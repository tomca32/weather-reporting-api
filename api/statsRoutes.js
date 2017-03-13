const express = require('express');
const router = express.Router();
const measurements = require('./measurements');
const statsService = require('./statsService');

router.get('/stats', function(req, res) {
  const metric = req.query.metric;
  const targetMeasurements = measurements.getInterval(Date.parse(req.query.fromDateTime), Date.parse(req.query.toDateTime));
  const stats = req.query.stat;
  const result = stats
    .map(stat => statsService.getStat(targetMeasurements, metric, stat))
    .filter(stat => typeof stat !== 'undefined');
  res.status(200).json(result);
});

module.exports = router;