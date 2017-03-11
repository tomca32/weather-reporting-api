const express = require('express');
const router = express.Router();
const measurements = require('./measurements');
const strings = require('./strings');

router.get('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', strings.errors.invalidTimestamp()).isISO8601();
  req.getValidationResult().then(function(errors) {
    if (!errors.isEmpty()) {
      return res.status(400).json({errors: errors.mapped()});
    }
    let measurement = measurements.get(req.params.timestamp);
    if (measurement) {
      return res.json(measurement);
    }
    res.status(404).json({errors: strings.errors.measurementNotFound(req.params.timestamp)});
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
