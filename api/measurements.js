let measurements = {};

function save(req) {
  validateMeasurementParams(req);
  return req.getValidationResult().then(function(errors) {
    if (errors.isEmpty()) {
      saveMeasurement(req.body);
    }
    return errors;
  });
}

function saveMeasurement(body) {
  measurements[body.timestamp] = {};
  iterateOverParams(body, measurement => measurements[body.timestamp][measurement] = body[measurement]);
}

function validateMeasurementParams(req) {
  req.checkBody('timestamp', 'timestamp is required in ISO-8061 format').notEmpty().isISO8601();
  iterateOverParams(req.body, (param) => {
    param !== 'timestamp' && req.checkBody(param, 'all measurement values should be floating-point numbers').isFloat();
  });
}

function get(measurementId) {
  return measurements[measurementId];
}

function getAll() {
  return measurements;
}

module.exports = {
  get: get,
  getAll: getAll,
  save: save
};

function iterateOverParams(body, fn) {
  for (let param in body) {
    if (body.hasOwnProperty(param)) {
      fn(param, body)
    }
  }
}