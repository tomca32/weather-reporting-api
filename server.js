'use strict';

var argv = require('optimist').argv;
var server = require('./api');

var port = Number(argv.port) || process.env.PORT || 3000;

server.listen(port, function () {
  console.log('Server running on port %d', port);
});
