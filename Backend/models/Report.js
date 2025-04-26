const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
    problem_description: {
        type: String,
        required: true
    },
    timestamp: {
        type: Date,
        required: true
    },
    agency: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('Report', ReportSchema);