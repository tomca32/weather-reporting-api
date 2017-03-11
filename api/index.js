'use strict';

const express = require('express');
const app = express();
const measurementRoutes = require('./measurements');
const bodyParser = require('body-parser');
const expressValidator = require('express-validator');

app.use(bodyParser.json());
app.use(expressValidator({}));

app.get('/ping', function (req, res) {
  res.send('pong');
});

app.use('/', measurementRoutes);

module.exports = app;
