import csv
import datetime
from dateutil import parser
import requests
import dotdict
import json
from functools import reduce

conf = {
    'base_url': 'http://localhost:8983/solr/aoe/select?',
    'facet_fields': ['Rep_organism', 'ArrayGroup', 'Technology', 'Instrument'],
    'facet_start': '2001-01-11T00:00:00Z',
    'stats_o_m': './static/uploads/organism_monthly.csv',
    'stats_o_c': './static/uploads/organisms_ct.csv',
    'stats_a_m': './static/uploads/assay_monthly.csv',
    'stats_a_o': './static/uploads/assay_organism.csv',
    'facet_query': 'facet.field={}&facet=on&indent=on&q=*:*&rows=0&wt=json&facet.limit={}&stats=true',
    'stats_query': 'fl={}&indent=on&q=*:*&rows=0&wt=json&stats=true&stats.field={}',
    'facet_range_query': 'q=*:*&fq={}:({})&facet=on&facet.range={}'
                         '&f.Date.facet.range.start={}&f.Date.facet.range.end=NOW'
                         '&f.Date.facet.range.gap=%2B1YEAR/YEAR&fl=Date&rows=0',
    'facet_range_total': 'q=*:*&facet=on&facet.range={}'
                         '&f.Date.facet.range.start={}&f.Date.facet.range.end=NOW'
                         '&f.Date.facet.range.gap=%2B1YEAR/YEAR&fl=Date&rows=0',
    'facet_assays_query': 'q=*:*&fq=Assay:{}&fq=Rep_organism:({})&facet=on&facet.range={}'
                         '&f.Date.facet.range.start={}&f.Date.facet.range.end=NOW'
                         '&f.Date.facet.range.gap=%2B1YEAR/YEAR&fl=Date&rows=0',
    'facet_assays_total': 'q=*:*&fq=Assay:{}&facet=on&facet.range=Date'
                         '&f.Date.facet.range.start={}&f.Date.facet.range.end=NOW'
                         '&f.Date.facet.range.gap=%2B1YEAR/YEAR&fl=Date&rows=0',
    'assays': ["Affymetrix", "Agilent", "Others_Array", "Unknown_Array", "Illumina", "Others_NGS", "Unknown_NGS"]
}
conf = dotdict.dotdict(conf)


def search_handler():
    count_organism()
    count_assay_by_y()
    count_organism_cumulative()
    count_assay_and_organism()


def count_assay_by_y():
    org_list = get_ranking()[0:10]
    # (各年, assay)行、生物種(10種)列のデータを作成する
    assay_lst = []
    ys = []
    # create assay_organism.csv
    for a in conf.assays:
        # COL
        org_lst = []
        for o in org_list:
            url = conf.base_url + conf.facet_assays_query.format(a, o, "Date", conf.facet_start)
            res = requests.get(url)
            dct = res.json()
            ys = [x[0:4] for x in dct["facet_counts"]["facet_ranges"]["Date"]["counts"][0::2]] if len(ys) == 0 else ys
            cnts = dct["facet_counts"]["facet_ranges"]["Date"]["counts"][1::2]
            org_lst.append(cnts)
        # リストの先頭に取得したレンジの年をリストとして追加しピボット
        org_lst.insert(0, ys)
        l = list(map(list, zip(*org_lst)))
        [x.insert(1, a) for x in l]
        assay_lst.append(l)

    # others(YEAR&Assayの検索結果の和-10位までの和)の値を追加
    # Y > Assay の二重のイテレーションでnumfoundを取得
    for i, a in enumerate(conf.assays):
        url = conf.base_url + conf.facet_assays_total.format(a, conf.facet_start)
        res = requests.get(url)
        dct = res.json()
        cnts = dct["facet_counts"]["facet_ranges"]["Date"]["counts"][1::2]
        # assay_lstにothersの値をappend
        for x, y in zip(cnts, assay_lst[i]):
            y.append(x - sum(y[2:]))

    # yでソートしながらリストを２次元に
    lst = []
    for i, y in enumerate(ys):
        for x in assay_lst:
            lst.append(x[i])
    # ヘッダを追加する
    o = get_ranking()[0:10]
    o.insert(0, "assay")
    o.insert(0, "year")
    o.append("others")
    lst.insert(0, o)

    with open(conf.stats_a_m, "w") as out_f:
        writer = csv.writer(out_f, lineterminator='\n')
        writer.writerows(lst)


def count_organism_cumulative():
    # 生物種毎facet.field=Dateなfacetを取得し、累積和のリストを生成
    lst = []
    ys = []
    org_list = get_ranking()[0:10]
    for o in org_list:
        url = conf.base_url + conf.facet_range_query.format("Rep_organism", o, "Date", conf.facet_start)
        res = requests.get(url)
        dct = res.json()
        cnt = dct["facet_counts"]["facet_ranges"]["Date"]["counts"][1::2]
        ys = [x[0:4] for x in dct["facet_counts"]["facet_ranges"]["Date"]["counts"][0::2]] if len(ys) == 0 else ys
        # 総和をmap
        cnt_cum = [sum(cnt[0:i]) for i, x in enumerate(cnt, 1)]
        cnt_cum = ["%.1f" %(x) for x in cnt_cum]
        lst.append(cnt_cum)
    lst.insert(0, ys)
    # ピボットする
    l = list(map(list, zip(*lst)))
    org_list = [x.capitalize() for x in org_list]
    org_list.insert(0, "year")
    l.insert(0, org_list)
    with open(conf.stats_o_c, "w") as out_f:
        writer = csv.writer(out_f, lineterminator='\n')
        writer.writerows(l)


def count_assay_and_organism():
    org_list = get_ranking()[0:10]
    lst = []
    ys = []
    for o in org_list:
        for a in conf.assays:
            url = conf.base_url + conf.facet_assays_query.format(a, o, "Date", conf.facet_start)
            res = requests.get(url)
            dct = res.json()
            cnt = dct["facet_counts"]["facet_ranges"]["Date"]["counts"][1::2]
            ys = [x[0:4] for x in dct["facet_counts"]["facet_ranges"]["Date"]["counts"][0::2]] if len(ys) == 0 else ys
            cnt.insert(0, a)
            cnt.insert(0, o)
            lst.append(cnt)

    ys.insert(0, "assay")
    ys.insert(0, "organism")
    lst.insert(0, ys)
    with open(conf.stats_a_o, "w") as out_f:
        writer = csv.writer(out_f, lineterminator='\n')
        writer.writerows(lst)


def count_organism():
    # 生物種を登録数で上位n位まで取得する
    org_list = get_ranking()
    # 年毎のトータルのデータ数をリストで取得
    cnt_total = get_facet_total()

    # 生物種毎、年毎のデータ登録数を取得する
    lst = []
    for o in org_list:
        lst_by_o = get_facet("Rep_organism", o)
        lst.append(lst_by_o)
    ls = list(map(list, zip(*lst)))

    # 各リストの先頭にインデックスを挿入する
    # 各年、最後から2番目の列にothersの値をinsertする
    # 最後の列に各年の総データ数をappendする
    # others = total - 30番目までのsum . totalは生物種を含めないクエリであらかじめsolrから取得しておく
    lst_by_y = []
    for l, t, y in zip(ls, cnt_total, get_years()):
        # othersの値を行に追加
        l.append(int(t) - sum(l))
        # 合計の値を行に追加
        l.append(t)
        # 年を先頭に挿入
        l.insert(0, y)
        lst_by_y.append(l)

    # 種名の頭をUpper caseに変換し、header行を生成
    org_list = [str[0].upper() + str[1:] for str in org_list]
    org_list.insert(0, "year")
    org_list.append("others")
    org_list.append("y_total")

    # headerを追加
    lst_by_y.insert(0,org_list)

    with open(conf.stats_o_m, 'w') as out_f:
        writer = csv.writer(out_f, lineterminator='\n')
        writer.writerows(lst_by_y)


def get_ranking(f="Rep_organism", n=30):
    url = conf.base_url + conf.facet_query.format(f, n)
    res = requests.get(url)
    dct = res.json()
    facet_lst = dct["facet_counts"]['facet_fields'][f]
    return facet_lst[0:-1:2]


def get_facet(fl, org, rng="Date"):
    url = conf.base_url + conf.facet_range_query.format(fl, org, rng, conf.facet_start)
    res = requests.get(url)
    dct = res.json()
    cnts = dct["facet_counts"]["facet_ranges"][rng]["counts"][1::2]
    return cnts


def get_years():
    y_start = conf.facet_start[0:4]
    y_end = int(datetime.datetime.now().strftime('%Y'))
    ys = []
    y = int(y_start)
    while y <= y_end:
        ys.append(y)
        y = y + 1
    return ys


def get_range():
    url = conf.base_url + conf.stats_query.format("Date", "Date")
    res = requests.get(url)
    dct = res.json()
    r = dct["stats"]["stats_fields"]["Date"]["min"], datetime.datetime.now().strftime('%Y-%m-%dT00:00:00Z')
    return r


def get_facet_total(rng="Date"):
    #  種を限定しない年毎のデータ数リストを返す
    url = conf.base_url + conf.facet_range_total.format(rng, conf.facet_start)
    res = requests.get(url)
    dct = res.json()
    cnts = dct["facet_counts"]["facet_ranges"][rng]["counts"][1::2]
    return cnts


