module.exports = (io) => {
  io.on('connection', (socket) => {
    console.log('User connected:', socket.id);
    socket.on('chat:message', (payload) => {
      socket.broadcast.emit('chat:message', payload);
    });
    socket.on('disconnect', () => console.log('User disconnected:', socket.id));
  });
};
