# QuickAttend Flutter App_Backend API Documentation

## Overview

This document provides an overview of the API routes available for the Flutter_App_Backend, including both Admin and User routes.

---
The API follows RESTful principles and requires authentication via Bearer Token for most endpoints.

---

## Admin Routes

### only admin access user can acess these routes

### 1. Get Holidays

**Method:** `GET`  
**Endpoint:** `/api/admin/getHolidays`  
**Authorization:** Bearer Token  

### 2. Set Holidays

**Method:** `POST`  
**Endpoint:** `/api/admin/setHolidays`  
**Authorization:** Bearer Token  
**Body:**

```json
{
  "holidays": ["2025-01-28","2025-11-03","2025-11-17","2025-11-27","2025-10-21"]
}
```

### 3. Search User by Employee ID

**Method:** `GET`  
**Endpoint:** `/api/admin/searchUser/{employeeId}`  
**Authorization:** Bearer Token  

### 4. Get Yearly Reports

**Method:** `GET`  
**Endpoint:** `/api/admin/reports/yearly/{year}`  
**Authorization:** Bearer Token  
**Path Variables:**

- `year`: `2025`

### 5. Get Notification Time

**Method:** `GET`  
**Endpoint:** `/api/notifications/get-notification-time`  
**Authorization:** Bearer Token  

### 6. Set Notification Time

**Method:** `POST`  
**Endpoint:** `/api/notifications/set-notification-time`  
**Authorization:** Bearer Token  
**Body:**

```json
{
    "notificationTime": "17:00",
    "timeZone": "Asia/Kolkata"
}
```

### 7. Get Monthly Reports

**Method:** `GET`  
**Endpoint:** `/api/admin/reports/monthly/{year}/{month}`  
**Authorization:** Bearer Token  
**Path Variables:**

- `year`: `2025`
- `month`: `02`

### 8. Update User by Employee ID

**Method:** `POST`  
**Endpoint:** `/api/admin/user/{employeeId}`  
**Authorization:** Bearer Token  
**Body:**

```json
{
    "name": "John Poer",
    "newEmployeeId": "EMP12986",
    "role": "admin"
}
```

### 9. Delete User by Employee ID

**Method:** `DELETE`  
**Endpoint:** `/api/admin/user/deleteUser/{employeeId}`  
**Authorization:** Bearer Token  

### 10. Get Users

**Method:** `GET`  
**Endpoint:** `/api/admin/user/getUsers`  
**Authorization:** Bearer Token  

---

## User Routes

### All user can access these routes including admin

### 1. Register User

**Method:** `POST`  
**Endpoint:** `/api/auth/register`  
**Body:**

```json
{
  "name": "John Doe",
  "employeeId": "EMP123"
}
```

### 2. Get Full Calendar

**Method:** `GET`  
**Endpoint:** `/api/attendance/getFullCalendar`  
**Authorization:** Bearer Token  

### 3. Login User

**Method:** `POST`  
**Endpoint:** `/api/auth/login`  
**Body:**

```json
{
  "employeeId": "EMP123"
}
```

### 4. Apply Attendance (On-Duty)

**Method:** `POST`  
**Endpoint:** `/api/attendance/apply`  
**Authorization:** Bearer Token  
**Body:**

```json
{
    "date": "2025-02-08",
    "status": "on-duty",
    "location": "Site A",
    "projectName": "project062",
    "remark": "For Station 02 issue"
}
```

### 5. Apply Attendance (Leave)

**Method:** `POST`  
**Endpoint:** `/api/attendance/apply`  
**Authorization:** Bearer Token  
**Body:**

```json
{
    "date": "2025-02-07",
    "status": "leave",
    "leaveType": "Sick Leave",
    "approverName": "Manager A",
    "remark": "Feeling unwell"
}
```

---

## Authentication

Most endpoints require authentication using a **Bearer Token**. Ensure that the token is passed in the request headers:

```http
Authorization: Bearer <token>
```

---

## Notes

- Ensure to replace `localhost:5000` with the actual production API URL when deploying.
- Date formats follow the standard `YYYY-MM-DD` format.
- All API responses are returned in JSON format.

---

## License

This API documentation is part of the Flutter_Backend project and is licensed under MIT.
