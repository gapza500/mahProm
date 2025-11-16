module.exports = {
  port: Number(process.env.PORT) || 3001,
  database: {
    url: process.env.DB_URL || 'mongodb://localhost:27017/petready-dev'
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: Number(process.env.REDIS_PORT) || 6379
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret-key',
    expiresIn: '7d'
  },
  cloud: {
    awsRegion: process.env.AWS_REGION || 'ap-southeast-1'
  }
};
