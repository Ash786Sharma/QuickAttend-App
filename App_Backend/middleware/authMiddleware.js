const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Adjust the path to your User model

// Middleware to verify JWT and attach user data
const verifyToken = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1]; // Extract Bearer token
        if (!token) {
            return res.status(401).json({success: false, error: 'No token provided, authorization denied.' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.userData._id); // Ensure ID matches database

        if (!user) {
            return res.status(401).json({success: false, error: 'User not found, authorization denied.' });
        }

        req.user = user; // Attach user data to request
        next();
    } catch (err) {
        console.error('JWT verification error:', err);
        res.status(401).json({success: false, error: 'Invalid token, authorization denied.' });
    }
};

// Middleware for role-based access control
const verifyRole = (requiredRole) => {
    return (req, res, next) => {
        if (!req.user || req.user.role !== requiredRole) {
            return res.status(403).json({success: false, error: 'Access denied. Insufficient permissions.' });
        }
        next();
    };
};

module.exports = { verifyToken, verifyRole };
