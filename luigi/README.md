# luigi python

## 概要

遺伝子 x RUNなどの発現量マトリクスから 
RUN どうしの類似度を計算しランキングで（類似度をソートして）JSONで返します

## 入力

発現量のマトリクスをインデックス列、カラム行有りのタブ区切りテキストとして入力ファイルとします。

### 入力ファイル例

```
id      NM_000014       NM_000015       NM_000016       NM_000017       NM_000018       NM_000019...
DRR000897       2.01043 0       41.8996 7.14537 166.349 61.9589 0       11.375  3.10128 1.33576 3.61708 0
DRR001173       0       0.200049        21.9467 20.8928 125.044 93.3776 0       20.2166 5.27255 0       6.94097
DRR001174       0       0       25.1586 13.5115 30.1159 108.001 0       21.0022 5.26211 0       6.17643 0
...
```

## スクリプトの呼び方

``` bash
$ python luigi.py <input file name> -o <out put file, option> -r < output ranking number, option>
```
### スクリプトの呼び出し例

ファイルT-TPM.txtを入力データとし、各サンプルについて10位ま類似なサンプルを生成しファイに出力する場合

```
$ python luigi.py T-TPM.txt -r 10
```


