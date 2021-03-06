const strings = require('./strings');
const pickBy = require('lodash.pickby');

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
  saveMetrics(body);
}

function saveMetrics(body) {
  iterateOverObject(body, (metricName, metricValue) => saveMetric(body.timestamp, metricName, metricValue));
}

function saveMetric(timestamp, metricName, metricValue) {
  if (metricName !== 'timestamp') {
    metricValue = Number(metricValue);
  }
  measurements[timestamp][metricName] = metricValue;
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

function getInterval(from, to) {
  return pickBy(measurements, (value, key) => {
    const date = Date.parse(key);
    return (from === 0 || date >= from) && (to === 0 || date < to);
  });
}

function replace(req) {
  req.checkParams('timestamp', strings.errors.measurementNotFound(req.params.timestamp)).measurementExists();
  validateMeasurementParams(req);
  req.checkBody('timestamp', strings.errors.timestampMismatch()).equals(req.params.timestamp);
  return req.getValidationResult().then(function(errors) {
    if (errors.isEmpty()) {
      saveMeasurement(req.body);
    }
    return errors;
  });
}

function update(req) {
  req.checkParams('timestamp', strings.errors.measurementNotFound(req.params.timestamp)).measurementExists();
  validateMeasurementParams(req);
  req.checkBody('timestamp', strings.errors.timestampMismatch()).equals(req.params.timestamp);
  return req.getValidationResult().then(function(errors) {
    if (errors.isEmpty()) {
      iterateOverObject(req.body, (metricName, metricValue) => saveMetric(req.params.timestamp, metricName, metricValue));
    }
    return errors;
  });
}

function deleteMeasurement(req) {
  req.checkParams('timestamp', strings.errors.measurementNotFound(req.params.timestamp)).measurementExists();
  return req.getValidationResult().then(function(errors) {
    if (errors.isEmpty()) {
      delete measurements[req.params.timestamp];
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

function measurementExists(timestamp) {
  return !!measurements[timestamp];
}

function clean() {
  measurements = {};
}

module.exports = {
  get: get,
  getInterval: getInterval,
  save: save,
  replace: replace,
  update: update,
  delete: deleteMeasurement,
  measurementExists: measurementExists,
  clean: clean
};
