//検索したデータのbarchart表示
;(function($) {
    $.fn.mychart = function(){
        //
        $("input[name = fulltext]").keypress(function(e){
            if(e.which == 13){
                drawMyChart();
                return false;
            }
        });
        $(".search .btn").click(function(){drawMyChart()});

        function drawMyChart(){
            var q = $("#fulltext").val();
		    if(q.match(/[^0-9a-zA-Z\- ]+/) == null && q != "") {
                if($("#section0").children().length == 0) {
                    var newsection = $("<div id='sub-header0'><h2><i class='fa fa-bar-chart-o fa-2x'></i> " + q + " " + h2_s0 +  "</h2><div class='info'></div></div><div id='mychart' class='dashboard'></div> ");
                    $("#section0").append(newsection)
                }else{
                    $("#section0").children().remove();
                    var newsection = $("<div id='sub-header0'><h2><i class='fa fa-bar-chart-o fa-2x'></i> " + q + " " + h2_s0 +  "</h2><div class='info'></div></div><div id='mychart' class='dashboard'></div> ");
                    $("#section0").append(newsection)
                }
		    }else{
			    alert("半角英数字を入力してください")
		　　};
                    newsection.ready(function(){
                        d3.json(url_mychart + "?fulltext=" + q, function (error, data) {
                            var w0 = 300;
                            var h0 = 175;
                            var barcolor = "#444400"
                            var margin0 = {top: 30, right:40, bottom: 20, left:55}

                            //crossfilterの作成
                            var cf0 = crossfilter(data),
                                    yer = cf0.dimension(function (d) {return d.Year;}),
                                    yers = yer.group().all(),
                                    or = cf0.dimension(function (d) {return d.Rep_organism;}),
                                    ors = or.group().top(15),
                                    as = cf0.dimension(function (d) {return d.Assay;}),
                                    ass = as.group().top(15);

                            //サンプル期間のリスト。d3.Date.fromatを文字列に変換
                            var myy = yers.map(function (d) {return d.key; });
                            var myo = ors.map(function(d){ return d.key; });
                            var mya = ass.map(function(d){ return d.key; });
                            var myt = data.length;//検索されたデータの総計
                            $("#sub-header0 > h2").append("<span class='nod'>(" + myt + h2_s0_ken +")</span>");
                            //選択された生物名リスト
                            var nm0 = []
                            var y0start;
                            var y0end;
                            var y0ag = [];

                            //検索されたデータが0でなければチャートを表示
                            if(myt != 0) {
                                var svg0 = d3.select("#mychart").append("svg").attr("class", "chart");
                                var svgh0 = svg0.append("g").attr("width", w0 + margin0.left).attr("hight", h0 + margin0.top)
                                        .attr("transform", "translate(" + margin0.left + "," + margin0.top + ")");
                                var svgh0b = svg0.append("g").attr("width", w0 + margin0.left).attr("height", h0 + margin0.top)
                                        .attr("transform", "translate(" + (margin0.left * 2  + w0) + "," + margin0.top + ")");
                                var svgh0c = svg0.append("g").attr("width", w0 + margin0.left).attr("height", h0 + margin0.top)
                                        .attr("transform", "translate(" + (margin0.left * 3  + w0 * 2) + "," + margin0.top + ")");

                                var x0 = d3.scale.ordinal()
                                        .domain(myy).rangeBands([0, w0]);
                                var x0s = d3.scale.ordinal()
                                        .domain(myy).rangeBands([0, w0]);
                                var y0 = d3.scale.linear()
                                        .domain([0, d3.max(yers, function (v) {
                                            return v.value
                                        })])
                                        .range([h0, 0]);
                                var x0b = d3.scale.ordinal()
                                        .domain(myo).rangeBands([0, w0]);
                                var x0bs = d3.scale.ordinal()
                                        .domain(myo).rangeBands([0, w0]);
                                var y0b = d3.scale.linear()
                                        .domain([0, d3.max(ors, function (v) {
                                            return v.value;
                                        })]).range([h0, 0]);
                                var x0c = d3.scale.ordinal()
                                        .domain(mya).rangeBands([0, w0]);
                                var x0cs = d3.scale.ordinal()
                                        .domain(mya).rangeBands([0, w0]);
                                var y0c = d3.scale.linear()
                                        .domain([0, d3.max(ass, function (v) {
                                            return v.value;
                                        })]).range([h0, 0]);

                                var x0Axis = d3.svg.axis().scale(x0).ticks(5).orient("bottom");
                                var y0Axis = d3.svg.axis();
                                var x0bAxis = d3.svg.axis().scale(x0b).orient("bottom");
                                var y0bAxis = d3.svg.axis().scale(y0b).orient("left").tickFormat(d3.format("d"));
                                var x0cAxis = d3.svg.axis().scale(x0c).orient("bottom");
                                var y0cAxis = d3.svg.axis().scale(y0c).orient("left").tickFormat(d3.format("d"));

                                //brush中のグループid
                                var ids;



                                function brushstart(){
                                    ids = this.id;
                                    switch(ids) {
                                        case "b0a":
                                            svgh0.classed("selecting",true);
                                            break;
                                        case "b0b":
                                            svgh0b.classed("selecting",true);
                                            break;
                                        case "b0c":
                                            svgh0c.classed("selecting",true);
                                    }

                                };

                                function brushmove(){
                                    var s = d3.event.target.extent();
                                    ids = this.id;
                                    switch(ids) {
                                        case "b0a":
                                            bar0.classed("selected", function(d,i){return s[0] <= (i * x0.rangeBand()) && (i+1) * x0.rangeBand() <= s[1];});
                                            break;
                                        case "b0b":
                                            bar0b.classed("selected", function(d,i){return s[0] <= (i * x0b.rangeBand()) && (i+1) * x0b.rangeBand() <= s[1];});
                                            break;
                                        case "b0c":
                                            bar0c.classed("selected", function(d,i){return s[0] <= (i * x0c.rangeBand()) && (i+1) * x0c.rangeBand() <= s[1];});
                                    }

                                };
                                function brushend(){
                                    ids = this.id;
                                    var rb;

                                    if(ids == "b0a"){
                                        xi = x0;
                                        xis = x0s;
                                    }else if(ids == "b0b"){
                                        xi = x0b;
                                        xis = x0bs;
                                    }else if(ids == "b0c"){
                                        xi = x0c;
                                        xis = x0cs;
                                    };

                                    rb = xi.rangeBand();

                                    var s = d3.event.target.extent();

                                    var selected = xi.domain()
                                        .filter(function(d,i){return(s[0] <= (i * rb) && (i+1) * rb <= s[1])});

                                    var originaldomain = xis.domain();

                                    if(ids == "b0a"){
                                        svgh0.classed("selecting", !d3.event.target.empty());
                                        if(d3.event.target.empty()){ selected = originaldomain;ye = d3.extent(myy);}else{ye = selected}
                                        yer.filterFunction(function(d){return selected.indexOf(d) > -1;});
                                        y0start = d3.extent(ye)[0];
                                        if(ye.length > 1){y0end = d3.extent(ye)[1];}
                                        else if(ye.length == 1){y0end = y0start}

                                    }else if(ids == "b0b"){
                                        svgh0b.classed("selecting", !d3.event.target.empty());
                                        if(d3.event.target.empty()){selected = originaldomain;nm0 = myo;}else{nm0 = selected};
                                        or.filterFunction(function(d){return selected.indexOf(d) > -1;});
                                    }else if(ids == "b0c"){
                                        svgh0c.classed("selecting", !d3.event.target.empty());
                                        if(d3.event.target.empty()){selected = originaldomain;y0ag = mya;}else{y0ag = selected}
                                        as.filterFunction(function(d){return selected.indexOf(d) > -1;});
                                    }

                                    updateMyChart();

                                };

                                //create brush object
                                var brush0 = d3.svg.brush().x(x0)
                                        .on("brushstart", brushstart)
                                        .on("brush", brushmove)
                                        .on("brushend", brushend);

                                var brush0b = d3.svg.brush().x(x0b)
                                        .on("brushstart", brushstart)
                                        .on("brush", brushmove)
                                        .on("brushend", brushend);

                                var brush0c = d3.svg.brush().x(x0c)
                                        .on("brushstart", brushstart)
                                        .on("brush", brushmove)
                                        .on("brushend", brushend);


                                var bar0 = svgh0.selectAll(".bar")
                                        .data(yers)
                                    .enter().append("g")
                                    .attr("class", "bar");

                                var bar0b = svgh0b.selectAll(".bar")
                                        .data(ors).enter().append("g").attr("class", "bar");

                                var bar0c = svgh0c.selectAll(".bar")
                                        .data(ass).enter().append("g").attr("class", "bar");

                                //チャートの描画
                                bar0.append("rect")
                                    .classed("rct", true)
                                    .attr("x", function (d, i) { return x0(d.key)})
                                    .attr("y", function (d) { return y0(d.value)})
                                    .attr("width", x0.rangeBand())
                                    .attr("height", function (d) {return h0 - y0(d.value)})
                                    .attr("fill", barColor)
                                    .attr("transorm", "translate(5,0")

                                bar0b.append("rect").classed("rct", true)
                                    .attr("x", function (d) { return x0b(d.key)})
                                    .attr("y", function (d) { return y0b(d.value)})
                                    .attr("width", x0b.rangeBand())
                                    .attr("height", function (d) { return h0 - y0b(d.value)})
                                    .attr("fill", barColor);

                                bar0c.append("rect").classed("rct", true)
                                    .attr("x", function (d) {return x0c(d.key) })
                                    .attr("y", function (d) {return y0c(d.value)})
                                    .attr("width", x0c.rangeBand())
                                    .attr("height", function (d) { return h0 - y0c(d.value)})
                                    .attr("fill", barColor);

                                svgh0.append("g").attr("class", "x axis")
                                        .attr("transform", "translate(0," + (h0 + 3) + ")")
                                        .call(x0Axis.tickFormat(function(d){
                                            if(d == null || d == "") {
                                              return "NA"
                                            }else{
                                                return d;
                                            }
                                         }))
                                        .selectAll("text")
                                        .style("text-anchor", "start")
                                        .attr("dy", "10").attr("dx", "5").attr("transform", function (d) {
                                            return "rotate(45)"
                                        });
                                svgh0.append("g").attr("class", "y axis")
                                        .attr("transform", "translate(-14 ,0)")
                                        .call(y0Axis.scale(y0).orient("left").tickFormat(d3.format("d")))
                                        .append("text")
                                        .text(chart_label_1)
                                        .attr("transform", "rotate(-90,7,-5)")
                                        .style({"text-anchor": "end"});

                                svgh0b.append("g").attr("class", "x axis")
                                        .attr("transform", "translate(0," + (h0 + 3) + ")")
                                        .call(x0bAxis.tickFormat(function (d) {
                                            if (d.length <= 22) {
                                                return d;
                                            } else if (d.length > 22) {
                                                txt = d.substr(0, 20) + '…';
                                                return txt;
                                            }
                                        }))
                                        .selectAll("text")
                                        .style("text-anchor", "start")
                                        .attr("dy", "10").attr("dx", "5").attr("transform", function (d) {
                                            return "rotate(45)"
                                        });

                                svgh0b.append("g").attr("class", "y axis")
                                        .attr("transform", "translate(-15,0)")
                                        .call(y0bAxis)
                                        .append("text")
                                        .text(chart_label_1)
                                        .attr("transform", "rotate(-90,7,-5)")
                                        .style({"text-anchor": "end"});

                                svgh0c.append("g").attr("class", "x axis")
                                        .attr("transform", "translate(0," + (h0 + 3) + ")")
                                        .call(x0cAxis.tickFormat(function (d) {
                                            if(d.length == 0) {
                                              return "NA"
                                            }else if (d.length <= 22) {
                                                    return d;
                                            } else if (d.length > 22) {
                                                    txt = d.substr(0, 20) + '…';
                                                    return txt;
                                                }
                                        }))
                                        .selectAll("text")
                                        .style("text-anchor", "start")
                                        .attr("dy", "10").attr("dx", "5").attr("transform", function (d) {
                                            return "rotate(45)"
                                        });

                                svgh0c.append("g").attr("class", "y axis")
                                        .attr("transform", "translate(-15,0)")
                                        .call(y0cAxis)
                                        .append("text")
                                        .text(chart_label_1)
                                        .attr("transform", "rotate(-90,7,-5)")
                                        .style({"text-anchor": "end"});

                                //add brush
                                function resizePath(d) {
                                    var e = +(d == "e"),
                                        x = e ? 1 : -1,
                                        y = h0 / 3;
                                    return "M" + (.5 * x) + "," + y
                                        + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
                                        + "V" + (2 * y - 6)
                                        + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
                                        + "Z"
                                        + "M" + (2.5 * x) + "," + (y + 8)
                                        + "V" + (2 * y - 8)
                                        + "M" + (4.5 * x) + "," + (y + 8)
                                        + "V" + (2 * y - 8);
                                }

                                var h0brush = svgh0.append("g").attr("class", "brush").attr("id","b0a").call(brush0);
                                h0brush.selectAll("rect")
                                        .style("cursor", "col-resize")
                                        .attr("height", h0);
                                h0brush.selectAll(".resize").append("path").attr("d",resizePath);

                                var h0bbrush = svgh0b.append("g").attr("class", "brush").attr("id","b0b").call(brush0b);
                                h0bbrush.selectAll("rect")
                                        .style("cursor", "col-resize")
                                        .attr("height", h0);
                                h0bbrush.selectAll(".resize").append("path").attr("d",resizePath);

                                var h0cbrush = svgh0c.append("g").attr("class", "brush").attr("id","b0c").call(brush0c);
                                h0cbrush.selectAll("rect")
                                        .style("cursor", "col-resize")
                                        .attr("height", h0);

                                h0cbrush.selectAll(".resize").append("path").attr("d",resizePath);

 				//submit button
                                var svgb0 = d3.select("#sub-header0 .info").append("svg")
                                        .attr("width", 220)
                                        .attr("height", 40);

                                //検索リンク生成
                                var sbmt0 = svgb0.append("a")
                                        .attr("xlink:href", function () {
                                            return  url_exp + "?fulltext=" + q;
                                        })
                                        .attr("transform", "translate(5, 5)");

                                //検索ボタンを生成し、検索用パラメータを加える。
                                var sbtn0 = sbmt0.append('rect')
                                        .attr("width", 220)
                                        .attr("height", 28)
                                        .attr("rx", 3)
                                        .attr("ry", 3)
                                        .attr("stroke", "#024b96")
                                        .attr("fill", "#024b96")
                                        .on("mouseover", function () {
                                            sbtn0.attr("fill", "#012d5a");
                                            sbmt0.attr("xlink:href", function () {
                                                var today = new Date();
                                                var param_org = nm0.length != 0 ? "Organisms=" + nm0 : "";
                                                var param_start =  y0start ? "ystart=" + y0start : "ystart=" + "2001";
                                                var param_end = y0end ? "yend=" + y0end : "yend=" + String(today.getFullYear());
                                                var param_fulltxt = q ? "fulltext=" + q : "";
                                                var param_assay = y0ag.length != 0 ? "assay=" + y0ag : "";
                                                var lst = [param_fulltxt, param_org, param_start, param_end, param_assay].filter(function(e){return e !== ""});
                                                var params = lst.join("&");
                                                return url_mylist + "?" + params.replace(/\&$/, '');

                                            })
                                        })
                                        .on("mouseout", function () {
                                            sbtn0.attr("fill", "#024b96")
                                        })
                                        .on("click", function () {
                                            sbtn0.attr("fill", "#024b96")
                                        })
                                        .attr("transform", "translate(0,0)");

                                sbmt0.append("text")
                                        .text(txt_a1)
                                        .attr("fill", "white")
                                        .attr("z-index", "10")
                                        .attr("font-size", "12px")
                                        .attr("transform", "translate(" + padding_mybtn + ",18)");

                                function updateMyChart(){
                                    myy = yers.map(function (d) {return d.key; });
                                    myo = ors.map(function(d){ return d.key; });
                                    mya = ass.map(function(d){ return d.key; });

                                    //
                                    x0.domain(myy);
                                    x0b.domain(myo);
                                    x0c.domain(mya);

                                    y0.range([h0, 0]).domain([0, d3.max(yers, function (v) { return v.value})]);
                                    y0b.range([h0, 0]).domain([0, d3.max(ors, function (v) { return v.value})]);
                                    y0c.range([h0, 0]).domain([0, d3.max(ass, function (v) { return v.value})]);

                                    //描画済みのg.barを選択しデータをバインディング
                                    var bar0 = svgh0.selectAll(".bar").data(yers);
                                    var bar0b = svgh0b.selectAll(".bar").data(ors);
                                    var bar0c = svgh0c.selectAll(".bar").data(ass);

                                    bar0.select("rect").transition().duration(500)
                                        .attr("x", function(d){return x0(d.key)})
                                        .attr("y", function(d){return y0(d.value)})
                                        .attr("width", x0.rangeBand())
                                        .attr("height", function(d){return h0 - y0(d.value)})
                                        .attr("fill", barColor);

                                    bar0b.select("rect").transition().duration(500)
                                        .attr("x", function(d){return x0b(d.key)})
                                        .attr("y", function(d){return y0b(d.value)})
                                        .attr("width", x0b.rangeBand())
                                        .attr("height", function(d){return h0 - y0b(d.value)})
                                        .attr("fill", barColor);

                                    bar0c.select("rect").transition().duration(500)
                                        .attr("x", function(d){return x0c(d.key)})
                                        .attr("y", function(d){return y0c(d.value)})
                                        .attr("width", x0c.rangeBand())
                                        .attr("height", function(d){return h0 - y0c(d.value)})
                                        .attr("fill", barColor);

                                    //軸のアップデート

                                    svgh0.select(".y.axis").transition().duration(500)
                                        .call(y0Axis);

                                    svgh0b.select(".y.axis").transition().duration(500)
                                        .call(y0bAxis);

                                    svgh0c.select(".y.axis").transition().duration(500)
                                        .call(y0cAxis);

                                }

                            }else{
                                // 検索結果が０の場合の処理
                                // グラフ表示エリアを削除
                                $("#mychart").remove();

                                //submit button
                                var svgb0 = d3.select("#sub-header0 .info").append("svg")
                                        .attr("width", 460)
                                        .attr("height", 40);

                                //検索リンク生成
                                var sbmt0 = svgb0.append("a")
                                        .attr("xlink:href", function () {
                                            return url_exp + "?organism=";
                                        })
                                        .attr("transform", "translate(5, 5)");

                                var sbmt0c = svgb0.append("g").attr("transform", "translate(5,5)");

                                //検索結果表示部分のDOMを削除
                                var sbtn0c = sbmt0c.append('rect')
                                        .attr("width", 220)
                                        .attr("height", 28)
                                        .attr("rx", 3)
                                        .attr("ry", 3)
                                        .attr("stroke", "#024b96")
                                        .attr("fill", "#024b96")
                                        .on("mouseover", function () {
                                            sbtn0c.attr("fill", "#012d5a");
                                        })
                                        .on("mouseout", function () {
                                            sbtn0c.attr("fill", "#024b96")
                                        })
                                        .on("click", function () {
                                            $("#section0").children().fadeOut(400, function () {
                                                $(this).remove()
                                            })
                                        })
                                        .attr("transform", "translate(235,0)");

                                sbmt0c.append("text")
                                        .text("検索結果をクリアする")
                                        .attr("fill", "white")
                                        .attr("z-index", "10")
                                        .attr("font-size", "12px")
                                        .attr("transform", "translate(290,18)");
                            }

                        });
                    });

                }
        //ここまで
    }

})(jQuery);
