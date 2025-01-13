const jwt = require('jsonwebtoken');

// Generate JWT Token
exports.generateToken = (userData) => {
    return jwt.sign({ userData }, process.env.JWT_SECRET, {
        expiresIn: '7d', // Token valid for 7 days
    });
};
