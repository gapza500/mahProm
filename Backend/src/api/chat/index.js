const express = require('express');
const router = express.Router();

router.get('/conversations', (_req, res) => {
  res.json({ conversations: [] });
});

module.exports = router;
