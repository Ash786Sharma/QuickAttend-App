const express = require('express');
const {registerUser, loginUser} = require('../controller/authController');

const router = express.Router();

// Register API
router.post('/register', registerUser);

// Login API
router.post('/login', loginUser);

module.exports = router;
