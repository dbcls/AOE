<static_main>

    <div id="section1" class="clearfix">
        <div id="sub-header1" class="clearfix">
            <h2><i class="fa fa-bar-chart-o fa-2x"></i>
                <span if="{!lan_en}">生物種別登録データランキング</span>
                <span if="{lan_en}">Ranking by organisms</span>
            </h2>
            <div class="info"></div>
        </div>
        <div class="dashboard clearfix">
            <div class="charts clearfix">
                <div id="histogram_organism" class="histogram"></div>
                <div id="cu_organism" class="cu"></div>
            </div>
            <div class="pie clearfix">
                <div id="composition_organism" class="composition"></div>
            </div>

            <div class="ranking clearfix">
                <ul id="ranking_lst"></ul>
                <button data-toggle='collapse' data-target='#o10' id="toggle_btn">show more</button><br>
                <div id="o10" class="collapse"></div>

                <div class="note">
                    <span style="font-size: 11px;">Togo picture gallery by DBCLS is licensed under</span>
                    <a href="http://creativecommons.org/licenses/by/2.1/jp/"><span style="font-size: 11px;"> a Creative Commons Attribution 2.1 Japan license (c)</span></a>
                </div>
            </div>

        </div>

    </div>


    <script>
        this.on("mount", function () {
            var self = this;
            var path = location.pathname;
            self.lan_en = path.startsWith('/en') ? true : false;
            self.update();

            //bar chart
            var svgh1 = d3.select("#histogram_organism").append("svg").attr("class", "chart")
                .attr("width", width1)
                .attr("height", height1 + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            //line chart
            var svgl1 = d3.select("#cu_organism").append("svg")
                .attr("width", width2)
                .attr("height", height2 + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top / 2 + ")");

            //pie chart and button UI
            var svgp1 = d3.select("#composition_organism").append("svg")
                .attr("width", width3 + margin.left).attr("height", height3 + margin.bottom).append("g")
                .attr("transform", "translate(" + ((width3 / 2) + (r1 / 2)) + "," + (r1 + 15) + ")");

            // pie chart text lavels
            svgp1.append("g").attr("class", "pies");
            svgp1.append("g").attr("class", "labels");

            // html table area
            var tb1 = d3.select("#ranking_lst");
            var tb10 = d3.select("#o10");

            //submit button
            var svgb1 = d3.select("#sub-header1 .info").append("svg")
                .attr("width", 225)
                .attr("height", 40);

            //create function to draw the arcs of the pie slice
            var arc1 = d3.svg.arc().outerRadius(r1 - 10).innerRadius(0);
            var outerArc = d3.svg.arc()
                .innerRadius(radius * 0.9)
                .outerRadius(radius * 0.9);

            //create function to compute the pie slice angles
            var pie1 = d3.layout.pie().sort(null).value(function (d) {
                return d.freq;
            });

            //年ごとの登録件数データを読み込み
            d3.csv("/uploads/organism_monthly.csv", function (error, data1) {
                //年間の合計登録数。ヒストグラム用。
                var yT = data1.map(function (d) {
                    return [d.year, +d.y_total, 0]
                });
                var ys = data1.map(function (d) {
                    return d.year
                });
                var ixLabel = 'year'

                //生物名を取得。y_total=年ごとのすべての生物の集計値、をのぞく
                var varNames1 = d3.keys(data1[0])
                    .filter(function (key) {
                        return key !== ixLabel && key !== "y_total";
                    });
                //生物種ごとの登録数。pie chart。
                //varNames10 = varNames1.slice(0,10);
                var yo = varNames1.map(function (name) {
                    return {
                        name: name,
                        freq: d3.sum(data1.map(function (d) {
                            return d[name]
                        })),//data1にd.生物名でmapしたArrayをsum
                        vis: 1
                    }
                });

                //10位までのobject yo10をyoから作成。piechartとtableにわたす
                var yo10 = Array.prototype.slice.call(yo, 0, 10);

                color1.domain(varNames1);

                //mapping values of "year"
                //var x1 = d3.scale.ordinal().rangeBands([0,width1 - margin.left - margin.right])
                //.domain(yT.map(function(d){return d[0]}));
                var x1 = d3.scale.ordinal().rangeBands([0, width1 - margin.left - margin.right])
                    .domain(yT.map(function (d) {
                        return d[0]
                    }));

                var x1s = d3.scale.ordinal().rangeBands([0, width1 - margin.left - margin.right])
                    .domain(yT.map(function (d) {
                        return d[0]
                    }));

                var y1 = d3.scale.linear().range([height1, 0])
                    .domain([0, d3.max(yT, function (d) {
                        return +d[1]
                    })]);

                var y2 = d3.scale.linear().range([height2, 0]);

                var y1Axis = d3.svg.axis();

                svgh1.append("g").attr("class", "x axis")
                    .attr("transform", "translate(0," + (height1 + 2) + ")")
                    .call(d3.svg.axis().scale(x1).orient("bottom")).selectAll("text")
                    .attr("transform", function (d) {
                        return "rotate(45)"
                    }).style("text-anchor", "start");

                svgh1.append("g").attr("class", "y axis")
                    .attr("transform", "translate(0,0)")
                    .call(y1Axis.scale(y1).orient("left"))
                    .append("text")
                    .text(chart_label_1)
                    .attr("transform", "rotate(-90,10,-5)")
                    .style({"text-anchor": "end"});

                var bars1 = svgh1.selectAll(".bar").data(yT).enter()
                    .append("g").attr("class", "bar");

                bars1.append("rect")
                    .classed("rct", true)
                    .attr("x", function (d) {
                        return x1(d[0])
                    })
                    .attr("y", function (d) {
                        return y1(d[1])
                    })
                    .attr("width", (0.9 * x1.rangeBand()))
                    .attr("height", function (d) {
                        return height1 - y1(d[1])
                    })
                    .attr("fill", barColor);

                bars1.append("text").text(function (d) {
                    return d3.format(",")(d[1])
                })
                    .attr("x", function (d) {
                        return x1(d[0]) + x1.rangeBand() / 2;
                    })
                    .attr("y", function (d) {
                        return y1(d[1]) - 5
                    })
                    .attr("text-anchor", "middle");

                //draw the pie slices
                var piechart1 = svgp1.select(".pies").selectAll("path").data(pie1(yo10)).enter().append("path");

                piechart1.attr("d", arc1)
                    .each(function (d) {
                        this._current = d;
                    })
                    .style("fill", function (d, i) {
                        if (i < 10) {
                            return color1(d.data.name);
                        } else {
                            return "#aaaaaa"
                        }
                    });

                // text_label
                var text_label = svgp1.select(".labels")
                    .selectAll("text").data(pie1(yo10));

                text_label
                    .enter().append("text")
                    .attr("dy", ".35em")
                    .text(function (d) {
                        return d.data.name;
                    });

                function midAngle(d) {
                    return d.startAngle + (d.endAngle - d.startAngle) / 2;
                }

                function text_transition() {
                    text_label.transition()
                        .attrTween("transform", function (d, i) {
                            this._current = this._current || d;
                            var interpolate = d3.interpolate(this._current, d);
                            this._current = interpolate(0);
                            return function (t) {
                                var d2 = interpolate(t);
                                var pos = outerArc.centroid(d2);
                                //pos[0] = radius * (midAngle(d2) < Math.PI ? 1 : -1);
                                pos[1] = Math.pow(pos[1], 3) / 1000 - i * 5;
                                return "translate(" + pos + ")";
                            };
                        })
                        .styleTween("text-anchor", function (d) {
                            this._current = this._current || d;
                            var interpolate = d3.interpolate(this._current, d);
                            this._current = interpolate(0);
                            return function (t) {
                                var d2 = interpolate(t);
                                return midAngle(d2) < Math.PI ? "start" : "end";
                            };
                        })
                        .style("font-size", 9);

                }

                text_transition();

                //選択した年の範囲でパイチャートをアップデートする
                function pie1Update(yo_s) {
                    piechart1.data(pie1(yo_s));
                    piechart1.transition().duration(500).attrTween("d", arcTween);
                    text_label.data(pie1(yo_s));
                    text_transition()
                }

                function arcTween(a) {
                    var i = d3.interpolate(this._current, a);
                    this._current = i(0);
                    return function (t) {
                        return arc1(i(t));
                    };
                }

                //ランキング（num）
                var bt1 = tb1.selectAll("li")
                    .data(yo.slice(0, 10))
                    .enter().append("li")
                    .attr("class", "btns");

                var bt10 = tb10.append("ul").attr("class", "more").selectAll("li")
                    .data(yo.slice(10))
                    .enter().append('li')
                    .attr('class', 'btns');

                bt1.html(function (d, i) {
                    return "<div class='org_rank' style='background-color:" + bgc(d, i) + "'>" + (i + 1) + "</div>" + "<div class='org_name'>" + d.name + "</div>"
                        + "<div class='org_num'>" + d3.format(",")(d.freq) + "</div>"
                        + "<img src='" + togopics[d.name] + "' width='40' height='40'>";
                })
                    .on("click", function (d) {
                        var a;
                        if (d.vis == 1) {
                            d.vis = 0
                        } else {
                            d.vis = 1;
                            bar1update()
                        }
                        bt1.select(".org_rank")
                            .attr("style", function (d) {
                                checkvis();
                                a = d.vis;
                                if (d.vis == 0) {
                                    return "background-color:" + color1(d.name);
                                } else {
                                    return "background-color: #eeeeee"
                                }
                            });

                        bt10.select(".org_rank")
                            .attr("style", function (d) {
                                a = d.vis;
                                if (d.vis == 0) {
                                    return "background-color:#aaaaaa";
                                } else {
                                    return "background-color: #eeeeee"
                                }
                            });
                        bar1update();
                    });

                bt10.html(function (d, i) {
                    return "<div class='org_rank' style='background-color: #aaaaaa'>" + (i + 11) + "</div>" + "<div class='org_name'>" + d.name + "</div>"
                        + "<div class='org_num'>" + d3.format(",")(d.freq) + "</div>"
                        + "<img src='" + togopics[d.name] + "' width='25' height='25'>";
                })
                    .on("click", function (d) {
                        var a;
                        if (d.vis == 1) {
                            d.vis = 0
                        } else {
                            d.vis = 1;
                            bar1update()
                        }
                        bt1.select(".org_rank").transition().duration(200)
                            .attr("style", function (d) {
                                checkvis();
                                a = d.vis;
                                if (d.vis == 0) {
                                    return "background-color:" + color1(d.name);
                                } else {
                                    return "background-color: #eeeeee"
                                }
                            });
                        bt10.select(".org_rank")
                            .attr("style", function (d) {
                                a = d.vis;
                                if (d.vis == 0) {
                                    return "background-color: #aaaaaa";
                                } else {
                                    return "background-color: #eeeeee"
                                }
                            });
                        bar1update();
                    });

                //すべての生物が非選択になったら、自動的に全てvis = 0に設定しなおす
                //visの初期値=1
                function checkvis() {
                    ss = d3.sum(yo, function (d) {
                        return d.vis
                    });
                    if (ss == varNames1.length) {
                        for (key in yo) {
                            yo[key].vis = 0
                        }
                    }
                }

                function bgc(d, i) {
                    if (d.vis == "1") {
                        if (i < 11) {
                            return color1(d.name)
                        } else {
                            return "#aaaaaa"
                        }
                    } else {
                        return "white"
                    }
                }

                //検索リンク生成
                var sbmt1 = svgb1.append("a")
                    .attr("xlink:href", function () {
                        return url_mylist;
                    })
                    .attr("transform", "translate(5, 5)");


                //検索ボタンを生成し、検索用パラメータを加える。
                var sbtn1 = sbmt1.append('rect')
                    .attr("width", 220)
                    .attr("height", 28)
                    .attr("rx", 3)
                    .attr("ry", 3)
                    .attr("stroke", "#024b96")
                    .attr("fill", "#024b96")
                    .on("mouseover", function () {
                        sbtn1.attr("fill", "#012d5a");
                        sbmt1.attr("xlink:href", function () {
                            if (others) {
                                return url_mylist + "?others=true&Organisms=" + nmotr + "&ystart=" + sd_extent[0] + "&yend=" + sd_extent[1];
                            } else {
                                // nm: organismのリスト
                                var param_org = nm ? "Organisms=" + nm : "";
                                var param_start = sd_extent[0] ? "ystart=" + sd_extent[0] : "";
                                var param_end = sd_extent[1] ? "yend=" + sd_extent[1] : "";
                                var params = [param_org, param_start, param_end].join("&");
                                return url_mylist + "?" + params
                                //return url_mylist + "?" + param_org + "&ystart=" + sd_extent[0] + "&yend=" + sd_extent[1];
                            }
                        })
                    })
                    .on("mouseout", function () {
                        sbtn1.attr("fill", "#024b96")
                    })
                    .on("click", function () {
                        sbtn1.attr("fill", "#024b96")
                    });

                sbmt1.append("text")
                    .text(txt_a1)
                    .attr("fill", "white")
                    .attr("z-index", "10")
                    .attr("font-size", "12px")
                    .attr("transform", "translate(" + padding_sbtn + ",18)");

                //累積度数グラフ
                d3.csv("/uploads/organisms_ct.csv", function (error, data1cu) {
                    var varNames10 = varNames1.slice(0, 10);
                    var co = varNames10.map(function (name) {
                        return {
                            name: name, values: data1cu.map(function (d) {
                                return {name: name, label: d[ixLabel], value: +d[name]};
                            }),
                            vis: "0"
                        }
                    });

                    y2.domain([
                        d3.min(co, function (c) {
                            return d3.min(c.values, function (d) {
                                return d.value
                            });
                        }),
                        d3.max(co, function (c) {
                            return d3.max(c.values, function (d) {
                                return d.value
                            });
                        })
                    ]);

                    //create function to draw line chart
                    var line1 = d3.svg.line()
                        .x(function (d) {
                            return x1(d.label) + x1.rangeBand()
                        })
                        .y(function (d) {
                            return y2(+d.value)
                        });


                    // line chart

                    var chart1 = svgl1.append('g');

                    var series1 = chart1.selectAll(".series")
                        .data(co)
                        .enter()
                        .append('g')
                        .attr('class', 'series');

                    series1.append("path")
                        .attr("class", "line")
                        .attr("d", function (d) {
                            if (d.vis == "0") {
                                return line1(d.values);
                            } else {
                                return null
                            }
                        })
                        .style("stroke", function (d) {
                            return color1(d.name);
                        })
                        .style("stroke-width", "2px")
                        .style("fill", "none");

                    chart1.append("g")
                        .attr("class", "x axis focus")
                        .attr("transform", "translate(0," + (height2 + 5) + ")")
                        .style({"stroke": "#444", "fill": "none", "stroke-width": "1px"})
                        .call(d3.svg.axis().scale(x1).orient("bottom"))
                        .selectAll("text")
                        .attr("transform", function (d) {
                            return "rotate(45)"
                        })
                        .style("text-anchor", "start");

                    svgl1.append("g").attr("class", "y axis")
                        .attr("transform", "translate(0,0)")
                        .call(d3.svg.axis().scale(y2).orient("left"))
                        .append("text")
                        .text(chart_label_2)
                        .attr("transform", "rotate(-90,10,-5)")
                        .style({"text-anchor": "end"});

                });

                //選択された生物種の期間ごとの合計値でヒストグラムをアップデートする
                function bar1update() {
                    yT = totaling1(data1);
                    x1.domain(yT.map(function (d) {
                        return d[0]
                    }));
                    y1.range([height1, 0]).domain([0, d3.max(yT, function (d) {
                        return +d[1]
                    })]);

                    var bars1 = svgh1.selectAll(".bar").data(yT);

                    bars1.select("rect").transition().duration(500)
                        .attr("x", function (d) {
                            return x1(d[0])
                        })
                        .attr("y", function (d) {
                            return y1(d[1])
                        })
                        .attr("width", (0.9 * x1.rangeBand()))
                        .attr("height", function (d) {
                            return height1 - y1(d[1])
                        })
                        .attr("fill", barColor);

                    bars1.select("text").transition().duration(500)
                        .text(function (d) {
                            return d3.format(",")(d[1])
                        })
                        .attr("x", function (d) {
                            return x1(d[0]) + x1.rangeBand() / 2;
                        })
                        .attr("y", function (d) {
                            return y1(d[1]) - 5
                        })
                        .attr("text-anchor", "middle");

                    svgh1.select(".y.axis").transition().duration(500)
                        .call(y1Axis);
                }

                //選択した生物種のみの年ごとの登録件数データを生成
                function totaling1(data1) {
                    //選択された生物名をnmにプッシュ
                    nm = [];
                    others = "";
                    for (h in varNames1) {
                        if (yo[h].name == "others" && yo[h].vis == 0) {
                            others = "true";
                        } else if (yo[h].vis == 0) {
                            nm.push(yo[h].name);
                        }
                    }
                    if (others) {
                        nmotr = varNames1.filter(function (v) {
                            return nm.indexOf(v) == -1;
                        });
                        nmotr = nmotr.filter(function (v) {
                            return v != "others"
                        });
                    }
                    ;

                    var total = [];
                    for (k in data1) {
                        d1 = data1[k];
                        t = 0;
                        //文字列から数値への型変換
                        for (j in nm) {
                            t = t + Number(d1[nm[j]]);
                        }
                        total.push(t);
                    }
                    new_yT = yT.map(function (d, i) {
                        return [d[0], total[i], 0]
                    });
                    return new_yT;
                }

                //brush object
                var brush = d3.svg.brush()
                    .x(x1)
                    .on("brushstart", brushstart)
                    .on("brush", brushmove)
                    .on("brushend", brushend);

                //brushing
                var h1brush = svgh1.append("g").attr("class", "brush").call(brush);
                h1brush.selectAll("rect")
                    .classed()
                    .style("cursor", "col-resize")
                    .attr("height", height1 + margin.top + margin.bottom);
                h1brush.selectAll(".resize").append("path").attr("d", resizePath);

                //reseizePath
                function resizePath(d) {
                    var e = +(d == "e"),
                        x = e ? 1 : -1,
                        y = height1 / 3;
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

                function brushstart() {
                    svgh1.classed("selecting", true);
                }

                function brushmove() {
                    var s = d3.event.target.extent();
                    bars1.classed("selected", function (d, i) {
                        return s[0] < ((i + 1) * x1.rangeBand()) && i * x1.rangeBand() < s[1];
                    });
                }

                function brushend() {
                    var s = d3.event.target.extent();

                    var selected = x1.domain()
                        .filter(function (d, i) {
                            return (s[0] <= ((i + 1) * x1.rangeBand()) && i * x1.rangeBand() <= s[1])
                        });

                    var originalDomain = x1.domain();
                    //選択範囲のドメインを指定する
                    x1s.domain(d3.event.target.empty() ? originalDomain : selected);

                    //console.log(x1s.domain());
                    var sd = x1s.domain();
                    sd_extent = d3.extent(sd);
                    //ドメインの最大値最小値のインデックスを取得し、オリジナルデータをスライスする。
                    data1_sliced = data1.slice(ys.indexOf(sd_extent[0]), ys.indexOf(sd_extent[1]) + 1);
                    yo_slieced = varNames1.map(function (name) {
                        return {
                            name: name,
                            freq: d3.sum(data1_sliced.map(function (d) {
                                return d[name]
                            })),
                            vis: 1
                        }
                    });
                    var yo10_sliced = Array.prototype.slice.call(yo_slieced, 0, 10)

                    //selectingをはずす
                    svgh1.classed("selecting", !d3.event.target.empty());

                    pie1Update(yo10_sliced);
                }

                var interval_id = setInterval(show_less, 100);

                function show_less(){
                    $("#o10").collapse('hide');
                    var el = document.getElementById('o10');
                    if (el.className == "collapse"){
                        clearInterval(interval_id);
                    }
                }



            });

            $("#o10").on("shown.bs.collapse", function () {$("#toggle_btn").text("show less");});
            $("#o10").on("hidden.bs.collapse", function () {$("#toggle_btn").text("show more");});


        })

    </script>

</static_main>