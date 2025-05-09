require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const analyzeRoute = require('./routes/analyze');
const ticketsRoute = require('./routes/tickets');
const { authMiddleware } = require('./auth');  // Import auth middleware properly

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '500mb' }));

// Log all requests
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// MongoDB connect
mongoose.connect(process.env.MONGO_URL, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB!'))
.catch((error) => console.error('MongoDB connection error:', error));

// Basic route to test server
app.get('/', (req, res) => {
  res.send('SnapSolve backend is running!');
});

// API Routes
app.use('/api/analyze', analyzeRoute);          // No login required
app.use('/api/tickets', ticketsRoute);  // ✅ Login required (attach req.user)

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server listening on port ${PORT}`);
});