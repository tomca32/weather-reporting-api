const strings = require('./strings');

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

module.exports = {
  respondIfErrors: respondIfErrors,
  respondIfMeasurementNonexistant: respondIfMeasurementNonexistant,
  respondIfConflict: respondIfConflict
};
