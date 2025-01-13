const mongoose = require('mongoose');

const AdminSettingsSchema = new mongoose.Schema({
    holidays: [String], // Array of holiday dates in 'YYYY-MM-DD' format
    weeklyOffs: [String], // Array of default weekly-off days (e.g., ['Saturday', 'Sunday'])    
    },
);

module.exports = mongoose.model('AdminSettings', AdminSettingsSchema);
