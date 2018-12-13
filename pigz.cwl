cwlVersion: v1.0
class: CommandLineTool
baseCommand: [pigz, -c]
inputs:
  file:
    type: File
    inputBinding:
      position: 0
outputs:
  compressed: stdout
stdout: prj2gse.json.gz
