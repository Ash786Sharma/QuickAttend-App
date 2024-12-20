const moment = require('moment'); // Install moment for date manipulations
const Attendance = require('../models/Attendance');
const AdminSettings = require('../Models/AdimnSettings'); // Ensure the path is correct

// Apply Attendance (Unified Approach)
exports.applyAttendance = async (req, res) => {
    try {
        const {employeeId, role} = req.user
        const { date, status, location, projectName, remark, leaveType, approverName } = req.body;

        // Validation: Check required fields
        if (!employeeId || !date || !status || !role) {
            console.log(req.body);
            return res.status(400).json({ success: false, error: 'Missing required fields' });
        }

        // Determine if the date is a range or a single date
        const isRange = date.includes(' - ');
        const dates = isRange
            ? generateDateRange(date.split(' - ')[0], date.split(' - ')[1])
            : [date];

        // Validation: Check for future dates
        const today = moment().startOf('day');
        const invalidDates = dates.filter((d) => moment(d).isAfter(today));
        if (invalidDates.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'Date or range includes future dates',
                invalidDates,
            });
        }

        const year = moment(dates[0]).year();

        // Retrieve admin settings (holidays, weekly offs)
        const adminSettings = await AdminSettings.findOne();
        if (!adminSettings) {
            return res.status(404).json({ success: false, error: 'Admin settings not found' });
        }

        const holidays = adminSettings.holidays || [];
        const weeklyOffs = adminSettings.weeklyOffs || [];

        // Restriction for Regular Users: Cannot reapply leave or on-duty
        if (role !== 'admin') {
            let attendance = await Attendance.findOne({ employeeId, year });
            if (attendance) {
                const conflictingDates = dates.filter((currentDate) =>
                    attendance.entries.some(
                        (entry) =>
                            entry.date === currentDate &&
                            (entry.status === 'leave' || entry.status === 'on-duty')
                    )
                );

                if (conflictingDates.length > 0) {
                    return res.status(403).json({
                        success: false,
                        error: 'Leave or on-duty already applied on these dates',
                        conflictingDates,
                    });
                }
            }
        }

        // Filter out invalid leave dates (holidays and weekly offs)
        if (status === 'leave') {
            const nonApplicableDates = dates.filter((date) => {
                return holidays.includes(date) || weeklyOffs.includes(date);
            });

            if (nonApplicableDates.length > 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Leave cannot be applied on holidays or weekly offs',
                    nonApplicableDates,
                });
            }
        }

        // Find or create attendance document
        let attendance = await Attendance.findOne({ employeeId, year });
        if (!attendance) {
            attendance = new Attendance({
                employeeId,
                year,
                entries: [],
            });
        }

        // Apply attendance for each date
        dates.forEach((currentDate) => {
            const existingEntry = attendance.entries.find((entry) => entry.date === currentDate);
            if (existingEntry) {
                // Update the existing entry
                existingEntry.status = status;
                existingEntry.onDutyData = status === 'on-duty' ? { location, projectName, remark } : null;
                existingEntry.leaveData = status === 'leave' ? { leaveType, approverName, remark } : null;
            } else {
                // Add a new entry
                attendance.entries.push({
                    date: currentDate,
                    status,
                    onDutyData: status === 'on-duty' ? { location, projectName, remark } : null,
                    leaveData: status === 'leave' ? { leaveType, approverName, remark } : null,
                });
            }
        });

        // Save updated attendance document
        await attendance.save();

        res.status(201).json({ success: true, message: 'Attendance applied successfully', attendance });
    } catch (err) {
        console.error('Error applying attendance:', err);
        res.status(500).json({ success: false, error: 'Error applying attendance', details: err.message });
    }
};

// Helper function to generate date range
const generateDateRange = (startDate, endDate) => {
    const start = moment(startDate);
    const end = moment(endDate);
    const range = [];
    while (start.isSameOrBefore(end)) {
        range.push(start.format('YYYY-MM-DD'));
        start.add(1, 'days');
    }
    return range;
};



// Get Full Calendar with Admin and User Data
exports.getFullCalendar = async (req, res) => {
    try {
        const {employeeId} = req.user; // From authenticated user
        //console.log(employeeId);
        
        const year = parseInt(req.query.year, 10) || moment().year();

        // Fetch admin data
        const adminSettings = await AdminSettings.findOne();
        if (!adminSettings) {
            return res.status(404).json({ success: false, error: 'Admin settings not found' });
        }

        // Fetch user-specific entries
        const userEntries = await Attendance.findOne({ employeeId }) || { entries: [] };
        //console.log(userEntries);
        

        const holidays = adminSettings.holidays || [];
        const weeklyOffsDefault = adminSettings.weeklyOffs || [];

        // Generate all dates for the year
        const allDates = [];
        for (let month = 0; month < 12; month++) {
            const daysInMonth = moment({ year, month }).daysInMonth();
            for (let day = 1; day <= daysInMonth; day++) {
                allDates.push(moment({ year, month, day }).format('YYYY-MM-DD'));
            }
        }

        // Map calendar dates with statuses
        const calendar = allDates.map((date) => {
            const dayOfWeek = moment(date).format('dddd');
            let status = 'workingDay';

            // Admin-controlled logic
            if (holidays.includes(date)) {
                status = 'holiday';
            }
            if (status === 'workingDay' && weeklyOffsDefault.includes(date)) {
                status = 'weeklyOff';
            }
            if (status === 'holiday' && weeklyOffsDefault.includes(date)) {
                status = 'holiday&weeklyOff';
            }

            // User-specific logic
            const userEntry = userEntries.entries.find((entry) => entry.date === date);
            //console.log(userEntry);
            
            if (userEntry) {
                // Override admin-defined statuses with user attendance
                if (status === 'workingDay' && userEntry.status === 'leave') {
                    status = 'leave';
                } else if (status === 'workingDay' && userEntry.status === 'on-duty') {
                    status = 'onDuty';
                }else if (status === 'holiday' && userEntry.status === 'on-duty') {
                    status = 'onDuty&holiday';
                }
                else if (status === 'weeklyOff' && userEntry.status === 'on-duty') {
                    status = 'onDuty&weeklyOff';
                }else if (status === 'holiday&weeklyOff' && userEntry.status === 'on-duty') {
                    status = 'onDuty&holiday&weeklyOff';
                }
            }

            return { date, status };
        });

        res.status(200).json({ success: true, calendar });
    } catch (err) {
        console.error('Error fetching full calendar:', err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};
