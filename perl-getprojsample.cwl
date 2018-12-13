cwlVersion: v1.0
class: CommandLineTool
baseCommand: perl
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.ipfile)
inputs:
  file:
    type: File
    inputBinding:
      position: 0
  ipfile:
    type: File
    default: IP.txt
outputs:
  results: stdout
stdout: perl-getprojsample-out.txt
