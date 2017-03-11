const express = require('express');
const router = express.Router();
const measurements = require('./measurements');

router.get('/measurements/:measurementId', function(req, res) {
  res.json(measurements.get(req.params.measurementId));
});

router.post('/measurements', function (req, res) {
  measurements.save(req).then(function(errors) {
    if (!errors.isEmpty()) {
      return res.status(400).json({errors: errors.mapped()});
    }
    res.status(201)
      .set('Location', `/measurements/${req.body.timestamp}`)
      .send();
  });
});

module.exports = router;
