const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    employeeId: { type: String, unique: true, required: true },
    role: { type: String, default: "regular" }, // 'admin' or 'regular'
    lastLogin: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
