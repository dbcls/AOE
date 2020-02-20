# -*- coding: utf-8 -*-
import json
import numpy as np
from numpy.linalg import norm
import argparse
import csv
import sys

# ファイルとして書き出す場合
#dbname = "data/ex.db"
#tblname = "human_fantom5_ranking"

parser = argparse.ArgumentParser()
# parser.add_argument('input', help='input file path')
parser.add_argument('-o', '--output', default='ranking.json', help='output file path')
parser.add_argument('-r', '--rows', default=100, help='out put ranking number')
args = parser.parse_args()
GET_NUM = 100

# 出力パスを入力
OUT_PUT = ""


def main(f, rows):
    """
    aoe内部で用いる本luigi.pyはaoeデータの類似度検索用に下記のように変更している
    - コマンドライン引数ではなく、メソッドの引数でmain()を呼ぶ
    - 全類似度を返す。ランキング上位に要約したくないが、後の処理が重すぎるため200位程度まで
    - ファイルに保存では無く、オブジェクトを返す。
    :param f:
    :param rows:
    :return:
    """
    input_file = f

    # 類似度マトリクスとインデックス（行方向のid）を取得
    res_sim, id_list = calc(input_file)
    i = 0
    # 行ごと、値をソートして、ランキングを取得
    ranking = []
    for l in res_sim:
        id = l.pop(0)
        # ソートされた類似度、これに対応してソートされた類似度arrayのインデックスを取得
        val_s, idx_s = sort(l)
        # create_ranking()で返る、id、類似性値はjsonである必要がある
        ranking.append({id: create_ranking(id_list,val_s,idx_s)})

    # fileに出力する場合
    export_ranking(ranking)

    # sqliteに出力する場合
    # store_ranking(ranking)



def sort(l):
    # listを降順にソートし、ソートした値のインデックスを取得
    value_sorted = np.sort(l)[::-1]
    index_sorted = np.argsort(l)[::-1]
    return value_sorted, index_sorted


def create_ranking(ids,val_s,idx_s):
    # get_num = args.rows
    # 類似度行方向データの間の類似度であるためindex_nameのリストにindexを渡すと対応するindex nameとなる
    ranking_array = []
    for i, id in enumerate(idx_s):
        idx_name = ids[id]
        val = val_s[i]
        ranking_array.append({"id": idx_name, "value": val})

        if i >= int(GET_NUM):
            break

    return ranking_array


def export_ranking(d):
    # output_file = args.output
    output_file = OUT_PUT
    with open(output_file, "w") as f:
        json.dump(d, f)


def get_index(name):
    with open(name, 'rb') as input_f:
        names = [row.split()[0].decode('utf-8') for row in input_f]
    return names


def get_col_len(name):
    with open(name, 'rb') as input_f:
        for i, row in enumerate(input_f):
            sample_list = row.split()
            if i >= 0:
                break
    return sample_list


def load_data(name):
    cols = len(get_col_len(name))
    # ヘッダを飛ばし＆idカラムの次の列から取得
    data = np.loadtxt(name, delimiter='\t', skiprows=1, usecols=range(1, cols))
    return data


# ファイルに書き出しているので、np.arrayを返すように変更
def calc(input_f):
    data = load_data(input_f)
    header = get_index(input_f)
    names = header[1:]
    similarity = []

    for i in range(len(data)):
        v1 = data[i]
        v = []
        for j in range(len(data)):
            v2 = data[j]
            n1 = norm(v1)
            n2 = norm(v2)
            s = np.dot(v1, v2) / (n1 * n2)
            v.append(s)

        v.insert(0, names[i])
        similarity.append(v)

    return similarity, names


main()
