const mongoose = require('mongoose');

const AttendanceSchema = new mongoose.Schema({
    employeeId: { type: String, required: true },
    name: { type: String, required: true },
    year: { type: Number, required: true }, // Logical grouping by year
    entries: [
        {
            date: { type: String, required: true }, // Format: 'YYYY-MM-DD'
            status: { type: String, enum: ['leave', 'on-duty'], required: true },
            onDutyData: {
                location: { type: String },
                projectName: { type: String },
                remark: { type: String }
            },
            leaveData: {
                leaveType: { type: String },
                approverName: { type: String },
                remark: { type: String }
            }
        }
    ]
});

module.exports = mongoose.model('Attendance', AttendanceSchema);
