Spine = require('spine')

class BoxChartDataset extends Spine.Model
  @configure 'BoxChartDataset', 'title', 'slug', 'url', 'active'
  

  
module.exports = BoxChartDataset