<form_set>
    <div class="container">
        <div class="select_set">
            <form id="search_aoe">
                <select class="select-organism" data-field="Organisms"></select>
                <select class="select-arraygroup" data-field="ArrayGroup"></select>
                <select class="select-technology" data-field="Technology"></select>
                <select class="select-instrument" data-field="Instrument"></select>
                <select class="select-rows" data-field="rows"><option</select>
                <input type="button" class="ui-button ui-widget ui-corner-all" id="search_aoe_btn" value="Search"/>
                <input show="{visible.dl}" type="button" class="ui-button ui-widget ui-corner-all" id="dl_id_lst"
                       value="Download ID list"/>
            </form>
        </div>
    </div>

    <script type="text/javascript">
        var self = this;
        this.visible = {
            dl: true
        };
        var rows = [{"text":25, "id": 0}, {"text":50, "id": 1},{"text": 100, "id":2}, {"text": 200, "id":3}  ];

        self.selected_item = {};
        var fields = [{"field": "Organism", "data": data_Rep_organism, "selector": ".select-organism", "width":155},
            {"field": "ArrayGroup", "data": data_ArrayGroup, "selector": ".select-arraygroup", "width": 155},
            {"field": "Technology", "data": data_Technology, "selector": ".select-technology", "width": 155},
            {"field": "Instrument", "data": data_Instrument, "selector": ".select-instrument", "width": 155},
            {"field": "max rows", "data": rows, "selector": ".select-rows", "width": 135},
        ];
        this.on("mount", function () {
            for (var i in fields) {
                $(fields[i]["selector"]).select2({
                    data: fields[i]["data"],
                    width: fields[i]["width"],  //サイズ
                    //placeholder: "Select " + fields[i]["field"], //動的にdataを読み込む場合はスキップされる
                    placeholder: {id: -1, text: 'Select ' + fields[i]["field"]},
                    allowClear: true,
                    templateSelection: function (data) {
                        if (data.id === -1) { // adjust for custom placeholder values
                            return 'Select ' + fields[i]["field"];
                        }
                        return data.text;
                    }
                });
                var f = fields[i]["selector"];
                $(f).on('select2:select', function (e) {
                    var k = $(this).attr('data-field');
                    self.selected_item[k] = e.params.data.text;
                })

            }

            $('#search_aoe_btn').click(function (e) {
                //console.log(self.selected_item);
                var path = location.pathname;
                var q = []
                for (e in self.selected_item) {
                    q.push(`${e}=${self.selected_item[e]}`)
                }
                qs = path + '?' + q.join('&');
                location.href = qs;
            });

            $('#dl_id_lst').click(function (e) {
                qs = '/api/fetch?' + params.qs;
                window.open(qs, '_blank');
            });

            opts.obs.on('params:filled', function (d) {
                self.visible['dl'] = d == '' ? false : true;
                self.update()
            })

        })

    </script>


</form_set>



