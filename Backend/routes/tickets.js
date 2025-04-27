// routes/tickets.js
const express = require('express');
const Report = require('../models/Report');

const router = express.Router();

// POST /api/tickets
router.post('/', async (req, res) => {
  try {
    const {
      problem_description,
      recommendation,      // ← renamed from `agency`
      timestamp,
      email,
      latitude,
      longitude,
      imageBase64,
      userId
    } = req.body;

    // Validate required fields
    if (!problem_description || !timestamp || !recommendation) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Build a new report (nesting location)
    const newReport = new Report({
      problem_description,
      recommendation,
      timestamp,
      email,
      location: {
        latitude,
        longitude
      },
      imageBase64,
      // userId: req.user.uid // Use the user ID from the request
    });

    const savedReport = await newReport.save();
    return res.status(201).json(savedReport);

  } catch (err) {
    console.error('Error in /api/tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

router.get('/', async (req, res) => {
  try {
    const reports = await Report.find({ userId: req.user.uid });
    return res.json(reports);
  } catch (err) {
    console.error('Error fetching tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;