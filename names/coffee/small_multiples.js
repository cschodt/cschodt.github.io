var SmallMultiples, plotData, setupIsoytpe, transformData;

SmallMultiples = function() {
  var area, bisect, caption, chart, circle, curYear, data, format, height, line, margin, setupScales, width, xScale, xValue, yAxis, yScale, yValue;
  width = 150;
  height = 120;
  margin = {
    top: 15,
    right: 10,
    bottom: 40,
    left: 35
  };
  data = [];
  circle = null;
  caption = null;
  curYear = null;
  bisect = d3.bisector(function(d) {
    return d.date;
  }).left;
  format = d3.time.format("%Y");
  xScale = d3.time.scale().range([0, width]);
  yScale = d3.scale.linear().range([height, 0]);
  xValue = function(d) {
    return d.date;
  };
  yValue = function(d) {
    return d.genderindex;
  };
  yAxis = d3.svg.axis().scale(yScale).orient("left").ticks(3).outerTickSize(0).tickSubdivide(1).tickSize(-width);
  area = d3.svg.area().x(function(d) {
    return xScale(xValue(d));
  }).y0(height).y1(function(d) {
    return yScale(yValue(d));
  });
  line = d3.svg.line().x(function(d) {
    return xScale(xValue(d));
  }).y(function(d) {
    return yScale(yValue(d));
  });
  setupScales = function(data) {
    var extentX;
    yScale.domain([0, 1]);
    extentX = d3.extent(data[0].values, function(d) {
      return xValue(d);
    });
    return xScale.domain(extentX);
  };
  chart = function(selection) {
    return selection.each(function(rawData) {
      var div, g, lines, svg;
      data = rawData;
      setupScales(data);
      div = d3.select(this).selectAll(".chart").data(data);
      div.enter().append("div").attr("class", "chart").append("svg").append("g");
      svg = div.select("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom);
      g = svg.select("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
      g.append("rect").attr("class", "background").style("pointer-events", "all").attr("width", width + margin.right).attr("height", height);
      lines = g.append("g");
      lines.append("path").attr("class", "area").style("pointer-events", "none").attr("d", function(c) {
        return area(c.values);
      });
      lines.append("path").attr("class", "line").style("pointer-events", "none").attr("d", function(c) {
        return line(c.values);
      });
      lines.append("text").attr("class", "title").attr("text-anchor", "middle").attr("y", height).attr("dy", margin.bottom / 2 + 5).attr("x", width / 2).text(function(c) {
        return c.key;
      });
      lines.append("text").attr("class", "static_year").attr("text-anchor", "start").style("pointer-events", "none").attr("dy", 13).attr("y", height).attr("x", 0).text("1880");
      lines.append("text").attr("class", "static_year").attr("text-anchor", "end").style("pointer-events", "none").attr("dy", 13).attr("y", height).attr("x", width).text("2013");
      return g.append("g").attr("class", "y axis").call(yAxis);
    });
  };
  return chart;
};

transformData = function(rawData) {
  var format, nest;
  format = d3.time.format("%Y");
  rawData.forEach(function(d) {
    d.date = format.parse(d.year);
    return d.genderindex = +d.genderindex;
  });
  nest = d3.nest().key(function(d) {
    return d.firstname;
  }).sortValues(function(a, b) {
    return d3.ascending(a.date, b.date);
  }).entries(rawData);
  return nest;
};

plotData = function(selector, data, plot) {
  return d3.select(selector).datum(data).call(plot);
};

setupIsoytpe = function() {
  $("#vis").isotope({
    itemSelector: '.chart',
    layoutMode: 'fitRows',
    getSortData: {
      count: function(e) {
        var d, sum;
        d = d3.select(e).datum();
        return sum = d3.sum(d.values, function(d) {
          return d.rank;
        });
      },
      name: function(e) {
        var d;
        d = d3.select(e).datum();
        return d.key;
      }
    }
  });
  return $("#vis").isotope({
    sortBy: 'count'
  });
};

$(function() {
  var display, plot;
  plot = SmallMultiples();
  display = function(error, rawData) {
    var data;
    if (error) {
      console.log(error);
    }
    data = transformData(rawData);
    plotData("#vis", data, plot);
    return setupIsoytpe();
  };
  queue().defer(d3.csv, "data/names_100.csv").await(display);
  return d3.select("#button-wrap").selectAll("div").on("click", function() {
    var id;
    id = d3.select(this).attr("id");
    d3.select("#button-wrap").selectAll("div").classed("active", false);
    d3.select("#" + id).classed("active", true);
    return $("#vis").isotope({
      sortBy: id
    });
  });
});
