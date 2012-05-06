Spine = require('spine')
boxChart = require('lib/box_chart')

class BoxCharts extends Spine.Controller

  template: require('views/box_charts')

  constructor: ->
    super
    @vis_id = @el.attr('id') + "_vis"
    @box_chart = new boxChart(@vis_id)
    @render()
    
  render: ->
    @.html @template(@)
    # to override defaults you can do this:
    # vis = @box_chart.init( {height:100} )
    # or this
    # vis = @box_chart.init().height(200)
    chart = @box_chart.init()
      #.axis(no)
      #.subTicks(yes)
      #.height(200)
      #.width(300)
    @box_chart.draw(chart)
    
  
      
module.exports = BoxCharts