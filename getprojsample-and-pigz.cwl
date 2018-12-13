cwlVersion: v1.0
# cwltool getprojsample-and-pigz.cwl --file 00getprojsample.pl --datafile IP.txt
class: Workflow
inputs:
  file:
    type: File
    inputBinding:
      position: 0
  datafile:
    type: File
    default: IP.txt
outputs:
  counts:
    type: File
    outputSource: pigz/counts
steps:
  getprojsample:
    run: perl-getprojsample.cwl
    in:
      file: file
      datafile: datafile
    out: [results]
  pigz:
    run: pigz.cwl
    in:
      file: getprojsample/results
    out: [counts]
