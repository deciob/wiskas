Spine = require('spine')
boxChart = require('lib/wisk/box_chart')
BoxChartsDataset = require('models/box_chart_dataset')

class BoxCharts extends Spine.Controller

  template: require('views/box_charts')
  
  events: 
    "click button": "updateVisualisation"
  
  country_groups_ref: [
    "Low income",
    "Lower middle income",
    "Upper middle income",
    "High income: nonOECD",
    "High income: OECD"
  ]

  constructor: ->
    super
    @vis_id = @el.attr('id') + "_vis"
    @vis_title_id = @el.attr('id') + "_vis_title"
    @box_chart = new boxChart(@vis_id)
    @indicators = []
    @i = 1
    @datasets = {}
    @country_groups = no
    BoxChartsDataset.each (indicator) => 
      @indicators.push(indicator.id)
    #BoxChartsDataset.bind "update", @changeDataset
    @default_indicator =  BoxChartsDataset.first()
    Spine.Route.navigate("/vis", @default_indicator.slug)
    @render()
    
    
  render: ->
    self = @
    @.html @template(@)
    # to override defaults you can do this:
    # vis = @box_chart.init( {height:100} )
    # or this
    # vis = @box_chart.init().height(200)
    #Miso testing
    ds_economies = new Miso.Dataset(
      url: "/data/economies.csv"
      delimiter: ","
    )
    ds_default_indicator = new Miso.Dataset(
      url: self.default_indicator.url #"../data/life_expectancy_2010.csv"
      delimiter: ","
    )
    _.when(ds_economies.fetch(), ds_default_indicator.fetch()).then ->
      dataset = self.buildDataset(ds_economies, ds_default_indicator)
      self.datasets[self.default_indicator.slug] = ds_default_indicator
      self.chart = self.box_chart.init()#{dataset:self.dataset})
      #.axis(no)
      #.subTicks(yes)
      #.height(200)
      .width(100)
      .dataset(dataset)
      self.box_chart.draw(self.chart)
    
  buildDataset: (ds_economies, indicator) =>
    self = @
    min = Infinity
    max = -Infinity
    if not @country_groups
      @country_groups = {}
      ds_economies.each( (row) =>
        @country_groups[row.Code] = row['Income group']
      )
    data = []
    dataset = {}
    indicator.each( (row) ->
      i = self.country_groups_ref?.indexOf(self.country_groups[row.code])
      if row.val
        if not data[i]
          data[i] = [row.val]
        else
          data[i].push(row.val)
        if (row.val > max) then max = row.val
        if (row.val < min) then min = row.val
    )
    for d in data
      d.sort( (a, b) -> d3.ascending(a, b) )
    dataset.data = data
    dataset.min = min
    dataset.max = max
    dataset
    
  
  updateVisualisation: =>
    self = @
    if not @indicators[@i]
      @i = 0
    box_chart_dataset = BoxChartsDataset.find(@indicators[@i])
    slug = box_chart_dataset.slug
    Spine.Route.navigate( "/vis", slug )
    if @datasets[slug]
      dataset = self.buildDataset(no, @datasets[slug])
      @chart.dataset(dataset)
      @box_chart.update(self.chart)
    else
      ds_indicator = new Miso.Dataset(
        url: box_chart_dataset.url #"../data/life_expectancy_2010.csv"
        delimiter: ","
      )
      ds_indicator.fetch(
        success : ->
          dataset = self.buildDataset(no, @)
          self.datasets[slug] = @
          self.chart.dataset(dataset)
          self.box_chart.update(self.chart)
      )
    @i += 1
  
  
  changeDataset: (indicator) =>
    if indicator.active
      console.log indicator.title
      

      
module.exports = BoxCharts
