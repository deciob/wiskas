require('lib/setup')

Spine = require('spine')
BoxCharts = require('controllers/box_charts')
BoxChartsDataset = require('models/box_chart_dataset')

$ = Spine.$


class App extends Spine.Controller

  elements:
    "#box_chart": "box_chart"


  constructor: ->
    super
    @setupDb()
    @setupRoutes()
    
    chart = new BoxCharts(el: @box_chart)
    
    
  setupRoutes: ->
    Spine.Route.setup()
    @routes
      "/vis/:indicator": (params) ->
        BoxChartsDataset.each (indicator) -> 
          if indicator.slug == params.indicator
            indicator.active = yes
          else
            indicator.active = no
          indicator.save()
     
     
  setupDb: ->
    forests = new BoxChartsDataset(
      slug: 'forest_coverage'
      title: "Forest area (% of land area)"
      url: "../data/forest_perc_land.csv"
      active: no
    )
    forests.save()
    life_expectancy = new BoxChartsDataset(
      slug: 'life_expectancy'
      title: "Life expectancy"
      url: "../data/life_expectancy_2010.csv"
      active: yes
    )
    life_expectancy.save()
    
    
    
module.exports = App
    