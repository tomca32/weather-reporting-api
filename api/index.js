'use strict';

const express = require('express');
const app = express();

const measurementRoutes = require('./measurements');

const bodyParser = require('body-parser');
app.use( bodyParser.json() );

app.get('/ping', function (req, res) {
  res.send('pong');
});

app.use('/', measurementRoutes);

module.exports = app;
