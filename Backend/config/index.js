const env = process.env.NODE_ENV || 'development';
const map = {
  development: './development',
  staging: './staging',
  production: './production'
};

const config = require(map[env] || map.development);
module.exports = config;
