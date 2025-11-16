const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const config = require('../config');
const registerWs = require('./api/websocket');

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

registerWs(io);

server.listen(config.port, () => {
  console.log(`🚀 PetReady Backend Server running on port ${config.port}`);
});
