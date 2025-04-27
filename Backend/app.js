const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

// Import the report routes and the authMiddleware
const { authMiddleware } = require('./auth');
const reportRoutes = require('./routes/reportRoutes');  // Make sure the path is correct

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
