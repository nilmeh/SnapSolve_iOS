// app.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const analyzeRoute = require('./routes/analyze');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json({ limit: '15mb' }));

// Log all requests
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

app.get('/', (req, res) => {
  res.send('SnapSolve backend is running!');
});

app.use('/api', analyzeRoute);

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});