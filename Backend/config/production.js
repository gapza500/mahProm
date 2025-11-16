module.exports = {
  port: Number(process.env.PORT) || 80,
  database: {
    url: process.env.DB_URL
  },
  redis: {
    host: process.env.REDIS_HOST,
    port: Number(process.env.REDIS_PORT)
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: '7d'
  },
  cloud: {
    awsRegion: process.env.AWS_REGION
  }
};
