// routes/analyze.js
require('dotenv').config();
const express = require('express');
const axios   = require('axios');
const router  = express.Router();

const GEMINI_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
const GEOCODE_URL = 'https://maps.googleapis.com/maps/api/geocode/json';

/**
 * Reverse-geocode lat/lng into:
 *  - formatted_address: string
 *  - address_components: [{ long_name, types: [...] }, …]
 *  - isPrivate: boolean (establishment, university, etc)
 */
async function reverseGeocode(lat, lng) {
  const resp = await axios.get(GEOCODE_URL, {
    params: { latlng: `${lat},${lng}`, key: process.env.GOOGLE_MAPS_API_KEY }
  });
  const result = resp.data.results?.[0];
  if (!result) {
    return { formatted_address: `${lat},${lng}`, address_components: [], isPrivate: false };
  }

  const components = result.address_components;
  const types = components.flatMap(c => c.types);

  // types that imply private property
  const privateTypes = new Set([
    'establishment','university','school','hospital','point_of_interest',
    'premise','subpremise'
  ]);
  const isPrivate = types.some(t => privateTypes.has(t));

  return {
    formatted_address: result.formatted_address,
    address_components: components,
    isPrivate
  };
}

router.post('/', async (req, res) => {
  const { imageBase64, latitude, longitude } = req.body;
  if (!imageBase64) {
    return res.status(400).json({ error: 'Missing imageBase64' });
  }

  try {
    // 1) Reverse-geocode
    const { formatted_address, address_components, isPrivate } =
      await reverseGeocode(latitude, longitude);

    // 2) Build full location metadata object
    const locationMeta = {
      latitude,
      longitude,
      address: formatted_address,
      components: address_components
    };

    // 3) Build prompt giving Gemini the full metadata plus the image
    const prompt = `
      You are analyzing an urban infrastructure report.
      Here is the location metadata (JSON):
      ${JSON.stringify(locationMeta, null, 2)}

      Based on that metadata:
      - Decide whether this is private property (campus, building, etc.) or public city-managed.
      - Identify the problem in the attached image (e.g., pothole, broken light, graffiti). If you can't identify the problem, say "unknown".
      - Recommend exactly which authority or department to notify, and search the web for their contact email.

      Respond with a JSON object only, with exactly these keys:
      {
        "description": "short description of the problem",
        "recommendation": "department or authority to notify",
        "email": "contact email address"
      }
      No extra text, no markdown, no explanation.
    `.trim();

    // 4) Prepare Gemini payload
    const payload = {
      contents: [{
        parts: [
          { text: prompt },
          { inlineData: { mimeType: 'image/jpeg', data: imageBase64 } }
        ]
      }]
    };

    // 5) Call Gemini
    const geminiResp = await axios.post(
      `${GEMINI_URL}?key=${process.env.GEMINI_API_KEY}`,
      payload,
      { headers: { 'Content-Type': 'application/json' }, timeout: 15000 }
    );

    // 6) Extract and parse response
    const raw = geminiResp.data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!raw) throw new Error('No response text from Gemini');

    const cleaned = raw
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim();

    const { description, recommendation, email } = JSON.parse(cleaned);
    console.log('Parsed result:', { description, recommendation, email });

    // 7) Return to client
    return res.json({ description, recommendation, email });

  } catch (err) {
    console.error('Error in /api/analyze:', err.response?.data || err.message);
    return res.status(500).json({ error: err.message || 'Analysis failed' });
  }
});

module.exports = router;