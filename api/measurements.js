const express = require('express');
const router = express.Router();

router.post('/measurements', function (req, res) {
  res.status(201)
    .set('Location', `/measurements/${req.body.timestamp}`)
    .send();
});

module.exports = router;
