const Attendance = require('../Models/test');

// Apply Attendance (Unified Approach)
exports.applyAttendance = async (req, res) => {
    try {
        const { employeeId, name, date, status, location, projectName, remark, leaveType, approverName } = req.body;

        // Validation
        if (!employeeId || !name || !date || !status) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const year = new Date(date).getFullYear();

        // Find or create attendance document for the employee and year
        let attendance = await Attendance.findOne({ employeeId, year });

        if (!attendance) {
            attendance = new Attendance({
                employeeId,
                name,
                year,
                entries: []
            });
        }

        // Check if entry for the specific date already exists
        const existingEntry = attendance.entries.find(entry => entry.date === date);

        if (existingEntry) {
            // Update the existing entry
            existingEntry.status = status;
            existingEntry.onDutyData = status === 'on-duty' ? { location, projectName, remark } : null;
            existingEntry.leaveData = status === 'leave' ? { leaveType, approverName, remark } : null;
        } else {
            // Add a new entry
            attendance.entries.push({
                date,
                status,
                onDutyData: status === 'on-duty' ? { location, projectName, remark } : null,
                leaveData: status === 'leave' ? { leaveType, approverName, remark } : null
            });
        }

        // Save the document
        await attendance.save();

        res.status(201).json({ message: 'Attendance applied successfully', attendance });
    } catch (err) {
        console.error('Error applying attendance:', err);
        res.status(500).json({ error: 'Error applying attendance', details: err.message });
    }
};
