# AOE API documentation

## /api/search

Search keyword across all fields.

### options

- fulltext   (search keyword across all text fields)
- Organisms
- Instrument
- ArrayGroup
- Technology
- page
- size

### usage

__Example__

```
/api/search?fulltext=hypoxia&page=1&size=25
```

```
/api/search?Technology=microarray&Organisms=homo%20sapiens&page=1&size=25
```


### response

__Example__
```
{
"last_page": 1,
"start": 0,
"numFound": 2,
"data":
[{
"PRJ": NA,
"AE":  "E-MARS-28",
"GSE": NA,
"ArrayGroup: "Others",
"Rep_organism": "Homo sapiens",
"Technology": "microarray",
"Date": "2014-08-12T00:00:00Z" ,
"Description: "Transcription profiling by array of hMADS cells transfected with miR-26a"
},,]
}
```

## /api/fetch

Search keyword across all fields and get accessions.

### options

- Organisms
- Instrument
- ArrayGroup
- Technology

### usage

__Example__

```
/api/fetch?Organisms=Canis%20lupus%20familiaris
```


### response

__Example__

```
AE,PRJ,GSE
E-MTAB-7103,NA,NA
NA,PRJNA9559,GSE118271
NA,PRJNA10726,GSE118029
NA,PRJNA10726,GSE117010
NA,PRJNA10726,GSE116881
NA,PRJNA453534,GSE113649
...
```