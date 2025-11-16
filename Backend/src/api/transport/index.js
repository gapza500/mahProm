const express = require('express');
const router = express.Router();

router.get('/jobs', (_req, res) => {
  res.json({ jobs: [] });
});

router.post('/jobs', (req, res) => {
  res.status(201).json({ job: req.body });
});

module.exports = router;
