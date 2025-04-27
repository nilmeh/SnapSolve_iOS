const admin = require('firebase-admin');
const serviceAccount = require(`${__dirname}/serviceAccountKey.json`);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Middleware to verify Firebase ID Token
const authMiddleware = async (req, res, next) => {
    const token = req.headers.authorization && req.headers.authorization.split(' ')[1]; // Extract token from Authorization header
    if (!token) {
      return res.status(403).json({ message: 'Unauthorized' });
    }
  
    try {
      const decodedUser = await admin.auth().verifyIdToken(token);  // Verifies Firebase ID Token
      req.user = decodedUser;  // Attach user data to request for later use
      next();  // Move to the next route handler
    } catch (error) {
      res.status(401).json({ message: 'Invalid or expired token' });
    }
  };
  
  module.exports = { authMiddleware, admin };