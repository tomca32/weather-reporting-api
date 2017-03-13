const statsCalculations = {
  min: function min(values) {
    return Math.min.apply(null, values);
  },
  max: function max(values) {
    return Math.max.apply(null, values);
  },
  average: function average(values) {
    return (values.reduce((sum, e) => {return sum + e}, 0) / values.length).toFixed(3);
  }
};

function getStat(measurements, metric, stat) {
  const metricValues = getMetricValues(objectValues(measurements), metric);
  if (metricValues.length === 0) {
    return;
  }
  const statValue = statsCalculations[stat](metricValues, metric);
  return wrapStat(metric, stat, statValue);
}

function filterByMetricName(measurements, metricName) {
  return measurements.filter(measurement => measurement.hasOwnProperty(metricName));
}

function getMetricValues(measurements, metricName) {
  return filterByMetricName(measurements, metricName).map(measurement => measurement[metricName]);
}

function wrapStat(metricName, statName, statValue) {
  return {
    metric: metricName,
    stat: statName,
    value: statValue
  };
}

function objectValues(object) {
  return Object.keys(object).map(key => object[key]);
}

module.exports = {
  getStat: getStat
};
