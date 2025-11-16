const shared = require('./development');

module.exports = {
  ...shared,
  port: Number(process.env.PORT) || 4001,
  database: {
    url: process.env.DB_URL || 'mongodb://localhost:27017/petready-staging'
  }
};
