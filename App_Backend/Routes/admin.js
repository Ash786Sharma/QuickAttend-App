const express = require('express');
const {verifyToken, verifyRole} = require('../middleware/authMiddleware')
const {
    updateUserData,
    setHolidays,
    setDefaultWeekoffs,
    addSelectedWeeklyOff,
    removeWeeklyOff,
    getUserByEmployeeId,
    fetchUsers,
    deleteUser,
    deleteAllUsers,
    getWeeklyOffDates,
    getHolidays
} = require('../controller/adminController');
const { generateYearlyReport, generateMonthlyReport } = require('../controller/reportController');

const router = express.Router();

// Update Admin Settings (Holidays, Weekly Offs)

// Fetch holiday dates
router.post('/setHolidays', verifyToken, verifyRole('admin'), setHolidays);
router.get('/getHolidays', verifyToken, verifyRole('admin'), getHolidays);
// Fetch weekly off dates
router.get('/getWeeklyOffs', verifyToken, verifyRole('admin'), getWeeklyOffDates);
router.get('/setDefaultWeeklyoffs', verifyToken, verifyRole('admin'), setDefaultWeekoffs);
router.post('/addSelectedWeeklyOff', verifyToken, verifyRole('admin'), addSelectedWeeklyOff)
router.delete('/removeWeeklyOff', verifyToken, verifyRole('admin'), removeWeeklyOff)

// Update User Data (if needed)
router.get('/searchUser/:employeeId', verifyToken, verifyRole('admin'), getUserByEmployeeId);
router.post('/user/:employeeId', verifyToken, verifyRole('admin'), updateUserData);
router.get('/user/getUsers', verifyToken, verifyRole('admin'), fetchUsers)
router.delete('/user/deleteUser/:employeeId', verifyToken, verifyRole('admin'), deleteUser)
router.delete('/user/deleteAllUsers', verifyToken, verifyRole('admin'), deleteAllUsers)

router.get('/reports/yearly/:year/:employeeId?', verifyToken, verifyRole('admin'), generateYearlyReport);
router.get('/reports/monthly/:year/:month/:employeeId?', verifyToken, verifyRole('admin'), generateMonthlyReport);

module.exports = router;
