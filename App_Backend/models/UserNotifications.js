const mongoose = require('mongoose');

const UserNotificationSchema = new mongoose.Schema({
    employeeId: { type: String, unique: true, required: true },
    notificationEnabled: { type: Boolean, default: false}, // user notification enabled
    notificationTime: { type: String }, // user notification time
    notificationTime_UTC: { type: String }, // user notification time in UTC
    timeZone: { type: String },
    pendingNotification: {type: Boolean, default: false}, // user time zone
});

module.exports = mongoose.model('UserNotification', UserNotificationSchema);