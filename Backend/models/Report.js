// models/Report.js
const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
  problem_description: { type: String,   required: true },
  recommendation:      { type: String,   required: true },
  timestamp:           { type: Number,   required: true },
  email:               { type: String,   required: true },
  location: {
    latitude:  { type: Number, required: true },
    longitude: { type: Number, required: true }
  },
  imageBase64:         { type: String,   required: true }
}); 

module.exports = mongoose.model('Report', ReportSchema);