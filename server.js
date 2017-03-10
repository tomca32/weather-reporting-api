'use strict';

const argv = require('optimist').argv;
const server = require('./api');

const port = Number(argv.port) || process.env.PORT || 3000;
const host = argv.host || 'localhost';
const invalidHostError = `This probably happened because of the invalid --host option.\nRemove the "--host ${argv.host}" option to run on localhost.`;

server.listen(port, host, function () {
  console.log('Server running on port %d', port);
}).on('error', function(err) {
  if (err.errno === 'EADDRNOTAVAIL') {
    console.error(`Error: ${err.message}\n${invalidHostError}`);
  }
});
