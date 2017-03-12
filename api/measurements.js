const strings = require('./strings');

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
  iterateOverObject(body, (measurementName, measurementValue) => measurements[body.timestamp][measurementName] = measurementValue);
}

function validateMeasurementParams(req) {
  req.checkBody('timestamp', strings.errors.timestampRequired()).notEmpty().isISO8601();
  iterateOverObject(req.body, (param) => {
    param !== 'timestamp' && req.checkBody(param, strings.errors.invalidMeasurementFormat()).isFloat();
  });
}

function get(time) {
  return measurements[time] || getMeasurementsOn(time);
}

function replace(req) {
  validateMeasurementParams(req);
  req.checkBody('timestamp', strings.errors.timestampMismatch()).equals(req.params.timestamp);
  return req.getValidationResult().then(function(errors) {
    if (errors.isEmpty()) {
      saveMeasurement(req.body);
    }
    return errors;
  });
}

function iterateOverObject(obj, fn) {
  for (let key in obj) {
    if (obj.hasOwnProperty(key)) {
      fn(key, obj[key])
    }
  }
}

function getMeasurementsOn(time) {
  let result = Object.keys(measurements)
    .filter(measurement => measurement.indexOf(time) !== -1)
    .map(measurement => measurements[measurement]);
  return result.length ? result : void 0;
}

module.exports = {
  get: get,
  save: save,
  replace: replace
};
