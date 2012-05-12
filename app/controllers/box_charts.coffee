Spine = require('spine')
boxChart = require('lib/wisk/box_chart')

class BoxCharts extends Spine.Controller

  template: require('views/box_charts')
  
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
    @box_chart = new boxChart(@vis_id)
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
    ds_life_expectancy = new Miso.Dataset(
      url: "../data/life_expectancy_2010.csv"
      delimiter: ","
    )
    _.when(ds_economies .fetch(), ds_life_expectancy.fetch()).then ->
      self.buildDataset(ds_economies, ds_life_expectancy)
      chart = self.box_chart.init()#{dataset:self.dataset})
      #.axis(no)
      #.subTicks(yes)
      #.height(200)
      .width(100)
      .dataset(self.dataset)
      self.box_chart.draw(chart)
    
  buildDataset: (ds_economies, ds_life_expectancy) =>
    self = @
    min = Infinity
    max = -Infinity
    country_groups = {}
    data = []
    @dataset = {}
    ds_economies.each( (row) ->
      country_groups[row.Code] = row['Income group']
    )
    ds_life_expectancy.each( (row) ->
      i = self.country_groups_ref?.indexOf(country_groups[row.code])
      console.log i, row
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
    @dataset.data = data
    @dataset.min = min
    @dataset.max = max

      
module.exports = BoxCharts
