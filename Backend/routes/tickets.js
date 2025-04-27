// routes/tickets.js
const express = require('express');
const Report = require('../models/Report');
const { sendReportEmail } = require('../mailer');

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

    const subject = 'Issue To Be Reported';
    const text = `A new report has been submitted to our app SnapSolve with the following details:
      Problem: ${problem_description}
      Recommendation: ${recommendation}
      Timestamp: ${timestamp}
      Location: (${latitude}, ${longitude})
    `;
    
    await sendReportEmail({
      fromEmail: email, // The user's email
      toEmail: savedReport.email, // The recipient's email (could be the agency or any relevant email)
      subject: subject,
      text: text,
      replyToEmail: req.user.email // Set the reply-to address to the user's email
    });

    return res.status(201).json(savedReport);

  } catch (err) {
    console.error('Error in /api/tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

router.get('/', async (req, res) => {
  try {
    let reports;
    if (req.user) {
      // If the user is authenticated, fetch reports specific to them
      reports = await Report.find({ userId: req.user.uid });
    } else {
      // If no user is authenticated, return all reports
      reports = await Report.find();
    }
    return res.json(reports);
  } catch (err) {
    console.error('Error fetching tickets:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;