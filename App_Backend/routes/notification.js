const express = require('express');
const { setNotificationTime, getNotificationTime } = require('../controller/notificationController');
const { verifyToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Set notification time API
router.post('/set-notification-time', verifyToken, setNotificationTime);
router.get('/get-notification-time', verifyToken, getNotificationTime);

module.exports = router;
