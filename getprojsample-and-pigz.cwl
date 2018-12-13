cwlVersion: v1.0
# cwltool getprojsample-and-pigz.cwl --file 00getprojsample.pl --ipfile IP.txt
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
  getprojsample:
    run: perl-getprojsample.cwl
    in:
      file: file
      ipfile: ipfile
    out: [results]
  pigz:
    run: pigz.cwl
    in:
      file: getprojsample/results
    out: [compressed]
