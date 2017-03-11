function saveMeasurement(req) {
  validateMeasurementParams(req);
  return req.getValidationResult();
}

function validateMeasurementParams(req) {
  req.checkBody('timestamp', 'timestamp is required in ISO-8061 format').notEmpty();
}

module.exports = {
  saveMeasurement: saveMeasurement
};
