import csv
import datetime
from dateutil import parser
import requests
import dotdict
import json
import argparse
import subprocess
import create_stats
from urllib.request import urlopen

#SOURCE_FILE_PATH = "data/AOE2-tab171129.txt"
# source_fileを標準化したファイルを決まったファイル名に書き出す
NEW_FILE = "/Users/oec/Dropbox/workspace/github/aoe/data/normalized_data.txt"
DEFAULT_DATE = ""
UPDATE_API = "http://localhost:8983/solr/aoe/update?commit=true&separator=%09&escape=%5c"
RESET_URL = "http://localhost:8983/solr/aoe/update?enableStreamBody=true&stream.body=<delete><query>*:*</query></delete>&commit=true"
COMMIT_URL = "http://localhost:8983/solr/aoe/update?stream.body=<commit/>"
RESET_PARAMS = {
    "set-property" : {"requestDispatcher.requestParsers.enableRemoteStreaming":"true"},
    "set-property" : {"requestDispatcher.requestParsers.enableStreamBody":"true"}
}
RESET_HEAD = {"Content-type":"application/json"}
conf = {
    'base_url': 'http://localhost:8983/solr/aoe/select?',
    'facet_fields': ['Rep_organism', 'ArrayGroup', 'Technology', 'Instrument'],
    'facet_query': 'facet.field={}&facet=on&indent=on&q=*:*&rows=0&wt=json&facet.limit=3000'
}
conf = dotdict.dotdict(conf)


# coreを初期化し、txtファイルからデータを再登録。
def update_handler():
    # コマンドライン引数からファイルパスを取得する
    source_file = get_args()
    # 空白の除去・assay列の追加・キーの追加
    normalize_data(source_file)

    data = open(NEW_FILE, 'rb').read()
    reset_core()

    res = requests.post(url=UPDATE_API,
                        data=data,
                        headers={'Content-type':'application/csv'})

    # 検索用のfacet dataを更新
    export_facet()

    # 統計ファイルを更新
    create_stats.search_handler()


def get_args():
    parser = argparse.ArgumentParser('Define input file path.')
    # 位置引数'file'を定義
    parser.add_argument('file')
    args = parser.parse_args()
    return args.file


def reset_core():
    # solr corの更新時一度現在のcoreをクリアする
    subprocess.run(['sh', 'clear_core.sh'])


# dateの値を標準化＆値をstrip()してtsvを書き換える。
def normalize_data(f):
    new_date = []
    with open(f, encoding='utf8', errors='ignore') as input_f:
        reader = csv.reader(input_f, delimiter='\t')
        for i, r in enumerate(reader):
            # 各要素の前後についた空白を取り除く
            r = [x.strip() for x in r]
            # ヘッダ行で、行の先頭に"ID"をを挿入&最後に"Assaay"をカラム名として追加
            if i == 0:
                # 先頭３項目のカラム名をつける
                r[0] = "PRJ"
                r[1] = "AE"
                r[2] = "GSE"
                r.insert(0, "ID")
                r.append("Assay")
            else:
                # \が文字列に含まれるケースがあるので置き換える
                r = [x.replace('\\', ' ') for x in r]
                # もし列の順序が不定であれば、mapを設定する
                # assay()の値を行最後に追加する（引数はArrayGroupとNGSGroup）
                r.append(assay(r[6].lower(), r[9].lower()))
                # iの値を行先頭に挿入する
                r.insert(0, i)
                dt = check_date_val(r[5])
                r[5] = dt
            new_date.append(r)

    with open(NEW_FILE, "w") as out_f:
        writer = csv.writer(out_f, delimiter='\t', lineterminator='\n')
        writer.writerows(new_date)


def assay(arr, ngs):
    # Assayの値を生成
    if ngs == "illumina":
        r = "Illumina"
    elif ngs == "others":
        r = "Others_NGS"
    elif arr == "affymetrix":
        r = "Affymetrix"
    elif arr == "others":
        r = "Others_Array"
    elif arr == "agilent":
        r = "Agilent"
    elif ngs == "unknown_ngs":
        r = "Unknown_NGS"
    elif arr == "unknown_array":
        r = "Unknown_Array"
    else:
        r = "NA"

    return r


def check_date_val(dt):
    try:
        t = parser.parse(dt)
        d = t.strftime("%Y-%m-%d")
        return d
    except ValueError:
        if dt == "Date":
            return dt
        else:
            return DEFAULT_DATE


def export_facet():
    fields = conf.facet_fields
    facet_data = []
    s = ''
    for f in fields:
        url = conf.base_url + conf.facet_query.format(f)
        res = requests.get(url)
        dct = res.json()
        facet_lst = dct["facet_counts"]['facet_fields'][f]
        facet_dct = [{'id': i, 'text': x} for i, x in enumerate(facet_lst[::2])]
        facet_dct.insert(0, {"id": -1})
        s = s + 'var data_{} = '.format(f) + json.dumps(facet_dct) + '\n'

    data_text = open('./static/js/facet_data.js', 'w')
    data_text.write(s)
    data_text.close()


update_handler()


