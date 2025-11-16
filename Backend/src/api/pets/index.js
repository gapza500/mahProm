const express = require('express');
const router = express.Router();

router.get('/', (_req, res) => {
  res.json({ pets: [] });
});

router.post('/', (req, res) => {
  res.status(201).json({ pet: req.body });
});

module.exports = router;
