const express = require('express');
const {applyAttendance, getFullCalendar } = require('../controller/attendanceController');
const {verifyToken} = require('../middleware/authMiddleware')


const router = express.Router();

// Apply Attendance (Leave/On-duty)
router.post('/apply', verifyToken, applyAttendance);

// Get Calendar Data
router.get('/getFullCalendar', verifyToken, getFullCalendar);

module.exports = router;
