const moment = require('moment'); // Install moment for date manipulations
const AdminSettings = require('../Models/AdimnSettings');
const User = require('../models/User');

// Update Calendar Settings (Holidays, Weekly Offs)
exports.setHolidays = async (req, res) => {
    try {
        const { holidays } = req.body;
        
        // Upsert (Update if exists, otherwise create)
        const settings = await AdminSettings.findOneAndUpdate(
            {},
            { holidays },
            { new: true, upsert: true }
        );

        res.status(200).json({success: true, message: 'Holidays Settings updated successfully', settings });
    } catch (err) {
        res.status(500).json({success: false, error: 'Error updating settings', details: err.message });
    }
};

// Fetch Holiday Dates
exports.getHolidays = async (req, res) => {
    try {
        // Fetch the document from the AdminSettings collection
        const settings = await AdminSettings.findOne({}, 'holidays'); // Fetch only the `holidays` field

        if (!settings || !settings.holidays) {
            return res.status(404).json({
                success: false,
                message: 'No holiday dates found in the database.',
            });
        }

        res.status(200).json({
            success: true,
            message: 'Holiday dates fetched successfully.',
            holidays: settings.holidays,
        });
    } catch (err) {
        console.error('Error fetching holiday dates:', err);
        res.status(500).json({
            success: false,
            error: 'Internal Server Error',
            details: err.message,
        });
    }
};

exports.setDefaultWeekoffs = async (req, res) => {
    try {
        const year = parseInt(req.query.year, 10) || moment().year();
        const weeklyOffDates = []; // To store the weekly off dates

        for (let month = 0; month < 12; month++) {
            const daysInMonth = moment({ year, month }).daysInMonth();

            const saturdays = [];
            const sundays = [];

            for (let day = 1; day <= daysInMonth; day++) {
                const currentDate = moment({ year, month, day });
                const dayOfWeek = currentDate.day(); // Sunday = 0, Monday = 1, ..., Saturday = 6

                if (dayOfWeek === 0) { // Sunday
                    sundays.push(currentDate.format('YYYY-MM-DD'));
                } else if (dayOfWeek === 6) { // Saturday
                    saturdays.push(currentDate.format('YYYY-MM-DD'));
                }
            }

            // Add all Sundays
            weeklyOffDates.push(...sundays);

            // Add 1st and 3rd Saturdays
            if (saturdays.length >= 1) weeklyOffDates.push(saturdays[0]); // 1st Saturday
            if (saturdays.length >= 3) weeklyOffDates.push(saturdays[2]); // 3rd Saturday
        }

        // Upsert (Update if exists, otherwise create)
        const settings = await AdminSettings.findOneAndUpdate(
            {}, // Match any document (singleton design)
            { 'weeklyOffs': weeklyOffDates }, // Update the weekly off dates
            { new: true, upsert: true } // Create if not exists
        );

        res.status(200).json({success: true, message: 'Default weeklyoffs generated successfully', settings });
    } catch (err) {
        res.status(500).json({success: false, error: 'Error updating settings', details: err.message });
    }
};

// Fetch Weekly Off Dates
exports.getWeeklyOffDates = async (req, res) => {
    try {
        // Fetch the document from the AdminSettings collection
        const settings = await AdminSettings.findOne({}, 'weeklyOffs'); // Fetch only the `weeklyOffs` field

        if (!settings || !settings.weeklyOffs) {
            return res.status(404).json({
                success: false,
                message: 'No weekly off dates found in the database.',
            });
        }

        res.status(200).json({
            success: true,
            message: 'Weekly off dates fetched successfully.',
            weeklyOffs: settings.weeklyOffs,
        });
    } catch (err) {
        console.error('Error fetching weekly off dates:', err);
        res.status(500).json({
            success: false,
            error: 'Internal Server Error',
            details: err.message,
        });
    }
};

exports.addSelectedWeeklyOff = async (req, res) => {
    const { date } = req.body;

    // Validate date format
    if (!date || !moment(date, 'YYYY-MM-DD', true).isValid()) {
        return res.status(400).json({ success: false, message: 'Invalid or missing date' });
    }

    try {
        // Add the single date to the `weeklyOffs` array if it doesn't already exist
        const settings = await AdminSettings.findOneAndUpdate(
            {}, // Match any document (singleton design)
            { $addToSet: { weeklyOffs: date } }, // Add the single date only if it doesn't already exist
            { new: true, upsert: true } // Create document if it doesn't exist
        );

        res.status(200).json({ success: true, message: 'Weekly off added successfully', settings });
    } catch (err) {
        console.error('Error adding selected weekly off:', err);
        res.status(500).json({ success: false, error: 'Error adding weekly off', details: err.message });
    }
};

exports.removeWeeklyOff = async (req, res) => {
    const { date } = req.body;

    if (!date || !moment(date, 'YYYY-MM-DD', true).isValid()) {
        return res.status(400).json({ success: false, message: 'Invalid or missing date' });
    }

    try {
        // Remove the date from the weeklyOffs array
        const settings = await AdminSettings.findOneAndUpdate(
            {}, // Match any document
            { $pull: { weeklyOffs: date } }, // Remove the specific date
            { new: true } // Return the updated document
        );

        if (!settings) {
            return res.status(404).json({ success: false, message: 'No settings document found' });
        }

        res.status(200).json({ success: true, message: 'Weeklyoff removed successfully', settings });
    } catch (err) {
        console.error('Error removing weekly off:', err);
        res.status(500).json({ success: false, error: 'Error removing weekly off', details: err.message });
    }
};

// GET /api/auth/user/:employeeId
exports.getUserByEmployeeId = async (req, res) => {
    try {
        const { employeeId } = req.params;
        
        if (!employeeId) {
            return res.status(404).json({ success: false, error: 'EmployeeId not found' });
        }
        
        const user = await User.findOne({ employeeId });
        
        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        res.status(200).json({success: true, message: 'User found Successfully', user});
    } catch (err) {
        console.error('Error fetching user:', err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};


// Update User Data
exports.updateUserData = async (req, res) => {
    try {
        const { employeeId } = req.params; // Extract current employeeId from params
        const { name, newEmployeeId, role} = req.body; // Allow changing employeeId
        
        // Search and update the user
        const user = await User.findOneAndUpdate(
            { employeeId }, // Query by current employeeId
            { 
                name, 
                employeeId: newEmployeeId || employeeId, // Update to newEmployeeId if provided
                role, 
            },
            { new: true } // Return the updated document
        );
        
        if (!user) {
            return res.status(404).json({success: false, error: 'User not found' });
        }

        res.status(200).json({success: true, message: 'User data updated successfully', user });
    } catch (err) {
        res.status(500).json({success: false, error: 'Error updating user data', details: err.message });
    }
};

// Fetch all users
exports.fetchUsers = async (req, res) => {
    try {
        const users = await User.find(); // Fetch all users from the database
        res.status(200).json({
            success: true,
            users,
        });
    } catch (err) {
        console.error('Error fetching users:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch users', details: err.message
        });
    }
};

// Delete a specific user
exports.deleteUser = async (req, res) => {
    try {
        const { employeeId } = req.params;

        if (!employeeId) {
            return res.status(404).json({
                success: false,
                message: 'Invalid employeeId',
            });
        }

        await User.deleteOne({employeeId}); // Delete the user
        res.status(200).json({
            success: true,
            message: 'User deleted successfully',
        });
    } catch (err) {
        console.error('Error deleting user:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to delete user', details: err.message
        });
    }
};

// Delete all users
exports.deleteAllUsers = async (req, res) => {
    try {
        await User.deleteMany(); // Delete all users from the database
        res.status(200).json({
            success: true,
            message: 'All users deleted successfully',
        });
    } catch (err) {
        console.error('Error deleting all users:', err);
        res.status(500).json({
            success: false,
            message: 'Failed to delete all users', details: err.message
        });
    }
};
