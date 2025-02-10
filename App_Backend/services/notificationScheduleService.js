const cron = require('node-cron');
const moment = require('moment-timezone');
const UserNotification = require('../models/UserNotifications');

module.exports = (io, userSockets) => {
    
    cron.schedule('* * * * *', async () => {
        console.log('Notification scheduler started!');
        const currentUtcTime = moment.utc().format('HH:mm');
        const currentLocalTime = moment().format('YYYY-MM-DD HH:mm:ss');
        const currentLocalZone = moment.tz.guess();

        console.log(`UTC Time: ${currentUtcTime}`);
        console.log(`Local Time: ${currentLocalTime}`);
        console.log(`Local Time Zone: ${currentLocalZone}`);
        try {
            // Find users whose notification time matches the current UTC time
            const users = await UserNotification.find({
                notificationEnabled: true,
                notificationTime_UTC: currentUtcTime,
            });
            console.log('Users to notify:', users);
            
            for (const user of users) {
                // Check if the user is online
                console.log('User socketId:', userSockets[user.employeeId]);
                const targetSocketId = userSockets[user.employeeId];
                console.log('Target socketId:', targetSocketId);
                
                if (targetSocketId) {
                    // Send real-time notification
                    io.to(targetSocketId).emit('daily-notification');
                    console.log('Notification sent to user:', user.employeeId);
                    
                } else {
                    // Update the pendingNotification flag if user is offline
                    await UserNotification.updateOne(
                        { employeeId: user.employeeId },
                        { $set: { pendingNotification: true } }
                    );
                }
            }
        } catch (error) {
            console.error('Error processing notifications:', error);
        }
    });
};