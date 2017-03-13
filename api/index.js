'use strict';

const express = require('express');
const app = express();
const measurementRoutes = require('./measurementsRoutes');
const statsRoutes = require('./statsRoutes');
const bodyParser = require('body-parser');
const expressValidator = require('express-validator');
const measurements = require('./measurements');

app.use(bodyParser.json());
app.use(expressValidator({
  customValidators: {
    measurementExists: function(value) {
      return measurements.measurementExists(value);
    }
  }
}));

app.get('/ping', function (req, res) {
  res.send('pong');
});

app.use('/', measurementRoutes);
app.use('/', statsRoutes);

module.exports = app;
