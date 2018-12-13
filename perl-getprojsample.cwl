cwlVersion: v1.0
class: CommandLineTool
baseCommand: perl
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.datafile)
inputs:
  file:
    type: File
    inputBinding:
      position: 0
  datafile:
    type: File
    default: IP.txt
outputs:
  results: stdout
stdout: perl-getprojsample-out.txt
