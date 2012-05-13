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
    
  setupDb: ->
    forests = new BoxChartsDataset(
      id: 'forest_coverage'
      title: "Forest area (% of land area)"
      url: "../data/forest_perc_land.csv"
      active: no
    )
    forests.save()
    life_expectancy = new BoxChartsDataset(
      id: 'life_expectancy'
      title: "Life expectancy"
      url: "../data/life_expectancy_2010.csv"
      active: yes
    )
    life_expectancy.save()
    cereal_yield = new BoxChartsDataset(
      id: 'cereal_yield_2010'
      title: "Cereal yield (kg per hectar, 2010)"
      url: "../data/cereal_yield_2010.csv"
      active: no
    )
    cereal_yield.save()
    
  setupRoutes: ->
    Spine.Route.setup()
    @routes
      "/vis/:id": (params) ->
        BoxChartsDataset.each (record) -> 
          if record.id == params.id
            record.active = yes
            Spine.trigger "title:update", record.title
          else
            record.active = no
          record.save()
     
    
        
module.exports = App
    