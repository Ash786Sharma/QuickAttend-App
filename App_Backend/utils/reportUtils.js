const moment = require('moment');
const Excel = require('xlsx');
const fs = require('fs');
const path = require('path');

exports.generateReportData = (users, attendanceRecords, holidays, weeklyOffDays, startDate, endDate) => {
    const reportData = [];
    users.forEach((user) => {
      const userAttendance = attendanceRecords.filter((record) => record.employeeId === user.employeeId);
      const attendanceMap = new Map(
        userAttendance.flatMap((record) => record.entries.map((entry) => [entry.date, entry]))
      );
  
      for (let date = moment(startDate); date.isSameOrBefore(endDate); date.add(1, 'days')) {
        const formattedDate = date.format('YYYY-MM-DD');
        const isHoliday = holidays.includes(formattedDate);
        const isWeeklyOff = weeklyOffDays.includes(formattedDate);
  
        const entry = attendanceMap.get(formattedDate);
  
        let status = 'Absent';
        if (isHoliday || isWeeklyOff) {
          status = isHoliday ? 'Holiday' : 'Weekly Off';
          if (entry?.status === 'on-duty') {
            status = `On-Duty (${status})`;
          }
        } else if (entry) {
          status = entry.status === 'leave' ? 'Leave' : entry.status === 'on-duty' ? 'On-Duty' : 'Present';
        }
  
        reportData.push({
          'Employee Name': user.name,
          'Employee ID': user.employeeId,
          Date: formattedDate,
          Status: status,
          'On-Duty Location': entry?.onDutyData?.location || '',
          'On-Duty Project': entry?.onDutyData?.projectName || '',
          'On-Duty Remark': entry?.onDutyData?.remark || '',
          'Leave Type': entry?.leaveData?.leaveType || '',
          'Leave Approver': entry?.leaveData?.approverName || '',
          'Leave Remark': entry?.leaveData?.remark || '',
        });
      }
    });
    return reportData;
  };

exports.createAndSendExcel = async (res, reportData, fileName, sheetName) => {
    const workbook = Excel.utils.book_new();
    const worksheet = Excel.utils.json_to_sheet(reportData);
    Excel.utils.book_append_sheet(workbook, worksheet, sheetName);
  
    const filePath = path.join(__dirname, 'reports', fileName);
    if (!fs.existsSync(path.join(__dirname, 'reports'))) {
      fs.mkdirSync(path.join(__dirname, 'reports'), { recursive: true });
    }
    Excel.writeFile(workbook, filePath);
  
    res.download(filePath, fileName, (err) => {
      if (err) {
        console.error('Error sending file:', err);
        res.status(500).json({ success: false, message: 'Error generating report' });
      } else {
        fs.unlinkSync(filePath);
      }
    });
  };
  
  