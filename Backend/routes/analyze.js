// routes/analyze.js
require('dotenv').config();
const express = require('express');
const axios = require('axios');
const router = express.Router();

const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

router.post('/analyze', async (req, res) => {
  console.log('POST /api/analyze triggered');
  console.log('Request headers:', req.headers);
console.log('Request body size:', JSON.stringify(req.body).length, 'bytes');
  console.log('POST /api/analyze received:', req.body);
  const { imageBase64, latitude, longitude } = req.body;

  if (!imageBase64) {
    console.log('Error: Missing imageBase64');
    return res.status(400).json({ error: 'Missing imageBase64' });
  }

  const prompt = `
    Analyze this image and identify any urban infrastructure issues
    (e.g., potholes, broken streetlights, damaged bike racks).
    Respond ONLY with JSON: {"description":"...","recommendation":"..."}.
  `;

  const payload = {
    contents: [
      {
        parts: [
          { text: prompt },
          { inlineData: { mimeType: 'image/jpeg', data: imageBase64 } }
        ]
      }
    ]
  };

  try {
    console.log('Calling Gemini API');
    const response = await axios.post(
      `${GEMINI_URL}?key=${process.env.GEMINI_API_KEY}`,
      payload,
      { headers: { 'Content-Type': 'application/json' },
      timeout: 15000 
    }
    );

    const text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
    console.log('Gemini raw text:', text);

    if (!text) throw new Error('No text in Gemini response');

    const cleaned = text.replace(/```json/g, '').replace(/```/g, '').trim();
    console.log('Cleaned text:', cleaned);

    const { description, recommendation } = JSON.parse(cleaned);
    console.log('Parsed result:', { description, recommendation });

    res.json({ description, recommendation });
  } catch (error) {
    console.error('Error in /api/analyze:', error.message || error);
    res.status(500).json({ error: error.message || 'Analysis failed' });
  }
});

module.exports = router;