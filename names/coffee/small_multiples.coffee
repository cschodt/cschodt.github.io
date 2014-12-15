
# ---
# We are using a function to scope
# the creation of this chart.
# Check out http://bost.ocks.org/mike/chart/
# for the details and benefits
# ---
SmallMultiples = () ->
  # variables accessible to
  # the rest of the functions inside SmallMultiples
  width = 240
  height = 140
  margin = {top: 15, right: 10, bottom: 40, left: 23}
  data = []

  # these will be set to d3 selections later
  circle = null
  caption = null
  curYear = null

  # d3.bisector creates a bisect function that
  # can be used to search an array for a specific
  # value. We will use it later in mouseover.
  bisect = d3.bisector((d) -> d.date).left
  format = d3.time.format("%Y")

  xScale = d3.time.scale().range([0,width])
  yScale = d3.scale.linear().range([height,0])

  # These accessor functions are defined to
  # indicate the data attributes used for the
  # x and y values. This makes it easier to
  # swap in your own data!
  # DATA COMES FROM THE D3.NEST CONVERSION BELOW, WHICH ALSO PARSES YEAR INTO A DATE
  # WE'RE PLOTTING GENDERINDEX ON Y AXISg
  xValue = (d) -> d.date
  yValue = (d) -> d.genderindex

  # The large tickSize is used
  # to paint lines across the plots
  # CHANGED NUMBER OF TICKS TO 3 SO WE MARK 0.5 ONLY
  yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left").ticks(3)
    .outerTickSize(0)
    .tickSubdivide(1)
    .tickSize(-width)

  area = d3.svg.area()
    .x((d) -> xScale(xValue(d)))
    .y0(height)
    .y1((d) -> yScale(yValue(d)))

  line = d3.svg.line()
    .x((d) -> xScale(xValue(d)))
    .y((d) -> yScale(yValue(d)))

  # ---
  # Sets the domain for our x and y scales.
  # We want all the small multiples to have the
  # same domains, so we only have to do this once.
  # ---
  # CHANGED THE YSCALE PART BECAUSE WE KNOW OUR GENDERINDEX DATA GOES FROM 0 TO 1
  # SO WE DON'T NEED TO SET DOMAIN FROM MAXIMUM VALUE. ALSO WE WANT TO CHART TO STOP AT 1
  setupScales = (data) ->
    yScale.domain([0,1])
    extentX = d3.extent(data[0].values, (d) -> xValue(d))
    xScale.domain(extentX)

  # ---
  # Creates new chart function. This is the 'constructor' of our
  # visualization. Again, this is based on
  # Bostock's Reusable Chart paradigm.
  # ---
  chart = (selection) ->
    selection.each (rawData) ->
      # Set local variable for input data.
      # Transformation of this data has already
      # been done by the time it reaches chart.
      data = rawData

      setupScales(data)

      # Create a div and an SVG element for each element in
      # our data array. Note that data is a nested array
      # with each element containing another array of 'values'
      div = d3.select(this).selectAll(".chart").data(data)
      sv = div.enter().append("div").attr("class", "chart")
        .append("svg")
        
      def = sv.append("defs")
        .append("linearGradient")
        .attr("id", "gradient1")
        .attr("x1", "0")
        .attr("x2", "0")
        .attr("y1", "0")
        .attr("y2", "1")

# CHANGED THIS TO GO FROM PINK TO BLUE
      def.append("stop")
        .attr("offset", "0%")
        .attr("stop-color", "#ff99ff")
        .attr("stop-opacity", ".4")

      def.append("stop")
        .attr("offset", "30%")
        .attr("stop-color", "#ccc")
        .attr("stop-opacity", ".4")

      def.append("stop")
        .attr("offset", "50%")
        .attr("stop-color", "#ccc")
        .attr("stop-opacity", ".2")
        
      def.append("stop")
        .attr("offset", "70%")
        .attr("stop-color", "#ccc")
        .attr("stop-opacity", ".4")

      def.append("stop")
        .attr("offset", "100%")
        .attr("stop-color", "#0099ff")
        .attr("stop-opacity", ".4")

      sv.append("g")

      svg = div.select("svg")
        .attr("width", width + margin.left + margin.right )
        .attr("height", height + margin.top + margin.bottom )

      # Margins give space for the axis and text labels
      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")
     
      # Invisible background rectangle that will
      # capture all our mouse movements
      g.append("rect")
        .attr("class", "background")
        .style("pointer-events", "all")
        .attr("width", width + margin.right )
        .attr("height", height)
# COMMENTED OUT FROM HERE ON BECAUSE I'VE ALSO COMMENTED OUT THE MOUSEOVER/MOVE/OUT INTERACTIVITY
#         .on("mouseover", mouseover)
#         .on("mousemove", mousemove)
#         .on("mouseout", mouseout)



      # Because we bound our nested array to
      # a 'selectAll' of SVG elements, each
      # svg element will be one of the nested
      # elements from that array. This means
      # each svg has its own key and its own
      # values array. Here, we use values to
      # draw our paths.
      lines = g.append("g")
      lines.append("path")
        .attr("class", "area")
        .style("pointer-events", "none")
        .attr("fill", "url(#gradient1)")
        .attr("d", (c) -> area(c.values))


      
      lines.append("path")
        .attr("class", "line")
        .style("pointer-events", "none")
        .attr("d", (c) -> line(c.values))


      lines.append("text")
        .attr("class", "title")
        .attr("text-anchor", "middle")
        .attr("y", height)
        .attr("dy", margin.bottom / 2 + 5)
        .attr("x", width / 2)
        .text((c) -> c.key)

# THESE NEXT TWO CODE BLOCKS SET UP THE TEXT LABELS FOR THE START AND END YEARS
# CHANGED TO JUST USE 1880 AND 2013, RATHER THAN CALCULATING FROM THE DATA 
# THE LATTER CAUSES PROBLEMS FOR NAMES THAT DON'T COVER THE FULL YEAR RANGE
      lines.append("text")
        .attr("class", "static_year")
        .attr("text-anchor", "start")
        .style("pointer-events", "none")
        .attr("dy", 13)
        .attr("y", height)
        .attr("x", 0)
        .text("1880")
#         .text((c) -> xValue(c.values[0]).getFullYear())

      lines.append("text")
        .attr("class", "static_year")
        .attr("text-anchor", "end")
        .style("pointer-events", "none")
        .attr("dy", 13)
        .attr("y", height)
        .attr("x", width)
        .text("2013")
#         .text((c) -> xValue(c.values[c.values.length - 1]).getFullYear())


# COMMENTED ALL OF THIS NEXT SECTION OUT TO REMOVE THE SCRUBBABLE DATA DISPLAY
# THERE'S QUITE A BIT OF WORK TO BE DONE TO MAKE THIS WORK PROPERLY FOR OUR DATA
# A PROJECT FOR YOU IF YOU ARE INTERESTED
      # Add a circle and caption to fill in
      # during mousemove
#       circle = lines.append("circle")
#         .attr("r", 2.2)
#         .attr("opacity", 0)
#         .style("pointer-events", "none")
# 
#       caption = lines.append("text")
#         .attr("class", "caption")
#         .attr("text-anchor", "middle")
#         .style("pointer-events", "none")
#         .attr("dy", -8)
# 
#       curYear = lines.append("text")
#         .attr("class", "year")
#         .attr("text-anchor", "middle")
#         .style("pointer-events", "none")
#         .attr("dy", 13)
#         .attr("y", height)

      # Add axis last so the tick lines
      # show over the paths (Upshot style).
      g.append("g")
        .attr("class", "y axis")
        .call(yAxis)

# COMMENTED OUT ALL THE INTERACTION CODE FOR MOUSEOVER/MOVE/OUT
  # ---
  # Called when viewer first starts to interact with
  # one of the plots. Ensure the circle is visible and the
  # the year labels are not.
  # ---
#   mouseover = () ->
#     circle.attr("opacity", 1.0)
#     d3.selectAll(".static_year").classed("hidden", true)
#     mousemove.call(this)

  # ---
  # Here is where the bulk of the interaction code lives.
  # When mouse moves, we want to grab the current year
  # the mouse is over. Then we want to pull out that
  # year's count from each of the data element's values.
  # ---
#   mousemove = () ->
#     year = xScale.invert(d3.mouse(this)[0]).getFullYear()
#     date = format.parse('' + year)
#     
#     # The index into values will be the same for all
#     # of the plots, so we can compute it once and
#     # use it for the rest of the scrollables
#     index = 0
#     circle.attr("cx", xScale(date))
#       .attr "cy", (c) ->
#         index = bisect(c.values, date, 0, c.values.length - 1)
#         yScale(yValue(c.values[index]))
# 
#     caption.attr("x", xScale(date))
#       .attr "y", (c) ->
#         yScale(yValue(c.values[index]))
#       .text (c) ->
#         yValue(c.values[index])
# 
#     curYear.attr("x", xScale(date))
#       .text(year)

  # ---
  # When viewer moves mouse out of plot, hide
  # circle and annotations while showing
  # the x axis labels
  # ---
#   mouseout = () ->
#     d3.selectAll(".static_year").classed("hidden", false)
#     circle.attr("opacity", 0)
#     caption.text("")
#     curYear.text("")


  # ---
  # If you wanted to use different
  # data in this visual, you could
  # pass in the xValue accessor function
  # using the x() getter/setter for
  # an instance of SmallMultiples.
  # ---
#   chart.x = (_) ->
#     if !arguments.length
#       return xValue
#     xValue = _
#     chart

  # ---
  # And the yValue using this
  # getter/setter.
  # ---
#   chart.y = (_) ->
#     if !arguments.length
#       return yValue
#     yValue = _
#     chart

  # final act of our wrapper function is to
  # return the internal chart function we have created
  return chart

# ---
# Convert the raw input data into the format
# that our visualization expects.
# ---
# ALSO PARSES YEAR INTO A DATE
# WE MAKE THE KEY FIRSTNAME AND SUBSTITUTE GENDERINDEX WHERE APPROPRIATE

transformData = (rawData) ->
  format = d3.time.format("%Y")
  rawData.forEach (d) ->
    d.date = format.parse(d.year)
    d.genderindex = +d.genderindex
  nest = d3.nest()
    .key((d) -> d.firstname)
    .sortValues((a,b) -> d3.ascending(a.date, b.date))
    .entries(rawData)
  nest

# ---
# Helper function that simplifies the calling
# of our chart with it's data and div selector
# specified
# ---
plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

# ---
# Isotype is used as a fun and easy way to
# implement reordering of the div's based
# on different sort orders.
# CHANGED SO WE SORT THE DATA ON THE NAMES' RANK WITHIN THE TOP 100
# ---
setupIsoytpe = () ->
  $("#vis").isotope({
    itemSelector: '.chart',
    layoutMode: 'fitRows',
    getSortData: {
      count: (e) ->
        d = d3.select(e).datum()
        sum = d3.sum(d.values, (d) -> d.rank)
      name: (e) ->
        d = d3.select(e).datum()
        d.key
    }
  })

  $("#vis").isotope({sortBy:'count'})

# ---
# jQuery document ready.
# ---
$ ->

  plot = SmallMultiples()

  # ---
  # This function is called when
  # the data has been successfully loaded
  # and we can start visualizing!!
  # ---
  display = (error, rawData) ->
    if error
      console.log(error)

    data = transformData(rawData)
    plotData("#vis", data, plot)
    setupIsoytpe()

  # I've started using Bostock's queue to load data.
  # The tool allows you to easily add more input files
  # if you need to (for this example it might be overkill or
  # inefficient, but its good to know about).
  # https://github.com/mbostock/queue
  # CHANGED TO LOAD OUR DATA
  queue()
    .defer(d3.csv, "data/names_100.csv")
    .await(display)

  d3.select("#button-wrap").selectAll("div").on "click", () ->
    id = d3.select(this).attr("id")
    d3.select("#button-wrap").selectAll("div").classed("active", false)
    d3.select("##{id}").classed("active", true)
    $("#vis").isotope({sortBy:id})


