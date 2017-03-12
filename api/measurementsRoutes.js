const express = require('express');
const router = express.Router();
const measurements = require('./measurements');
const strings = require('./strings');

router.get('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', strings.errors.invalidTimestamp()).isISO8601();
  req.getValidationResult().then(function(errors) {
    if (respondIfErrors(errors, res)) return;

    let measurement = measurements.get(req.params.timestamp);
    if (measurement) {
      return res.json(measurement);
    }
    res.status(404).json({errors: strings.errors.measurementNotFound(req.params.timestamp)});
  });
});

router.post('/measurements', function (req, res) {
  measurements.save(req).then(function(errors) {
    if (respondIfErrors(errors, res)) return;

    res.status(201)
      .set('Location', `/measurements/${req.body.timestamp}`)
      .send();
  });
});

router.put('/measurements/:timestamp', function(req, res) {
  req.checkParams('timestamp', strings.errors.invalidTimestamp()).isISO8601();
  measurements.replace(req).then(function(errors) {
    if (respondIfMeasurementNonexistant(errors, res,req) || respondIfConflict(errors, res) || respondIfErrors(errors, res)) return;

    res.status(204).send();
  });
});

router.patch('/measurements/:timestamp', function(req, res) {
  measurements.update(req).then(function(errors) {
    if (respondIfMeasurementNonexistant(errors, res,req) || respondIfConflict(errors, res) || respondIfErrors(errors, res)) return;

    res.status(204).send();
  });
});

function respondIfErrors(errors, res) {
  if (!errors.isEmpty()) {
    res.status(400).json({errors: errors.mapped()});
    return true;
  }
  return false;
}

function respondIfMeasurementNonexistant(errors, res, req) {
  if (!errors.isEmpty()) {
    let errs = errors.mapped();
    if (errs.timestamp && errs.timestamp.msg === strings.errors.measurementNotFound(req.params.timestamp)) {
      res.status(404).json({errors: errors.mapped()});
      return true;
    }
  }
  return false;
}

function respondIfConflict(errors, res) {
  if (!errors.isEmpty()) {
    let errs = errors.mapped();
    if (errs.timestamp && errs.timestamp.msg === strings.errors.timestampMismatch()) {
      res.status(409).json({errors: errors.mapped()});
      return true;
    }
  }
  return false;
}

module.exports = router;
