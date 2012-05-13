Spine = require('spine')

class BoxChartDataset extends Spine.Model
  @configure 'BoxChartDataset', 'title', 'url', 'active', 'dataset'
  

  
module.exports = BoxChartDataset