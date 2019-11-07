from flask import Flask, Response, send_from_directory, url_for, render_template, request
from urllib.parse import quote
import dotdict
import requests
import json
import math
import inspect
from datetime import date

conf = {
    'base_url': 'http://localhost:8983/solr/aoe/select?',
    'date_option': '&fq=Date:[*%20TO%20NOW]&sort=Date%20Desc',
    'wt': 'json',
    'max_dl_rows': 10000,
    'vocab': {'id': 'fq', 'Organisms': 'fq', 'ArrayGroup': 'fq', 'Technology': 'fq', 'Project': 'fq',
        'fulltext': 'fulltext', 'assay': 'assay', 'page': 'page', 'size': 'size', 'ystart': 'ystart', 'yend': 'yend'},
    'assay_fq':{'Affymetrix':'ArrayGroup:affymetrix', 'Others_NGS':'NGSGroup:others','Illumina':'NGSGroup:illumina',
               'Agilent':'ArrayGroup:agilent', 'Others_Array':'(ArrayGroup:Others OR NGSGroup:others)',
                'Others':'(ArrayGroup:Others AND NGSGroup:na)'},
    'max_mychart_rows': 80000
}
conf = dotdict.dotdict(conf)


app = Flask(__name__, static_url_path='')


@app.route('/css/<path:path>')
@app.route('/en/css/<path:path>')
def send_css(path):
    return send_from_directory('static/css', path)


@app.route('/en/js/<path:path>')
def send_js(path):
    return send_from_directory('static/js', path)


@app.route('/en/uploads/<path:path>')
def send_data(path):
    return send_from_directory('static/uploads', path)


@app.route('/experiment')
def index_page():
    qs = create_query_string(parse_request(request))
    return send_from_directory('static', 'experiments.html')


@app.route('/en/experiment')
def en_page():
    qs = create_query_string(parse_request(request))
    return send_from_directory('static', 'experiments.html')


@app.route('/')
def trends_page():
    return send_from_directory('static', 'static_trends.html')


@app.route('/en')
def en_trends_page():
    return send_from_directory('static', 'static_trends.html')


@app.route('/api/search')
def search():
    qs = create_query_string(parse_request(request))
    res = parse_response(key_word_search(qs))
    resp = Response(json.dumps(res))
    resp.headers['Access-Control-Allow-Origin'] = '*'
    resp.headers['Access-Control-Allow-Methods'] = 'POST, GET'
    resp.headers['Access-Control-Allow-Headers'] = '*'
    return resp


@app.route('/api/mychart')
def mychart():
    qs = create_query_string(parse_request(request))
    res = parse_mychart_response(key_word_search(qs))
    resp = Response(json.dumps(res))
    resp.headers['Access-Control-Allow-Origin'] = '*'
    resp.headers['Access-Control-Allow-Methods'] = 'POST, GET'
    resp.headers['Access-Control-Allow-Headers'] = '*'
    return resp


@app.route('/api/fetch')
def fetch_id_list():
    qs = create_query_string(parse_request(request))
    res = requests.get(qs)
    resp = Response(res.text)
    resp.headers['Content-Type'] = 'text/csv'
    return resp


def test():
    caller = inspect.getouterframes(inspect.currentframe(), 2)[1][3]
    return caller


def parse_request(r):
    # and検索を考慮するとMultiDictのままのほうがベターかも。要検討。
    return dict(r.args)


def create_query_string(obj):
    def fq(o):
        qs = o[1][0].replace(',', ' OR ')
        qs = qs.replace('%20', '\%20')
        return "fq=({}:*{}*)".format(o[0], qs)

    def fulltext(o):
        qs = quote(o[1][0]).replace('%20', '\%20')
        return "fq=_text_:%22*{}*%22".format(qs)

    q = []
    start_rows = {}
    dates = {}
    assays = []
    for o in obj.items():
        # keyが登録されていないケースは何もクエリに追加しない
        # 検索クエリ変換後に値取得後にstart-rowsを計算する（そのままqには追加しない）
        typ = conf.vocab.get(o[0], 'fulltext')
        if typ in ['page', 'size']:
            start_rows[typ] = o[1][0]
        elif typ == 'ystart':
            dates['ystart'] = o[1][0] + '-01-01T00:00:00Z'
        elif typ == 'yend':
            yend = o[1][0] + '-12-31T00:00:00Z'
            ty = date.today()
            # 検索期間がthis yearなケースではdatetime.todayを yendに渡す
            if int(o[1][0]) >= ty.year:
                yend = date.today().strftime("%Y-%m-%dT00:00:00Z")
            dates['yend'] = yend
        elif typ == 'assay':
            assays = o[1][0].split(',')
        else:
            # リストqにfqクエリを連結する
            q.append(locals().get(typ)(o))

    # start, rowsを設定
    rows = int(start_rows.get('size', 25))
    start = (int(start_rows.get('page', 1)) - 1) * rows
    # csv dl用のクエリを出力するケースではflやrowsを変更して、solrクエリを生成する。csvはconfに設定したmax rowsを超えない範囲で全件返す
    caller = inspect.getouterframes(inspect.currentframe(), 2)[1][3]
    if caller == "fetch_id_list":
        fl = "fl=AE,PRJ,GSE&"
        qs = conf.base_url + fl + '&'.join(q) + '&indent=on&q=*:*' + '&start=0'\
             + '&rows=' + str(conf.max_dl_rows) + '&wt=csv'
    elif caller == "mychart":
        fl = "fl=Rep_organism,Date,ArrayGroup,NGSGroup&"
        qs = conf.base_url + fl + '&'.join(q) + '&indent=on&q=*:*' + '&start=' + str(start) \
             + '&rows=' + str(conf.max_mychart_rows) + '&wt=' + conf.wt
    else:
        # レスポンスに含めるフィールドを設定
        fl = "fl=PRJ,AE,GSE,Description,Rep_organism,ArrayGroup,Technology,Instrument,Date&"
        # solr検索のクエリパラメータを連結
        qs = conf.base_url + fl + '&'.join(q) + '&indent=on&q=*:*' + '&start=' + str(start) \
             + '&rows=' + str(rows) + '&wt=' + conf.wt
    # 日付のレンジを追加
    dt = '&fq=Date:[{}%20TO%20{}]'.format(dates.get('ystart', '*'), dates.get('yend', 'NOW'))
    if len(dates) > 0:
        qs = qs + dt + '&sort=Date%20Desc'
    else:
        qs = qs + conf.date_option

    # assayがクエリに含まれいていた場合の検索クエリを追加
    if len(assays):
        #lst = [conf.assay_fq[x] for x in assays]
        lst = ["Assay:"+ x for x in assays]
        s = ' OR '.join(lst)
        s = '&fq=({})'.format(s)
        qs = qs + s
    return qs


def parse_response(res_dict):
    obj = dict()
    obj['numFound'] = res_dict['response']['numFound']
    obj['data'] = res_dict['response']['docs']
    obj['start'] = res_dict['response']['start']
    obj['last_page'] = math.ceil(int(obj['numFound']) / int(res_dict['responseHeader']['params']['rows']))
    return obj


def parse_mychart_response(res_dict):
    lst = res_dict['response']['docs']
    stats = [{"Rep_organism": x.get("Rep_organism"), "Year": d2y(x["Date"]),
              "Assay": create_assay(x["ArrayGroup"], x["NGSGroup"])} for x in lst]
    return stats


def d2y(d):
    return d[0:4]


def create_assay(ag, ng):
    if ng == "NA":
        ng = ""
    if ng:
        ag = ""
    if ag == "Others":
        ag = "Others_Array"
    if ng == "Others":
        ng = "Others_NGS"
    return ng + ag


def key_word_search(s):
    res = requests.get(s)
    res_dict = res.json()
    return res_dict


if __name__ == "__main__":
    #app.run(host='localhost', debug=True)
    app.run(host='0.0.0.0', debug=True)
