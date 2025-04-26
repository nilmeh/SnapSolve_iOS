// app.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const analyzeRoute = require('./routes/analyze');
const ticketsRoute = require('./routes/tickets'); // <-- add this import

const app = express();
const PORT = process.env.PORT || 4000;

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URL, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB!'))
.catch((error) => console.error('MongoDB connection error:', error));

// Middleware
app.use(cors());
app.use(express.json({ limit: '15mb' }));

// Log all requests
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Basic test route
app.get('/', (req, res) => {
  res.send('SnapSolve backend is running!');
});

// API routes
app.use('/api', analyzeRoute);
app.use('/api/tickets', ticketsRoute); // <-- add this route!

// Start the server
app.listen(PORT, () => {
  console.log(`🚀 Server listening on port ${PORT}`);
});