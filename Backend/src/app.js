const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const authRoutes = require('./api/auth');
const petRoutes = require('./api/pets');
const clinicRoutes = require('./api/clinics');
const chatRoutes = require('./api/chat');
const transportRoutes = require('./api/transport');
const adminRoutes = require('./api/admin');

const app = express();
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/pets', petRoutes);
app.use('/api/clinics', clinicRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/transport', transportRoutes);
app.use('/api/admin', adminRoutes);

app.get('/health', (_req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

module.exports = app;
