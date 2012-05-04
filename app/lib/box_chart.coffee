

class boxChart
  
  constructor: -> 
    self = @
    @margin = { top: 10, right: 50, bottom: 20, left: 50 }
    @width = 120 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom
    @min = Infinity
    @max = -Infinity
        
    @chart = @draw()
      .width(@width)
      .height(@height)
      
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
      
      self.svg = d3.select("#box_viz").selectAll("svg")
        .data(self.data)
      .enter().append("svg")
        .attr("class", "box")
        .attr("width", self.width + self.margin.left + self.margin.right)
        .attr("height", self.height + self.margin.bottom + self.margin.top)
      self.svg.append("g")
        .attr("transform", "translate(#{self.margin.left}, #{self.margin.top})")
        .call(self.chart)
      
    )
    

  draw: ->
    self = @
    # defaults
    #width 
    
    
    box = (g) ->
    
      y = d3.scale.linear()
        # input inverted because svg y positions are counted from top to bottom
        .domain([self.max, self.min])  # input
        .range([0, box.height()])      # output

      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .tickSize(6, 3, 0) # sets major to 6, minor to 3, and end to 0
        
      self.svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        # translate(x, y)
        .attr("transform", "translate(#{self.margin.left}, #{self.margin.top})")
      
      g.each( (d, i) ->
        #console.log 'g.each', d, i 
        # create a box plot for each data group
      )
      
      
    box.width = (value) ->
      return self.width unless arguments.length
      self.width = value
      box
      
      
    box.height = (value) ->
      return self.height unless arguments.length
      self.height = value
      box
      

    return box
    


module.exports = boxChart

  
