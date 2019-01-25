#!/bin/sh
# script to get metadata from xRX.json

# run

pigz -dc xRX.json.gz \
| perl 01xRX2instrument_model.pl \
| pigz -c \
> xRX2instrument_model.txt.gz

