const UserNotification = require('../models/UserNotifications');
const moment = require('moment-timezone');

exports.setNotificationTime = async (req, res) => {
    const { employeeId } = req.user; // Extract employeeId from route parameters
    const { notificationTime, timeZone } = req.body;

    try {
        // Convert local time to UTC
        const notificationTime_UTC = moment.tz(notificationTime, 'HH:mm', timeZone).utc().format('HH:mm');

        // Upsert user preferences in MongoDB
        await UserNotification.findOneAndUpdate(
            { employeeId },
            {
                $set: {
                    notificationEnabled: true,
                    notificationTime,
                    notificationTime_UTC,
                    timeZone,
                },
            },
            { upsert: true, new: true }
        );

        res.status(200).json({ success: true, message: 'Notification time set successfully!' });
    } catch (err) {
        console.log('Error setting notification time:', err);
        
        res.status(500).json({ success: false, error: 'Error setting notification time', details: err.message});
    }
};


exports.getNotificationTime = async (req, res) => {
    const { employeeId } = req.user; // Extract employeeId from route parameters

    try {
        // Find the user's notification settings
        const notificationData = await UserNotification.findOne({ employeeId });

        if (!notificationData) {
            return res.status(404).json({
                success: false,
                message: 'Notification settings not found for this user.',
            });
        }

        res.status(200).json({
            success: true,
            notificationEnabled: notificationData.notificationEnabled,
            notificationTime: notificationData.notificationTime,
            notificationTime_UTC: notificationData.notificationTime_UTC,
            pendingNotification: notificationData.pendingNotification,
            timeZone: notificationData.timeZone,
        });
    } catch (err) {
        console.log('Error fetching notification settings:', err);
        res.status(500).json({
            success: false,
            error: 'Error fetching notification settings'
        });
    }
};

