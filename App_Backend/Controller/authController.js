const User = require('../models/User');
const {generateToken, protect} = require('../utils/jwtToken');

module.exports.registerUser = async (req, res) => {
    try {
        const { name, employeeId } = req.body;

        // Check if a user with the same name and employeeId already exists
        const existingUser = await User.findOne({ name, employeeId });
        if (existingUser) {
            return res.status(200).json({ message: 'User already exists' });
        }

        // Create and save the new user
        const newUser = new User({ name, employeeId });
        await newUser.save();

        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        res.status(500).json({ error: 'Error registering user', details: err.message });
    }
};


module.exports.loginUser = async (req, res) => {

    const { employeeId } = req.body;


    // Check for missing fields
    if (!employeeId ) {
        return res.status(400).json({error: 'Employee ID and biometric authentication are required' });
    }
    try {

        const Users = await User.findOne({ employeeId });
        if (!Users) return res.status(404).json({success: false, error: 'User not found' });

        // Update last login
        Users.lastLogin = new Date();
        await Users.save();

        const token = generateToken(Users)

        res.status(200).json({
            success: true,
            message: 'Login successful',
            token
        });
    } catch (err) {
        res.status(500).json({ success: false, error: 'Error logging in', details: err.message });
    }
};
