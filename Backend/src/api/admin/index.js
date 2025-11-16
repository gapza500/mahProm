const express = require('express');
const router = express.Router();

router.get('/announcements', (_req, res) => {
  res.json({ announcements: [] });
});

router.post('/announcements', (req, res) => {
  res.status(201).json({ announcement: req.body });
});

module.exports = router;
