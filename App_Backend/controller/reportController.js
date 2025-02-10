const moment = require('moment');

const Attendance = require('../models/Attendance');
const AdminSettings = require('../models/AdimnSettings');
const User = require('../models/User');
const {generateReportData, createAndSendExcel} = require('../utils/reportUtils')

exports.generateYearlyReport = async (req, res) => {
    try {
      const { year, employeeId } = req.params;
  
      // Validate year
      if (!year) {
        return res.status(400).json({ success: false, message: 'Year is required' });
      }
  
      const startDate = moment(`${year}-01-01`, 'YYYY-MM-DD');
      const endDate = moment(startDate).endOf('year');
  
      if (!startDate.isValid()) {
        return res.status(400).json({ success: false, message: 'Invalid year provided' });
      }
  
      // Fetch users and optionally filter by employeeId
      const userFilter = employeeId ? { employeeId } : {};
      const users = await User.find(userFilter);
      if (employeeId && users.length === 0) {
        return res.status(404).json({ success: false, message: 'Employee not found' });
      }
  
      // Fetch admin settings and attendance records
      const adminSettings = await AdminSettings.findOne();
      const holidays = adminSettings?.holidays || [];
      const weeklyOffDays = adminSettings?.weeklyOffs || [];
      const attendanceRecords = await Attendance.find({
        'entries.date': { $gte: startDate.format('YYYY-MM-DD'), $lte: endDate.format('YYYY-MM-DD') },
      });
  
      // Prepare report data
      const reportData = generateReportData(users, attendanceRecords, holidays, weeklyOffDays, startDate, endDate);
  
      // Generate Excel file
      const fileName = `Yearly_Report_${year}${employeeId ? `_${employeeId}` : ''}_${moment().format('YYYYMMDD_HHmmssSSS')}.xlsx`;

      await createAndSendExcel(res, reportData, fileName, 'Yearly Report');
    } catch (error) {
      console.error('Error generating yearly report:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
    }
  };

  
  exports.generateMonthlyReport = async (req, res) => {
    try {
      const { year, month, employeeId } = req.params;
  
      // Validate year and month
      if (!year || !month) {
        return res.status(400).json({ success: false, message: 'Year and month are required' });
      }
  
      const startDate = moment(`${year}-${month}-01`, 'YYYY-MM-DD');
      const endDate = moment(startDate).endOf('month');
  
      if (!startDate.isValid()) {
        return res.status(400).json({ success: false, message: 'Invalid date provided' });
      }
  
      // Fetch users and optionally filter by employeeId
      const userFilter = employeeId ? { employeeId } : {};
      const users = await User.find(userFilter);
      if (employeeId && users.length === 0) {
        return res.status(404).json({ success: false, message: 'Employee not found' });
      }
  
      // Fetch admin settings and attendance records
      const adminSettings = await AdminSettings.findOne();
      const holidays = adminSettings?.holidays || [];
      const weeklyOffDays = adminSettings?.weeklyOffs || [];
      const attendanceRecords = await Attendance.find({
        'entries.date': { $gte: startDate.format('YYYY-MM-DD'), $lte: endDate.format('YYYY-MM-DD') },
      });
  
      // Prepare report data
      const reportData = generateReportData(users, attendanceRecords, holidays, weeklyOffDays, startDate, endDate);
  
      // Generate Excel file
      const fileName = `Monthly_Report_${year}_${month}${employeeId ? `_${employeeId}` : ''}_${moment().format('YYYYMMDD_HHmmssSSS')}.xlsx`;

      await createAndSendExcel(res, reportData, fileName, 'Monthly Report');
    } catch (error) {
      console.error('Error generating monthly report:', error);
      res.status(500).json({ success: false, message: 'Internal Server Error', error: error.message });
    }
  };
  