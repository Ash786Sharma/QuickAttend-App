const express = require('express');
const http = require('http');
const cors = require('cors');
const dotenv = require('dotenv');
const socketIo = require('socket.io');
const connectDB = require('./database/database');
const UserNotification = require('./models/UserNotifications'); // Import the UserNotification model
//const notificationService = require('./services/notificationScheduleService'); // Import the notification service
const auth = require('./routes/auth')
const attendance = require('./routes/attendance')
const admin = require('./routes/admin')
const notification = require('./routes/notification');

const userSockets = {}; // Mapping of userId to socketId


// Load environment variables
dotenv.config({path: "./Config/config.env"});

// Connect to MongoDB
connectDB();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, { cors: { origin: '*' } });

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', auth);
app.use('/api/attendance', attendance);
app.use('/api/admin', admin);
app.use('/api/notifications', notification);



// Initialize notification service
//notificationService(io, userSockets);

io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);

    // Register user with their userId
    socket.on('register_user', async (userId) => {
        userSockets[userId] = socket.id; // Map userId to socketId
        console.log(`User ${userId} registered with socket ${socket.id}`);

        //try {
           // Check if the user has pending notifications
        //    const user = await UserNotification.findOne({ employeeId: userId, pendingNotification: true });
        //    console.log('User:', user);
        //    
        //    if (user) {
        //        const message = `This is your pending daily notification!`;
        //        console.log('Emitting pending notification to user:', userId);
                // Emit the notification
        //        io.to(socket.id).emit('daily-notification-pending');
        //
                // Reset the pendingNotification flag
        //        await UserNotification.updateOne(
        //            { employeeId: userId },
        //            { $set: { pendingNotification: false } }
        //        );
        //    }
        //} catch (error) {
        //    console.error('Error sending pending notifications:', error);
        //}
    });

    // Global calendar refresh for weekly off or holiday updates
    socket.on('update_WeeklyOffOrHoliday', () => {
        //console.log('Weekly off or holiday updated');
        io.emit('refresh_calendar');
    });

    // User-specific calendar refresh
    socket.on('apply_attendance', ( userId ) => {
        const targetSocketId = userSockets[userId];
        if (targetSocketId) {
            //console.log(`Refreshing calendar for user ${userId}`);
            io.to(targetSocketId).emit('refresh_calendar_user');
        } else {
            console.log(`User ${userId} not connected`);
        }
    });

    // Handle disconnection
    socket.on('disconnect', () => {
        console.log('Client disconnected:', socket.id);
        // Remove the user from the mapping
        const disconnectedUser = Object.keys(userSockets).find(
            (userId) => userSockets[userId] === socket.id
        );
        if (disconnectedUser) {
            delete userSockets[disconnectedUser];
        }
    });
});

app.get('/', (req, res) => {
    res.send('Server is running');
});

// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
