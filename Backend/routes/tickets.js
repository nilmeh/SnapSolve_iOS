const express = require('express');
const Report = require('../models/Report');
const { sendReportEmail } = require('../mailer');
const { authMiddleware } = require('../auth'); // <<< ADD THIS

const router = express.Router();

// POST /api/tickets  ✅ protected
router.post('/', authMiddleware, async (req, res) => {
  try {
    const {
      problem_description,
      recommendation,
      timestamp,
      email,
      latitude,
      longitude,
      imageBase64,
      userId
    } = req.body;

    if (!problem_description || !timestamp || !recommendation) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

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
      userId: req.user.uid  // 👈 you need `req.user.uid`
    });

    const savedReport = await newReport.save();

    const subject = 'Issue To Be Reported';
    const text = `A new report has been submitted to our app SnapSolve with the following details:
      Problem: ${problem_description}
      Recommendation: ${recommendation}
      Timestamp: ${timestamp}
      Location: (${latitude}, ${longitude})
    `;

    await sendReportEmail({
      fromEmail: email,
      toEmail: savedReport.email,
      subject: subject,
      text: text,
      replyToEmail: req.user.email
    });

    return res.status(201).json(savedReport);

  } catch (err) {
    console.error('Error in /api/tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/tickets/my  ✅ protected
router.get('/my', authMiddleware, async (req, res) => {
  try {
    const reports = await Report.find({ userId: req.user.uid });
    return res.json(reports);
  } catch (err) {
    console.error('Error fetching user tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/tickets/all  🌍 public
router.get('/all', async (req, res) => {
  try {
    const reports = await Report.find();
    return res.json(reports);
  } catch (err) {
    console.error('Error fetching all tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/tickets/locations  🌍 public
router.get('/locations', async (req, res) => {
  try {
    const docs = await Report.find({}, {
      _id: 1,
      "location.latitude": 1,
      "location.longitude": 1
    });

    const coords = docs.map(doc => ({
      id: doc._id,
      latitude: doc.location.latitude,
      longitude: doc.location.longitude
    }));

    return res.json(coords);
  } catch (err) {
    console.error('Error fetching locations:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;