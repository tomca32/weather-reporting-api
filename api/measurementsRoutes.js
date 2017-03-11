const express = require('express');
const router = express.Router();
const measurements = require('./measurements');
const invalidTimestamp = 'Invalid or missing timestamp. Use ISO-8601 format to identify measurements, e.g. /measurements/2015-09-01T16:40:00.000Z';

router.get('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', invalidTimestamp).isISO8601();
  req.getValidationResult().then(function(errors) {
    if (!errors.isEmpty()) {
      return res.status(400).json({errors: errors.mapped()});
    }
    let measurement = measurements.get(req.params.timestamp);
    if (measurement) {
      return res.json(measurement);
    }
    res.status(404).json({errors: `Measurement on ${req.params.timestamp} does not exist.`});
  });
});

router.post('/measurements', function (req, res) {
  measurements.save(req).then(function(errors) {
    if (!errors.isEmpty()) {
      return res.status(400).json({errors: errors.mapped()});
    }
    res.status(201)
      .set('Location', `/measurements/${req.body.timestamp}`)
      .send();
  });
});

module.exports = router;
