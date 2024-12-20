const express = require('express');
const {applyAttendance, getFullCalendar } = require('../Controller/attendanceController');
const {verifyToken} = require('../Middleware/authMiddleware')


const router = express.Router();

// Apply Attendance (Leave/On-duty)
router.post('/apply', verifyToken, applyAttendance);

// Get Calendar Data
router.get('/getFullCalendar', verifyToken, getFullCalendar);

module.exports = router;
