
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
      margin: top: 10, right: 50, bottom: 20, left: 50
    c.height = 500 - c.margin.top - c.margin.bottom
    c.width = 600 - c.margin.left - c.margin.right
    @c = $.extend(yes, c, conf)
 
    
    box = (g) ->
    
      y = d3.scale.linear()
        # input inverted because svg y positions are counted from top to bottom
        .domain([self.max, self.min])  # input
        .range([0, self.c.height])      # output

      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .tickSize(6, 3, 0) # sets major to 6, minor to 3, and end to 0
        
      self.svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        # translate(x, y)
        .attr("transform", "translate(#{self.c.margin.left}, #{self.c.margin.top})")
      
      g.each( (d, i) ->
        #console.log 'g.each', d, i 
        # create a box plot for each data group
      )
      
      
    box.width = (value) ->
      return self.c.width unless arguments.length
      self.c.width = value
      box
      
      
    box.height = (value) ->
      return self.c.height unless arguments.length
      self.c.height = value
      box
      

    return box
    


module.exports = boxChart

  
