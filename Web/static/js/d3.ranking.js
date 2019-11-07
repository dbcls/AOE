var clr = ['#DD421D','#E27E1A','#EF9E1D','#AAC40E','#76B711','#088BA0'];

var width=430 , barHeight = 18;

var graph1 = d3.scale.linear()
    .domain([0,d3.max(d_to, function(d_to){return d_to.Value})])
    .range([0, 180]);

var graph2 = d3.scale.linear()
    .domain([0,d3.max(d_at, function(d_to){return d_to.Value})])
    .range([0, 130]);

var barChart1 = d3.select(".bar1")
  .attr("width", width)
  .attr("height",(barHeight + 4) * d_to.length)

var bar1 = barChart1.selectAll("g")
    .data(d_to)
  .enter().append("g")
    .attr("transform", function(d_to, i){return "translate(0," + i*(barHeight + 4) + ")";});

bar1.append("rect")
    .attr("width",function(d_to){return graph1(d_to.Value);})
    .attr("height", barHeight)
    .attr("x", "200px")
    .attr("fill", function(d_to,i){if (clr[i]){return clr[i]}else{return "#777"}});

bar1.append("rect")
    .attr("width", "20px")
    .attr("height", "19px")
    .attr("x", "2px")
    .attr("fill", function(d_to,i){if (clr[i]){return clr[i]}else{return "#777"}});

bar1.append("text")
    .attr("x", "425px")
    .attr("y", barHeight /2 +5)
    .attr("fill", "#052945")
    .text(function(d_to){return d_to.Value;});

bar1.append("text")
    .attr("x", "15px")
    .attr("y", barHeight /2 +5)
    .attr("fill", "#fff")
    .text(function(d_to,i){return i+1});

bar1.append("a")
    .attr("xlink:href",  function(d_to){return "experiments?organism=" + d_to.Name;})
  .append("text")
    .attr("x", "195px")
    .attr("y", barHeight/2 + 5)
    .text(function(d_to){if(d_to.Name.length <= 25){return d_to.Name;} else if (d_to.Name.length > 25){txt = d_to.Name.substr(0,23)+'…';return txt;}});


//.bar2
var barChart2 = d3.select(".bar2")
  .attr("width", width)
  .attr("height",(barHeight + 4) * d_at.length)

var bar2 = barChart2.selectAll("g")
    .data(d_at)
  .enter().append("g")
    .attr("transform", function(d_at, i){return "translate(0," + i*(barHeight + 4) + ")";});

bar2.append("rect")
    .attr("width",function(d_at){return graph2(d_at.Value);})
    .attr("height", barHeight)
    .attr("x", "255px")
    .attr("fill", function(d_at,i){if (clr[i]){return clr[i]}else{return "#777"}});

bar2.append("rect")
    .attr("width", "20px")
    .attr("height", "19px")
    .attr("x", "2px")
    .attr("fill", function(d_at,i){if (clr[i]){return clr[i]}else{return "#777"}});

bar2.append("text")
    .attr("x", "425px")
    .attr("y", barHeight /2 +5)
    .attr("fill", "#052945")
    .text(function(d_at){return d_at.Value;});

bar2.append("text")
    .attr("x", "15px")
    .attr("y", barHeight /2 +5)
    .attr("fill", "#fff")
    .text(function(d_at,i){return i+1});

bar2.append("a")
    .attr("xlink:href",  function(d_at){return "experiments?assay=" + d_at.Name;})
   .append("text")
    .attr("x", "245px")
    .attr("y", barHeight/2 + 5)
    .text(function(d_at){if(d_at.Name.length <= 32){return d_at.Name;} else if (d_at.Name.length > 32){txt = d_at.Name.substr(0,30)+'…';return txt;}});

function updateOrganismData(d){
    switch (d){
        case 0:
            d = d_bm;
            break;
        case 1:
            d = d_to;
            break;
    }
    d3.selectAll(".bar1>g").remove();

var graph1 = d3.scale.linear()
    .domain([0,d3.max(d, function(d){return d.Value})])
    .range([0, 180]);

var barChart1 = d3.select(".bar1")
  .attr("width", width)
  .attr("height",(barHeight + 4) * d.length)

var bar1 = barChart1.selectAll("g")
    .data(d)
  .enter().append("g")
    .attr("transform", function(d, i){return "translate(0," + i*(barHeight + 4) + ")";});

    bar1.append("rect")
            .attr("width",function(d){return graph1(d.Value);})
            .attr("height", barHeight)
            .attr("x", "200px")
            .attr("fill", function(d,i){if (clr[i]){return clr[i]}else{return "#777"}});

    bar1.append("rect")
    .attr("width", "20px")
    .attr("height", "19px")
    .attr("x", "2px")
    .attr("fill", function(d,i){if (clr[i]){return clr[i]}else{return "#777"}});

    bar1.append("text")
    .attr("x", "425px")
    .attr("y", barHeight /2 +5)
    .attr("fill", "#052945")
    .text(function(d){return d.Value;});

    bar1.append("text")
        .attr("x", "15px")
        .attr("y", barHeight /2 +5)
        .attr("fill", "#fff")
        .text(function(d,i){return i+1});

    bar1.append("a")
        .attr("xlink:href",  function(d){return "experiments?organism=" + d.Name;})
      .append("text")
        .attr("x", "195px")
        .attr("y", barHeight/2 + 5)
        .text(function(d){if(d.Name.length <= 25){return d.Name;} else if (d.Name.length > 25){txt = d.Name.substr(0,23)+'…';return txt;}});


}

function updateAssayData(d){
    switch (d){
        case 0:
            d = d_at;
            break;
        case 1:
            d = d_am;
            break;
    }
    d3.selectAll(".bar2>g").remove();

    var graph2 = d3.scale.linear()
        .domain([0,d3.max(d, function(d){return d.Value})])
        .range([0, 130]);

    var barChart2 = d3.select(".bar2")
      .attr("width", width)
      .attr("height",(barHeight + 4) * d.length)

    var bar2 = barChart2.selectAll("g")
        .data(d)
      .enter().append("g")
        .attr("transform", function(d, i){return "translate(0," + i*(barHeight + 4) + ")";});

    bar2.append("rect")
            .attr("width",function(d){return graph2(d.Value);})
            .attr("height", barHeight)
            .attr("x", "255px")
            .attr("fill", function(d,i){if (clr[i]){return clr[i]}else{return "#777"}});

    bar2.append("rect")
            .attr("width", "20px")
            .attr("height", "19px")
            .attr("x", "2px")
            .attr("fill", function(d,i){if (clr[i]){return clr[i]}else{return "#777"}});

    bar2.append("text")
            .attr("x", "425px")
            .attr("y", barHeight /2 +5)
            .attr("fill", "#052945")
            .text(function(d){return d.Value;});

    bar2.append("text")
        .attr("x", "15px")
        .attr("y", barHeight /2 +5)
        .attr("fill", "#fff")
        .text(function(d,i){return i+1});

    bar2.append("a")
        .attr("xlink:href",  function(d){return "experiments?assay=" + d.Name;})
      .append("text")
        .attr("x", "245px")
        .attr("y", barHeight/2 + 5)
        .text(function(d){if(d.Name.length <= 32){return d.Name;} else if (d.Name.length > 32){txt = d.Name.substr(0,30)+'…';return txt;}});



}