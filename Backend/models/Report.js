// models/Report.js
const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
  problem_description: { type: String,   required: false },
  recommendation:      { type: String,   required: false },
  timestamp:           { type: Number,   required: false },
  email:               { type: String,   required: false },
  location: {
    latitude:  { type: Number, required: false },
    longitude: { type: Number, required: false }
  },
  imageBase64:         { type: String,   required: false }
});

module.exports = mongoose.model('Report', ReportSchema);