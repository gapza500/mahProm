const express = require('express');
const router = express.Router();

router.post('/login', (req, res) => {
  const now = new Date().toISOString();
  res.json({
    token: 'mock-token',
    user: {
      id: '00000000-0000-0000-0000-000000000000',
      userType: 'owner',
      displayName: 'Demo Owner',
      phone: req.body?.phone ?? '',
      email: 'owner@petready.app',
      verificationStatus: 'verified',
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
      isDirty: false
    }
  });
});

router.post('/otp', (_req, res) => {
  res.json({ valid: true });
});

module.exports = router;
