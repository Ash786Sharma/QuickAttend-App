# QuickAttend Flutter App_Backend

## Project Folder Structure

This document provides an overview of the folder structure and the purpose of each file in the project.

## Root Directory

```json
App_Backend/
│── config/                  # Configuration files
│   ├── config.env           # Environment variables (MongoDB URI, JWT Secret)
│── controllers/             # Controllers for handling business logic
│   ├── authController.js    
│   ├── adminController.js   
│   ├── attendanceController.js  
│   ├── notificationController.js  
│   ├── reportController.js  
│── database/                # Database connection setup
│   ├── database.js  
│── middleware/              # Middleware functions
│   ├── authMiddleware.js    # JWT authentication & role verification
│── models/                  # MongoDB schemas
│   ├── AdminSettings.js  
│   ├── Attendance.js  
│   ├── User.js  
│   ├── UserNotifications.js  
│── routes/                  # API routes
│   ├── admin.js  
│   ├── attendance.js  
│   ├── auth.js  
│   ├── notification.js  
│── services/                # Additional services
│   ├── notificationScheduleService.js # Server-side notification scheduling
│── utils/                   # Utility functions
│   ├── jwtToken.js          # JWT Token generation
│   ├── report.js            # Excel report generation
│── server.js                # Entry point of the application
│── package.json             # Project dependencies & scripts
│── README.md                # Documentation

```

### 1. **server.js**

The entry point of the Node.js application. It initializes the Express server, Socket.io, and connects to the MongoDB database.

---

## Folders and Their Descriptions

### 2. **config/**

Contains configuration-related files.

- **config.env** – Stores environment variables such as MongoDB URI, PORT and JWT secret.

### 3. **controllers/**

Handles business logic and processes requests before sending responses.

- **authController.js** – Handles authentication processes like login and registration.
- **adminController.js** – Manages admin-related actions like user management and settings.
- **attendanceController.js** – Manages attendance-related operations.
- **notificationController.js** – Handles notification-related functionalities.
- **reportController.js** – Generates reports and processes report-related data.

### 4. **database/**

Manages the database connection.

- **database.js** – Establishes and maintains a connection with MongoDB.

### 5. **middleware/**

Middleware functions that execute before the main request is processed.

- **authMiddleware.js** – Verifies JWT tokens and checks user roles for access control.

### 6. **models/**

Contains MongoDB schemas and models.

- **AdminSettings.js** – Defines the schema for admin settings configurations.
- **Attendance.js** – Defines the schema for storing employee attendance.
- **User.js** – Defines the schema for user data.
- **UserNotifications.js** – Defines the schema for user notification preferences.

### 7. **routes/**

Handles API endpoints and routing.

- **admin.js** – Defines routes for admin operations.
- **attendance.js** – Defines routes for attendance related routes.
- **auth.js** – Defines routes for authentication routes.
- **notification.js** – Defines routes for notifications.

### 8. **service/**

Handles background tasks and scheduled services.

- **notificationScheduleService.js** – Manages server-side scheduled notifications.

### 9. **utils/**

Utility functions used across the project.

- **jwtToken.js** – Generates and verifies JWT tokens.
- **report.js** – Generates Excel reports from the database.

---

## Summary

This structure organizes the project into functional sections, making it scalable and maintainable. Let me know if you need any modifications! 🚀
