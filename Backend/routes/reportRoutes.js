const express = require('express');
const Report = require('../models/Report');

const router = express.Router();

// POST route to create a new report
router.post('/', async (req, res) => {
    try {
        const { problem_description, timestamp, agency } = req.body;

        // Validate required fields
        if (!problem_description || !timestamp || !agency) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        // Create a new report
        const newReport = new Report({
            problem_description,
            timestamp,
            agency,
            userId: req.user.uid 
        });

        // Save the report to the database
        const savedReport = await newReport.save();

        res.status(201).json(savedReport);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

// GET route to fetch user's reports
router.get('/', async (req, res) => {
    try {
        // Fetch reports for the authenticated user
        const reports = await Report.find({ userId: req.user.uid });
        res.json(reports);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch reports.' });
    }
});

module.exports = router;
