const express = require('express');
const isString = require('lodash.isstring');
const router = express.Router();
const measurements = require('./measurements');
const statsService = require('./statsService');

router.get('/stats', function(req, res) {
  const metrics = isString(req.query.metric) ? [req.query.metric] : req.query.metric;
  const targetMeasurements = measurements.getInterval(Date.parse(req.query.fromDateTime), Date.parse(req.query.toDateTime));
  const stats = req.query.stat;
  const result = metrics.map((metric) => {
    return stats
      .map(stat => statsService.getStat(targetMeasurements, metric, stat))
      .filter(stat => typeof stat !== 'undefined');
  });
  res.status(200).json(flatten(result));
});

function flatten(arr) {
  return Array.prototype.concat(...arr);
}

module.exports = router;
