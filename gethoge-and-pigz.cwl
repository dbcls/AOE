cwlVersion: v1.0
# cwltool perl-gethoge.cwl --file 00getprojsample.pl --ipfile IP.txt
# cwltool perl-gethoge.cwl --file 00getlistofxRX.pl  --ipfile IP.txt
class: Workflow
inputs:
  file:
    type: File
    inputBinding:
      position: 0
  ipfile:
    type: File
    default: IP.txt
outputs:
  compressed:
    type: File
    outputSource: pigz/compressed
steps:
  gethoge:
    run: perl-gethoge.cwl
    in:
      file: file
      ipfile: ipfile
    out: [results]
  pigz:
    run: pigz.cwl
    in:
      file: gethoge/results
    out: [compressed]
