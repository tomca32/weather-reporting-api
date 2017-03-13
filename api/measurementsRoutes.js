const express = require('express');
const router = express.Router();
const measurements = require('./measurements');
const strings = require('./strings');
const errorResponder = require('./errorResponder');

router.get('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', strings.errors.invalidTimestamp()).isISO8601();
  req.getValidationResult().then(function(errors) {
    if (errorResponder.respondIfErrors(errors, res)) return;

    let measurement = measurements.get(req.params.timestamp);
    if (measurement) {
      return res.json(measurement);
    }
    res.status(404).json({errors: strings.errors.measurementNotFound(req.params.timestamp)});
  });
});

router.post('/measurements', function (req, res) {
  measurements.save(req).then(function(errors) {
    if (errorResponder.respondIfErrors(errors, res)) return;

    res.status(201)
      .set('Location', `/measurements/${req.body.timestamp}`)
      .send();
  });
});

router.put('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', strings.errors.invalidTimestamp()).isISO8601();
  measurements.replace(req).then(function(errors) {
    if (errorResponder.respondIfMeasurementNonexistant(errors, res,req) || errorResponder.respondIfConflict(errors, res) || errorResponder.respondIfErrors(errors, res)) return;

    res.status(204).send();
  });
});

router.patch('/measurements/:timestamp', function(req, res) {
  measurements.update(req).then(function(errors) {
    if (errorResponder.respondIfMeasurementNonexistant(errors, res,req) || errorResponder.respondIfConflict(errors, res) || errorResponder.respondIfErrors(errors, res)) return;

    res.status(204).send();
  });
});

router.delete('/measurements/:timestamp', function(req, res) {
  measurements.delete(req).then(function(errors) {
    if (errorResponder.respondIfMeasurementNonexistant(errors, res,req)) return;

    res.status(204).send();
  });
});



module.exports = router;
