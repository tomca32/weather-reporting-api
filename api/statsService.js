const statsCalculations = {
  min: function min(measurements, metricName) {
    return Math.min.apply(null, getMetricValues(measurements, metricName));
  },
  max: function max(measurements, metricName) {
    return Math.max.apply(null, getMetricValues(measurements, metricName));
  },
  average: function average(measurements, metricName) {
    const values = getMetricValues(measurements, metricName);
    return values.reduce((sum, e) => {return sum + e}, 0) / values.length;
  }
};

function getStat(measurements, metric, stat) {
  const statValue = statsCalculations[stat](objectValues(measurements), metric);
  return wrapStat(metric, stat, statValue);
}

function filterByMetricName(measurements, metricName) {
  return measurements.filter(measurement => measurement.hasOwnProperty(metricName));
}

function getMetricValues(measurements, metricName) {
  return filterByMetricName(measurements, metricName).map(measurement => Number(measurement[metricName]));
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
