require('lib/setup')

Spine = require('spine')
BoxCharts = require('controllers/box_charts')

$ = Spine.$


class App extends Spine.Controller

  elements:
    "#box_chart": "box_chart"

  constructor: ->
    super
    chart = new BoxCharts(el: @box_chart)
    
    
  

    
module.exports = App
    