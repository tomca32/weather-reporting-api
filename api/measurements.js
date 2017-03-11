const express = require('express');
const router = express.Router();

router.post('/measurements', function (req, res) {
  validateMeasurementParams(req);
  req.getValidationResult().then(function(result) {
    if (!result.isEmpty()) {
      return res.status(400).json({errors: result.mapped()});
    }
    res.status(201)
      .set('Location', `/measurements/${req.body.timestamp}`)
      .send();
  });
});

function validateMeasurementParams(req) {
  req.checkBody('timestamp', 'timestamp is required in ISO-8061 format').notEmpty();
}

module.exports = router;
