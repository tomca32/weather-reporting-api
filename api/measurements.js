function saveMeasurement(req) {
  validateMeasurementParams(req);
  return req.getValidationResult();
}

function validateMeasurementParams(req) {
  req.checkBody('timestamp', 'timestamp is required in ISO-8061 format').notEmpty();
  for (let param in req.body) {
    if(req.body.hasOwnProperty(param) && param !== 'timestamp') {
      req.checkBody(param, 'all measurement values should be floating-point numbers').isFloat();
    }
  }
}

module.exports = {
  saveMeasurement: saveMeasurement
};
