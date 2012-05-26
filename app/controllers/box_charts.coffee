Spine = require('spine')
BoxChart = require('lib/wisk/box_chart')
BoxChartsDataset = require('models/box_chart_dataset')

#console.log BoxChart

class BoxCharts extends Spine.Controller

  template: require('views/box_charts')
  
  elements:
    "button": "update_button"
    "#vis_title": "title"
  
  events: 
    "click button": "updateVisualisation"
  
  country_groups_ref: [
    "Low income"
    "Lower middle income"
    "Upper middle income"
    "High income: nonOECD"
    "High income: OECD"
  ]

  constructor: ->
    super
    Spine.bind "title:update", @updateTitle
    @vis_id = @el.attr('id') + "_vis"
    @vis_title_id = @el.attr('id') + "_vis_title"
    @vis_ids = []  # used as an ordered reference to update the visualisation
    @current_vis_id = no
    @box_chart = new BoxChart(@vis_id)  # d3 vis
    Spine.Route.navigate("/vis")
    @render()
    
  render: ->
    self = @
    @.html @template(@)
    @setupData()
    
  buildDataset: (indicator) =>
    self = @
    min = Infinity
    max = -Infinity
    if not @country_groups
      @country_groups = {}
      self.ref_ds.each( (row) =>
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
    old_vis = BoxChartsDataset.find(@current_vis_id)
    old_vis_index = @vis_ids.indexOf(old_vis.id)
    if @vis_ids[old_vis_index + 1]
      new_vis_index = @vis_ids[old_vis_index + 1]
    else
      new_vis_index = @vis_ids[0]
    new_vis = BoxChartsDataset.find(new_vis_index)
    Spine.Route.navigate( "/vis", new_vis.id )
    self.chart.dataset(new_vis.dataset)
    self.box_chart.update(self.chart)
    @current_vis_id = new_vis_index

   
  setupData: ->
    # for every entry in BoxChartsDataset
    # save a dataset object that looks like:
    # [ min, max, [all_data] ]
    # then navigate to the first one saved
    # and draw the chart (d3)!
    # relies on miso-dataset (http://misoproject.com)
    self = @
    initialised = no
    first = BoxChartsDataset.first()
    datasets = {}
    saveDataset = (id) ->
      dataset = self.buildDataset(@)
      record = BoxChartsDataset.find(id)
      record.dataset = dataset
      record.save()
      if not initialised
        Spine.Route.navigate("/vis", id)
        # to override defaults you can do this:
        # vis = @box_chart.init( {height:100} )
        # or this
        # vis = @box_chart.init().height(200)
        self.chart = self.box_chart.init()
          .in_margin(top: 10, right: 30, bottom: 20, left: 30)
          .axis(yes)
          .subTicks(yes)
          .height(400)
          .width(600)
          #.stroke_width(5)
          .dataset(dataset)
        self.box_chart.draw(self.chart)
        self.current_vis_id = id
        initialised = yes
    getDatasets = ->
      BoxChartsDataset.each (record) ->
        id = record.id
        self.vis_ids.push(id)  #used later, when updating the vis
        datasets[id] = new Miso.Dataset(
          url: record.url
          delimiter: ","
        )
        _.when( datasets[id].fetch() ).then ->
          saveDataset.call(@, id)
    # reference dataset, contains information on how to group countries
    ref_ds = new Miso.Dataset(
      url: "/data/economies.csv"
      delimiter: ","
    )
    _.when( ref_ds.fetch() ).then ->
      getDatasets.call(@)
    @ref_ds = ref_ds
    
  updateTitle: (txt) =>
    @title.html(txt)
    
    
    
module.exports = BoxCharts
