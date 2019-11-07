//script for assay ranking & charts
$(function() {
 var margin_a= {top: 30, right:10, bottom: 40, left:55},
     padding_a = {top: 10, right: 10, bottom: 30, left: 40},
     width_a1 = 430, height_a1 = 220,width_a2 = 330, height_a2 = 220;
    //手法のソート用配列
    var aorder = ["Affymetrix","Agilent","Others_Array","Illumina","Others_NGS"]
    //fill colorの設定
    var acolors = {"Affymetrix":"#488EC4","Agilent":"#83B9DD","Others_Array":"#C1DAE8","Illumina":"#E57E76","Others_NGS":"#F4B8B5","B":"#F4B8B5","54":"#F4B8B5","on":"#F4B8B5","acBio":"#F4B8B5"};

    //svg g conainer for bar chart assay/y
    var svga1 = d3.select("#histogram_assay_1").append("svg").attr("class", "chart")
                    .attr("width", width_a1 )
                    .attr("height", height_a1 + margin_a.top + margin_a.bottom)
                    .append("g")
                    .attr("transform", "translate(" + margin_a.left + "," + margin.top + ")");
    var svga2 = d3.select("#histogram_assay_2").append("svg").attr("class", "chart")
                    .attr("width", width_a1 )
                    .attr("height", height_a2 + margin_a.top + (margin_a.bottom * 3))
                    .append("g")
                    .attr("transform", "translate(" + margin_a.left + "," + margin.top + ")");
    var svga3 = d3.select("#ranking_assay").append("svg").attr("class", "ranking")
                    .attr("width", width_a1 / 2 )
                    .attr("height", height_a1 + margin_a.top + margin_a.bottom)
                    .append("g")
                    .attr("transform", "translate(" + (margin_a.left * 2 ) +"," + margin.top + ")");

    var svga1lg = d3.select("#histogram_assay_1").append("svg").attr("class", "ranking")
                    .attr("width", width_a1 )
                    .attr("height", 150)
                    .append("g")
                    .attr("transform", "translate(" + margin_a.left + ",5)");

    //検索ボタンを配置するsvg要素を作成
    var svgas = d3.select("#sub-header2 .info").append("svg")
                .attr("width", 225)
                .attr("height", 40);

    //データセットの読み込み
    var data_a1 = [];
    var data_a2 = [];
    d3.csv("../uploads/assay_monthly_old_ver.csv", function(error,data) {
        data_a1 = data;
        d3.csv("../uploads/assay_organism.csv",function(error,data){
            data_a2 = data;
            drawChart();
        });
    });
    function drawChart() {
        //生物種名の配列を取得
        var aorgs = d3.keys(data_a1[0])
            .filter(function (key) {
                return key !== 'assay' && key !== "year";
            });
        //登録年バリエーションを配列として取得
        var ayears = data_a1.map(function (d) {
            return d.year
        });

        ayears = $.unique(ayears);

        //year-assay-total
        var ay = data_a1.map(function (d) {
            return{year: d.year,
                assay: d.assay,
                total: d3.sum(aorgs.map(function (v) {
                    return d[v]
                }))//生物ごとの登録データの配列を作り合算

            }
        });
        //年ごとのassay:value
        //assaysの値を年ごとにまとめる-チャートに反映
        var aay = d3.nest().key(function (d) {
            return d.year
        }).entries(ay);
        var aaay = d3.nest().key(function (d) {
            return d.assay
        }).entries(ay);
        //手法ごとの登録数の合計を取得-ランキングに反映
        aaay.forEach(function (d) {
            d.total = d3.sum((d.values).map(function (d) {
                return d.total
            }));
            d.vis = 1;
        });
        //aayにstackしたy軸の値を追加
        aay.forEach(function (d) {
            var ya0 = 0;
            var ya1 = 0;
            d.total = d3.sum(d.values.map(function (d) {
                return d.total
            }));//年ごとの登録数の合計
            d.values.forEach(function (d) {
                //y0: y axis start of the bar
                d.ya0 = ya0;
                d.ya1 = ya1 = ya0 + +d.total;
                ya0 = ya1;
            });
        });

        //生物種-手法ごとの登録数
        var ao = data_a2.map(function (d,i) {
            return {
                organism: d.organism,
                assay: d.assay,
                total: d3.sum(ayears.map(function(v){return d[v]}))
            };
        });
        var aoo = d3.nest().key(function(d){
            return d.organism
        }).entries(ao);
        //手法ごとの値を合算し生物ごとの登録数を取得
        aoo.forEach(function(d){
            d.total = d3.sum(d.values.map(function(v){
                return v.total
            }))
        });

        //登録データ件数順にハッシュをソート
        aoo.sort(function(a,b){return (a.total > b.total)? -1:1});
        //初期設定の生物種とランキングをaorderにマップ
        var oorder = aoo.map(function(d,i){return {org:d.key, order:i}});

        //トップ10の生物種名を配列で取得
        var aorgs = aoo.map(function(d){return d.key});

        //スケールの設定
        var a_x1 = d3.scale.ordinal().rangeBands([0, width_a1 - margin_a.left - margin_a.right])
            .domain(ayears);
        var a_y1 = d3.scale.linear().range([height_a1, 0])
            .domain([0, d3.max(aay, function (d) {
                return d.total
            })]);
        var a_x2 = d3.scale.ordinal().rangeBands([0, width_a2 - margin_a.left - margin_a.right])
            .domain(aorgs);
        var a_y2 = d3.scale.linear().range([height_a2, 0])
            .domain([0, d3.max(aoo, function (d) {
                return d.total
            })]);
        //axis
        var a1_yAxis = d3.svg.axis().scale(a_y1).orient("left").tickFormat(d3.format("d"));
        var a1_xAxis = d3.svg.axis().scale(a_x1).orient("bottom");
        var a2_yAxis = d3.svg.axis().scale(a_y2).orient("left").tickFormat(d3.format("d"));
        var a2_xAxis = d3.svg.axis().scale(a_x2).orient("bottom");

        //選択された生物種名
        sassay = [];

        //brush
        var a1_brush = d3.svg.brush().x(a_x1);

        //add x axis
        svga1.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + ( height_a1 + 5) + ")")
            .call(a1_xAxis).selectAll("text")
            .attr("transform", function (d) {
                return "rotate(45)"
            }).style("text-anchor", "start");
        svga2.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(5," + ( height_a2 + 5) + ")")
            .call(a2_xAxis).selectAll("text")
            .attr("transform", function (d) {
                return "rotate(45)"
            }).style("text-anchor", "start");

        //add y axis
        svga1.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(0,0)")
            .call(a1_yAxis)
            .append("text")
            .attr("transform", "translate(-90)")
            .attr("y", 6)
            .style("text-anchor", "end")
            .text("データ登録数")
            .attr("transform", "rotate(-90,2,-5)")
            .attr("class", "y_label");

        svga2.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(-10,0)")
            .call(a2_yAxis)
            .append("text")
            .attr("transform", "translate(-90)")
            .attr("y", 6)
            .style("text-anchor", "end")
            .text("データ登録数")
            .attr("transform", "rotate(-90,2,-5)")
            .attr("class", "y_label");
        //add brush


        //barを追加
        var a1_bar = svga1.selectAll(".bars")
            .data(aay);
        a1_bar.enter().append("g").classed("bars", true);

        var a2_bar = svga2.selectAll(".bars")
            .data(aoo)
            .enter().append("g")
            .attr("class", "bars");

        var a1_mybar = a1_bar.selectAll("rect")
            .data(function (d) {return d.values;});
        a1_mybar.enter().append("rect")
            .attr("width", function (d) {
                return width_a1 / (1.5 * ayears.length )
            })
            .attr("x", function (d) {
                return a_x1(d.year)
            })
            .attr("y", function (d) {
                return a_y1(d.ya1)
            })
            .attr("fill", function (d) {
                return acolors[d.assay]
            })
            .attr("height", function (d) {
                return a_y1(d.ya0) - a_y1(d.ya1)
            })
            .on("click", function (d) {
                console.log("assay: " + d.assay + "year: " + d.year)
            });

        a1_bar.append("text").text(function(d){return d3.format(",")(d.total)})
            .attr("x", function(d){return a_x1(d.key) + 10} )
            .attr("y", function(d){return a_y1(d.total) - 5})
            .attr("text-anchor", "middle");

        var a2_barval = a2_bar.append("text");
        a2_barval.text(function(d){return d3.format(",")(d.total)})
            .attr("x", function(d){return a_x2(d.key) + 17} )
            .attr("y", function(d){return a_y2(+d.total) - 5})
            .attr("text-anchor", "middle");

        a2_bar.append("rect")
            .attr("width", function (d) {
                return width_a2 / (1.5 * aorgs.length )
            })
            .attr("x", function (d) {
                return a_x2(d.key)
            })
            .attr("y", function (d) {
                return a_y2(+d.total)
            })
            .attr("fill", barColor)
            .attr("height", function (d) {
                return height_a2 - a_y2(d.total)
            })
            .attr("transform", "translate(5,0)");

        //add legend
        var a1_legend_a = svga1lg.append("g");
        var a1_legend_n = svga1lg.append("g");

        lg_a = a1_legend_a.selectAll("rect")
            .data(aorder.filter(function (d, i) {
                return i < 3
            }))
            .enter().append("rect")
            .attr("width", 20)
            .attr("height", 20)
            .attr("x", 0)
            .attr("y", function (d, i) {
                return i * 25
            })
            .attr("fill", function (d) {
                return acolors[d]
            });

        lg_n = a1_legend_n.selectAll("rect")
            .data(aorder.filter(function (d, i) {
                return i > 2
            }))
            .enter().append("rect")
            .attr("width", 20)
            .attr("height", 20)
            .attr("x", 140)
            .attr("y", function (d, i) {
                return i * 25
            })
            .attr("fill", function (d) {
                return acolors[d]
            });

        a1_legend_a.selectAll("text")
            .data(aorder.filter(function (d, i) {
                return i < 3
            })).enter().append("text")
            .text(function (d) {
                return d
            })
            .attr("x", 35)
            .attr("y", function (d, i) {
                return (i * 25) + 15
            })
            .attr("font-size", 12);

        a1_legend_n.selectAll("text")
            .data(aorder.filter(function (d, i) {
                return i > 2
            })).enter().append("text")
            .text(function (d) {
                return d
            })
            .attr("x", 170)
            .attr("y", function (d, i) {
                return (i * 25) + 15
            })
            .attr("font-size", 12);

        //ranking
        var a3_ranking = svga3.append("g").selectAll(".btns")
            .data((aaay.sort(function (a, b) {
                return +a.total - +b.total
            })).reverse())
            .enter().append("g")
            .attr("class", "btns")
            .attr("transform", "translate(-105, -10)");

        a3_ranking.append("rect")
            .attr("x", 0)
            .attr("y", function (d, i) {
                return i * 30
            })
            .attr("width", 30)
            .attr("height", 18)
            .attr("rx", 3)
            .attr("ry", 3)
            .attr("stroke", function (d) {
                return acolors[d.key]
            })
            .attr("fill", function (d) {
                if (d.vis == "1") {
                    return acolors[d.key];
                } else {return "white"}})
            .on("click", function (d) {
                var a;
                if (d.vis == 1) { //選択されていない
                    d.vis = 0
                } else {
                    d.vis = 1;
                }
                a3_ranking.select("rect").transition().duration(200)
                    .attr("fill", function (d) {
                        checkvis();
                        //a = d.vis;
                        if (d.vis == 0) {return acolors[d.key];} else {return "white"};
                    });
                updateAChart();
            });

        a3_ranking.append("text")
            .text(function (d, i) {
                return i + 1
            })
            .attr("x", 11)
            .attr("y", function (d, i) {
                return (i * 30) + 13
            })
            .style("font-size", "12")
            .attr("fill", "#fdfdfd")
            .on("click", function (d) {
                var a;
                if (d.vis == 1) {
                    d.vis = 0
                } else {
                    d.vis = 1;
                }
                a3_ranking.select("rect").transition().duration(200)
                    .attr("fill", function (d) {
                        checkvis();
                        //a = d.vis;
                        if (d.vis == 0) {return acolors[d.key];} else {return "white"};
                    });
                updateAChart();
            });

        a3_ranking.append("text")
            .text(function (d) {
                return d.key
            })
            .style("font-size", "12")
            .attr("x", 50)
            .attr("y", function (d, i) {
                return (i * 30) + 12
            })
            .on("click", function (d) {
                var a;
                if (d.vis == 1) {
                    d.vis = 0
                } else {
                    d.vis = 1;
                }
                a3_ranking.select("rect").transition().duration(200)
                    .attr("fill", function (d) {
                        checkvis();
                        //a = d.vis;
                        if (d.vis == 0) {return acolors[d.key];} else {return "white"};
                    });
                console.log("text2")
                updateAChart();
            });

        a3_ranking.append("text")
            .text(function (d) {
                return d3.format(",")(d.total)
            })
            .attr("x", 185)
            .attr("y", function (d, i) {
                return (i * 30) + 12
            })
            .style("font-size", "12")
            .style("text-anchor", "end")
            .on("click", function (d) {
                var a;
                if (d.vis == 1) {
                    d.vis = 0
                } else {
                    d.vis = 1;
                }
                a3_ranking.select("rect").transition().duration(200)
                    .attr("fill", function (d) {
                        checkvis();
                        //a = d.vis;
                        if (d.vis == 0) {return acolors[d.key];} else {return "white"};
                    });
                console.log("text3");
                updateAChart();
            });

        //検索リンク作成
        var sbmt_a = svgas.append("a")
            .attr("xlink:href",function(){
                return url_mylist
            })
            .attr("transform","translate(5, 5)");

        //検索ボタン作成
        var sbtn_a = sbmt_a.append("rect")
            .attr("width", 220)
            .attr("height", 28)
            .attr("rx", 3)
            .attr("ry", 3)
            .attr("stroke", "#024b96")
            .attr("fill", "#024b96")
            .on("mouseover", function(){
                sbtn_a.attr("fill", "#012d5a");
                sbmt_a.attr("xlink:href", function(){
                        return url_mylist + "?assay=" + sassay;
                })
            })
            .on("mouseout", function(){
                sbtn_a.attr("fill", "#024b96")
            })
            .on("click", function(){
                sbtn_a.attr("fill", "#024b96")
            });

        sbmt_a.append("text")
            .text(txt_a1)
            .attr("fill", "white")
            .attr("z-index","10")
            .attr("font-size", "12px")
            .attr("transform", "translate(" + padding_sbtn + ",18)");


        //手法別チャートを再描画
        function updateAChart() {
            var selected = selectedAssayIs().map(function(d){return d.key});
            sassay = selected;
            ay_r = ay.filter(function(d){ if(selected.indexOf(d.assay) > -1){return true;}});

            //aayに手法をフィルターしたvlues, totalを再設定
            aay = d3.nest().key(function(d){return d.year}).entries(ay_r);
            //aayにtotal値とya0, ya1を追加
            aay.forEach(function (d) {
                var ya0 = 0;
                var ya1 = 0;
                d.total = d3.sum((d.values).map(function (d) {
                    return d.total
                }));//年ごとの登録数の合計
                d.values.forEach(function (d) {
                    //y0: y axis start of the bar
                    d.ya0 = ya0;
                    d.ya1 = ya1 = ya0 + +d.total;
                    ya0 = ya1;
                });
            });


            //aaoに手法をフィルターしたvalues, totalを再設定
            ao_r = ao.filter(function(d){if (selected.indexOf(d.assay) > -1){return true}});
            aoo = d3.nest().key(function(d){return d.organism}).entries(ao_r);
            //aooはkeyの文字列で昇順にソートされているので、フィルター前のランキング順にソート
            aoo.forEach(function(d,i){
                //aooの"key"とoorderの"orgs"が一致するoorderの"order"の値を取得しidの値に
                d.id = (oorder.filter(function(v){return v.org == d.key}))[0].order
            });
            aoo.sort(function(a,b){return (a.id < b.id)? -1:1})
            aoo.forEach(function(d){
                d.total = d3.sum(d.values.map(function(v){return +v.total}))
            });

            ////生物種ごとの登録数チャートを更新
            //aorgs = aoo.map(function(d){return d.key})
            a_y2.domain([0, d3.max(aoo, function(d){return +d.total})]);
            //a_x2.domain(aorgs);
            svga2.select(".y.axis").transition().duration(300).call(a2_yAxis);

            ////手法ごとの年間登録数チャートを更新
            //aayのtotal max値をドメインの最大側に設定
            a_y1.domain([0, d3.max(aay, function(d){return d.total})]);
            svga1.select(".y.axis").transition().duration(300).call(a1_yAxis);

            a2_bar = svga2.selectAll(".bars").data(aoo);
            a2_bar.select("rect").transition().duration(300)
                .attr("width", function (d) {return width_a2 / (1.5 * aorgs.length )})
                .attr("x", function (d) { return a_x2(d.key)})
                .attr("y", function (d) { return a_y2(d.total)})
                .attr("fill", barColor)
                .attr("height", function (d) { return height_a2 - a_y2(d.total)})
                .attr("transform", "translate(5,0)");

            //g.barsを削除
            svga1.selectAll(".bars").remove()

            //g.barsとrectを再描画
            a1_bar = svga1.selectAll(".bars").data(aay);
            a1_bar.enter().append("g").classed("bars", true);

            a1_mybar = a1_bar.selectAll("rect").data(function (d) {return d.values;});
            a1_mybar.enter().append("rect").attr("width", function (d) {
                    return width_a1 / (1.5 * ayears.length )
                })
                .attr("x", function (d) {
                    return a_x1(d.year)
                })
                .attr("y", function (d) {
                    return a_y1(d.ya1)
                })
                .attr("fill", function (d) {
                    return acolors[d.assay]
                })
                .attr("height", function (d) {
                    return a_y1(d.ya0) - a_y1(d.ya1)
                })
                .attr("opacity",0).transition().duration(300).attr("opacity",1);

            a1_bar.append("text").text(function(d){return d3.format(",")(d.total)})
                .attr("x", function(d){return a_x1(d.key) + 10} )
                .attr("y", function(d){return a_y1(d.total) - 5})
                .attr("text-anchor", "middle");

            a2_barval = a2_bar.select("text").transition().duration(300);
            a2_barval.text(function(d){return d3.format(",")(d.total)})
                .attr("x", function(d){return a_x2(d.key) + 17} )
                .attr("y", function(d){return a_y2(d.total) - 5})
                .attr("text-anchor", "middle");

        }

        //ランキング表で選択された手法の配列を返す
        function selectedAssayIs(){
            var selectedAS = aaay.filter(function(d){if((d.vis) == 0){return true}});
            return  selectedAS;
        }


        //すべての手法が非選択になったら、自動的に全てvis = 0に再設定する
        function checkvis() {
            ss = d3.sum(aaay, function (d) {
                return d.vis
            });
            if (ss == aaay.length) {
                for (k in aaay) {
                    aaay[k][vis] = 0
                }
            }
        }

    }

    //})

});

