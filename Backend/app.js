const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const analyzeRoute = require('./routes/analyze');
const ticketsRoute = require('./routes/tickets'); // <-- add this import
require('dotenv').config();

// Import the report routes and the authMiddleware
const { authMiddleware } = require('./auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Basic route to test
app.get('/', (req, res) => {
  res.send('SnapSolve backend is running!');
});

// Use the report routes with the /api prefix and protect the routes
app.use('/api/reports', authMiddleware, reportRoutes);  // Apply authMiddleware here to protect routes

// Start the server
app.listen(PORT, () => {
  console.log(`Server is listening on port ${PORT}`);
});

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