#!/bin/sh

cd /Users/oec/Solr/solr-7.2.1
bin/post -c aoe -type text/xml -out yes -d '<delete><query>*:*</query></delete>'
