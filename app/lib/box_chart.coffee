
class boxChart

  # conventions:
  #  throughout the code c stands for configuration
  
  constructor: (vis_id) -> 
    @vis_id = vis_id
    @min = Infinity
    @max = -Infinity


  draw: (chart) ->
    self = @
    d3.csv("../data/life_expectancy_2010.csv", (csv) ->
      self.data = []
      data_child = []  # initial assumption: only 1 data group
      csv.forEach( (y) ->
        d = y.val
        if d != ""
          data_child.push(d)
          if (d > self.max) then self.max = d
          if (d < self.min) then self.min = d
      )
      self.data.push(data_child)
      
      self.svg = d3.select("##{self.vis_id}").selectAll("svg")
        .data(self.data)
      .enter().append("svg")
        .attr("class", "box")
        .attr("width", 
          self.c.width + self.c.margin.left + self.c.margin.right)
        .attr("height", 
          self.c.height + self.c.margin.bottom + self.c.margin.top)
      self.svg.append("g")
        .attr("transform", 
          "translate(#{self.c.margin.left}, #{self.c.margin.top})")
        .call(chart)
        
      
    )
    

  init: (conf) ->
    self = @
    c =
      margin: top: 10, right: 30, bottom: 20, left: 30
      axis: yes
      sub_ticks: no
    c.height = 500 - c.margin.top - c.margin.bottom
    c.width = 100 - c.margin.left - c.margin.right
    @c = $.extend(yes, c, conf)
    #console.log @c
 
    
    box = (g) ->
    
      # Compute the new y-scale.
      self.y1 = d3.scale.linear()
        # range inverted because svg y positions are counted from top to bottom
        .domain([self.min, self.max])  # input
        .range([self.c.height, 0])     # output 
      
      # Retrieve the old y-scale, if this is an update.
      self.y0 = self.__chart__ || d3.scale.linear()
        # input inverted because svg y positions are counted from top to bottom
        .domain([0, Infinity])  # input
        .range(self.y1.range())     # output 
      
      # Stash the new scale.
      self.__chart__ = self.y1
        
      if self.c.axis then self.setYAxis.call(@, self)
      
      g.each( (d, i) ->
        # create a box plot for each data group
        #self.setSpread.call(@, self, d, i)
        @g = d3.select(@)
        self.setMedian.call(@, self, d, i)
      )
        
    box.width = (value) ->
      return self.c.width unless arguments.length
      self.c.width = value
      box
      
    box.height = (value) ->
      return self.c.height unless arguments.length
      self.c.height = value
      box
      
    box.axis = (value) ->
      return self.c.axis unless arguments.length
      self.c.axis = value
      box
      
    box.subTicks = (value) ->
      return self.c.sub_ticks unless arguments.length
      self.c.sub_ticks = value
      box

    return box  ## end of init function, returns a closure
    

  setYAxis: (self) ->
    sub_ticks = if self.c.sub_ticks then 1 else 0
  
    yAxis = d3.svg.axis()
      .scale(self.y1)
      .orient("left")
      .tickSubdivide(sub_ticks)
      .tickSize(6, 3, 0) # sets major to 6, minor to 3, and end to 0

    self.svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      # translate(x, y)
      .attr("transform", "translate(#{self.c.margin.left}, #{self.c.margin.top})")
      
      
  setSpread: (self, d, i) ->
  
  
  setMedian: (self, d, i) ->
    # special case of getQuantiles for finding the median value of an array of values
    median = d3.quantile(d.sort( (a, b) -> d3.ascending(a, b) ), 0.5)
    line = @g.selectAll("line.median")
      .data([median])
    line.enter().append("svg:line")
      .attr("class", "median")
      .attr("x1", self.c.margin.left)
      .attr("y1", self.y0)
      .attr("x2", self.c.width)
      .attr("y2", self.y0)
    .transition()
      .duration(500)
      .attr("y1", self.y1)
      .attr("y2", self.y1)
    line.transition()
      .duration(500)
      .attr("y1", self.y1)
      .attr("y2", self.y1)

      

module.exports = boxChart

  
