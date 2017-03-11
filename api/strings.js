module.exports = {
  errors: {
    invalidTimestamp: () => 'Invalid or missing timestamp. Use ISO-8601 format to identify measurements, e.g. /measurements/2015-09-01T16:40:00.000Z',
    timestampRequired: () => 'timestamp is required in ISO-8061 format',
    measurementNotFound: (time) => `Measurement on ${time} does not exist.`,
    invalidMeasurementFormat: () => 'all measurement values should be floating-point numbers'
  }
};
