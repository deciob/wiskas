Spine = require('spine')
boxChart = require('lib/box_chart')

class BoxCharts extends Spine.Controller

  template: require('views/box_charts')
  box: new boxChart()

  constructor: ->
    super
    @render()
    #@box.draw()()
    
  render: ->
    @.html @template()
    
  
    
    
    
module.exports = BoxCharts