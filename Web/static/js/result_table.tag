<result-table>
    <div class="container">
        <h3><span class="stats">{founds} items found.</span></h3>
        <div id="rslt-table"></div>

        <div id="data-container"></div>
    </div>

    <script type="text/javascript">

        var self = this;
        var base_url = conf.api_base_url;
        // web site urlへ付随するパラメター
        var arg = {};
        var q =location.search.substring(1).split('&');
        for(var i=0;q[i];i++) {
            var kv = q[i].split('=');
            arg[kv[0]]=kv[1];
        };
        // 検索オプション
        var search_ops = ["rows", "sort"];
        var search_option = [];
        var search_keys = [];
        var rows = arg["rows"] ? arg["rows"] : conf.default_rows;
        // sortの設定デフォルトでDate descに固定
        //var sort = arg["sort"] ? arg["sort"] + "%20desc" : "uid%20desc";

        Object.keys(arg)
            .filter((function (k) {return search_ops.indexOf(k) != -1}))
            .forEach(function (k){
                var obj = {};
                obj[k] = arg[k];
                search_option.push(obj);
            });

        // 検索optionとして設定されたキーをargより外すinplace処理
        Object.keys(arg)
            .filter(function (k) { return search_ops.indexOf(k) != -1})
            .forEach(function(k){ delete arg[k]});

        Object.keys(arg)
            .forEach(function(k){ search_keys.push(
                k + "=" + arg[k]
            )});

        // tabulatorに渡すURLを設定.同時にobserverに通知
        var qs = search_keys.join('&')
        params['qs'] = qs;
        var q = base_url + params['qs'];
        opts.obs.trigger('params:filled', qs);
        var table_conf = {
                responsiveLayout: true,
                columns:[
                    {title:"ArrayExpress", field:"AE", minWidth:110, width:"8%", cellClick:function(e, cell){ if(cell.getValue() != "NA") {window.open("https://www.omicsdi.org/dataset/arrayexpress-repository/" + cell.getValue() )}}, headerSort:false},
                    {title:"Project", field:"PRJ", minWidth:105, width:"8%", align:"left", cellClick:function(e, cell){ if (cell.getValue() != "NA"){window.open("http://sra.dbcls.jp/details.html?db=bioproject&accession=" + cell.getValue())}}, headerSort:false},
                    {title:"GEO", field:"GSE", minWidth:105, width:"8%", align:"left", cellClick:function(e, cell){ if(cell.getValue() != "NA") {window.open("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=" + cell.getValue())}},headerSort:false},
                    {title:"Desctiption", field:"Description", width: "30%", headerSort:false},
                    {title:"Organism", field:"Rep_organism", width: " 10%"},
                    {title:"Array Group", field:"ArrayGroup", width: "8%", headerSort:false},
                    {title:"Technology", field:"Technology", width: "10%"},
                    {title:"Instrument", field:"Instrument", width: "10%"},
                    {title:"Last update", field: "Date",  formatter:function(cell){return cell.getValue().substr(0,10)}}
                ]
        };

        this.on("mount", function(){
            $("#rslt-table").tabulator({
                pagination:"remote",
                ajaxURL: q,
                timeout: 5000,
                paginationSize: rows,
                columns:table_conf["columns"],
                dataLoaded: function (datas) {
                    // 検索結果の数を表示する


                    self.update();
                    self.founds = datas["numFound"];

                    self.query_params = Object.keys(arg) + ": " +decodeURI(Object.values(arg));


                }
            });
        });



        //-->
    </script>

</result-table>