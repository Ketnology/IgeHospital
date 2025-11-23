# API Reference Documentation

> **Document Version:** 1.0.0
> **Last Updated:** November 2024
> **Base URL:** `https://api.igehospital.com/api`

## Overview

The IGE Hospital API is a RESTful API that follows standard HTTP conventions. All requests require authentication via Bearer token (except login).

---

## Authentication

### Headers

All authenticated requests must include:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Response Format

All API responses follow this structure:

```json
{
  "status": 200,
  "message": "Success message",
  "data": { ... }
}
```

### Error Response

```json
{
  "status": 400,
  "message": "Error description",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

---

## Authentication Endpoints

### POST `/auth/login`

Authenticate user and receive access token.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "token_expiration": "1700000000",
    "user": {
      "user_id": "uuid-here",
      "full_name": "John Doe",
      "email": "user@example.com",
      "phone": "+1234567890",
      "user_type": "admin",
      "designation": "System Administrator",
      "gender": "male",
      "profile_image": "https://..."
    }
  }
}
```

**Error (401):**
```json
{
  "status": 401,
  "message": "Invalid credentials"
}
```

---

### POST `/auth/validate-token`

Validate and refresh the current token.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "status": 200,
  "message": "Token is valid",
  "data": {
    "token_expiration": "1700100000"
  }
}
```

**Error (401):**
```json
{
  "status": 401,
  "message": "Token expired or invalid"
}
```

---

### POST `/auth/logout`

Invalidate the current session.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "status": 200,
  "message": "Logged out successfully"
}
```

---

## Patient Endpoints

### GET `/patient`

Get list of patients with pagination and filters.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (default: 1) |
| `per_page` | int | Items per page (default: 12) |
| `search` | string | Search by name, email, phone |
| `gender` | string | Filter by gender (male/female) |
| `blood_group` | string | Filter by blood group |
| `date_from` | string | Start date (YYYY-MM-DD) |
| `date_to` | string | End date (YYYY-MM-DD) |
| `sort_by` | string | Sort field (default: created_at) |
| `sort_direction` | string | asc/desc (default: desc) |

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "patient-uuid",
        "patient_unique_id": "PAT-001",
        "user": {
          "full_name": "Jane Smith",
          "email": "jane@example.com",
          "phone": "+1234567890",
          "gender": "female",
          "profile_image": null
        },
        "address": {
          "street": "123 Main St",
          "city": "New York",
          "state": "NY",
          "country": "USA"
        },
        "stats": {
          "appointments_count": 5,
          "documents_count": 3
        },
        "vital_signs_summary": {
          "latest_blood_pressure": "120/80",
          "latest_heart_rate": "72 bpm",
          "latest_temperature": "37.0°C"
        },
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-20T15:45:00Z"
      }
    ],
    "total": 150,
    "per_page": 12,
    "current_page": 1,
    "last_page": 13
  }
}
```

---

### GET `/patient/{id}`

Get single patient details.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "id": "patient-uuid",
    "patient_unique_id": "PAT-001",
    "user": { ... },
    "address": { ... },
    "appointments": [ ... ],
    "documents": [ ... ],
    "vital_signs": [ ... ],
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

---

### POST `/patient`

Create new patient.

**Request:**
```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "gender": "female",
  "date_of_birth": "1990-05-15",
  "blood_group": "O+",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "zip_code": "10001"
  }
}
```

**Response (201):**
```json
{
  "status": 201,
  "message": "Patient created successfully",
  "data": {
    "id": "new-patient-uuid",
    ...
  }
}
```

---

### PUT `/patient/{id}`

Update patient information.

**Request:**
```json
{
  "first_name": "Jane",
  "last_name": "Doe",
  "phone": "+1987654321"
}
```

**Response (200):**
```json
{
  "status": 200,
  "message": "Patient updated successfully",
  "data": { ... }
}
```

---

### DELETE `/patient/{id}`

Delete patient record.

**Response (200):**
```json
{
  "status": 200,
  "message": "Patient deleted successfully"
}
```

---

## Doctor Endpoints

### GET `/doctor`

Get list of doctors with filters.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number |
| `per_page` | int | Items per page |
| `search` | string | Search by name, email |
| `department_id` | string | Filter by department |
| `status` | string | active/blocked/pending |

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "doctor-uuid",
        "user_id": "user-uuid",
        "first_name": "Dr. John",
        "last_name": "Wilson",
        "email": "john.wilson@hospital.com",
        "phone": "+1234567890",
        "gender": "male",
        "department": "Cardiology",
        "department_id": "dept-uuid",
        "specialty": "Heart Surgery",
        "qualification": "MD, FACC",
        "status": "active",
        "profile_image": "https://...",
        "stats": {
          "appointments_count": 45,
          "schedules_count": 5
        },
        "schedules": [
          {
            "id": "schedule-uuid",
            "per_patient_time": "30",
            "days": [
              {
                "day": "monday",
                "time_from": "09:00",
                "time_to": "17:00"
              }
            ]
          }
        ]
      }
    ],
    "total": 25,
    "per_page": 12,
    "current_page": 1
  }
}
```

---

### GET `/doctor-departments`

Get list of doctor departments.

**Response (200):**
```json
{
  "status": 200,
  "data": [
    {
      "id": "dept-uuid",
      "name": "Cardiology",
      "description": "Heart and cardiovascular care"
    }
  ]
}
```

---

### POST `/doctor`

Create new doctor.

**Request:**
```json
{
  "first_name": "John",
  "last_name": "Wilson",
  "email": "john.wilson@hospital.com",
  "phone": "+1234567890",
  "gender": "male",
  "department_id": "dept-uuid",
  "specialty": "Heart Surgery",
  "qualification": "MD, FACC",
  "password": "securepassword",
  "password_confirmation": "securepassword"
}
```

---

## Nurse/Receptionist Endpoints

### GET `/receptionist`

Get list of nurses/receptionists.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "nurse-uuid",
        "user_id": "user-uuid",
        "first_name": "Sarah",
        "last_name": "Johnson",
        "email": "sarah@hospital.com",
        "phone": "+1234567890",
        "gender": "female",
        "status": "active",
        "qualification": "RN",
        "blood_group": "A+"
      }
    ]
  }
}
```

---

## Appointment Endpoints

### GET `/appointments`

Get appointments with filters.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number |
| `per_page` | int | Items per page |
| `doctor_id` | string | Filter by doctor |
| `patient_id` | string | Filter by patient |
| `department_id` | string | Filter by department |
| `date_from` | string | Start date |
| `date_to` | string | End date |
| `is_completed` | bool | Filter completed |
| `search` | string | Search |
| `sort_by` | string | Sort field |
| `sort_direction` | string | asc/desc |

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "appointment-uuid",
        "patient_id": "patient-uuid",
        "doctor_id": "doctor-uuid",
        "department_id": "dept-uuid",
        "appointment_date": "2024-01-25",
        "appointment_time": "10:30:00",
        "problem": "Regular checkup",
        "is_completed": false,
        "doctor_name": "Dr. John Wilson",
        "doctor_department": "Cardiology",
        "patient_name": "Jane Smith",
        "created_at": "2024-01-20T08:00:00Z"
      }
    ],
    "total": 45
  }
}
```

---

### POST `/appointments`

Create new appointment.

**Request:**
```json
{
  "patient_id": "patient-uuid",
  "doctor_id": "doctor-uuid",
  "department_id": "dept-uuid",
  "appointment_date": "2024-01-25",
  "appointment_time": "10:30",
  "problem": "Regular checkup"
}
```

---

## Live Consultation Endpoints

### GET `/live-consultations`

Get consultations with filters.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | scheduled/ongoing/completed/cancelled |
| `doctor_id` | string | Filter by doctor |
| `patient_id` | string | Filter by patient |
| `date_from` | string | Start date |
| `date_to` | string | End date |

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "consultation-uuid",
        "consultation_title": "Follow-up Consultation",
        "consultation_date": "2024-01-25T14:00:00Z",
        "consultation_duration_minutes": 30,
        "type": "zoom",
        "status": "scheduled",
        "meeting_id": "123-456-789",
        "password": "abc123",
        "doctor": {
          "id": "doctor-uuid",
          "name": "Dr. John Wilson",
          "department": "Cardiology"
        },
        "patient": {
          "id": "patient-uuid",
          "name": "Jane Smith",
          "email": "jane@example.com"
        },
        "status_info": {
          "status": "scheduled",
          "label": "Scheduled",
          "color": "#4CAF50",
          "is_active": false,
          "is_upcoming": true
        },
        "permissions": {
          "can_join": true,
          "can_start": false,
          "can_end": false,
          "can_edit": true,
          "can_delete": true
        },
        "join_info": {
          "can_join_now": false,
          "join_window_start": "2024-01-25T13:55:00Z",
          "join_window_end": "2024-01-25T14:30:00Z"
        }
      }
    ]
  }
}
```

---

### POST `/live-consultations`

Create new consultation.

**Request:**
```json
{
  "consultation_title": "Follow-up Consultation",
  "doctor_id": "doctor-uuid",
  "patient_id": "patient-uuid",
  "consultation_date": "2024-01-25T14:00:00Z",
  "consultation_duration_minutes": 30,
  "type": "zoom",
  "host_video": true,
  "participant_video": true,
  "description": "Post-surgery follow-up"
}
```

---

### POST `/live-consultations/{id}/join`

Join an active consultation.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "join_url": "https://zoom.us/j/123456789?pwd=abc123",
    "meeting_id": "123-456-789",
    "password": "abc123"
  }
}
```

---

### POST `/live-consultations/{id}/start`

Start a scheduled consultation (doctor only).

**Response (200):**
```json
{
  "status": 200,
  "message": "Consultation started",
  "data": {
    "start_url": "https://zoom.us/s/123456789",
    "status": "ongoing"
  }
}
```

---

### POST `/live-consultations/{id}/end`

End an ongoing consultation (doctor only).

**Response (200):**
```json
{
  "status": 200,
  "message": "Consultation ended",
  "data": {
    "status": "completed",
    "actual_duration_minutes": 28
  }
}
```

---

### GET `/live-consultations/statistics`

Get consultation statistics.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "total_consultations": 150,
    "completed_consultations": 120,
    "cancelled_consultations": 10,
    "ongoing_consultations": 5,
    "scheduled_consultations": 15,
    "completion_rate": 80.0,
    "average_duration_minutes": 25.5,
    "daily_statistics": [
      {
        "date": "2024-01-20",
        "count": 8
      }
    ]
  }
}
```

---

## Vital Signs Endpoints

### GET `/patients/{patientId}/vital-signs/staff`

Get patient's vital signs history.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number |
| `per_page` | int | Items per page |

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "vital-uuid",
        "patient_id": "patient-uuid",
        "blood_pressure": "120/80",
        "systolic_pressure": 120,
        "diastolic_pressure": 80,
        "heart_rate": "72 bpm",
        "temperature": "37.0°C",
        "respiratory_rate": "16 /min",
        "oxygen_saturation": "98%",
        "weight": "70 kg",
        "height": "175 cm",
        "bmi": "22.9",
        "notes": "Patient stable",
        "recorded_at": "2024-01-20T10:30:00Z",
        "recorded_by": {
          "id": "nurse-uuid",
          "name": "Sarah Johnson",
          "type": "nurse"
        }
      }
    ],
    "total": 25,
    "per_page": 12,
    "current_page": 1
  }
}
```

---

### POST `/vital-signs`

Record new vital signs.

**Request:**
```json
{
  "patient_id": "patient-uuid",
  "systolic_pressure": 120,
  "diastolic_pressure": 80,
  "heart_rate": 72,
  "temperature": 37.0,
  "temperature_unit": "celsius",
  "respiratory_rate": 16,
  "oxygen_saturation": 98,
  "weight": 70.0,
  "weight_unit": "kg",
  "height": 175,
  "height_unit": "cm",
  "notes": "Patient stable",
  "recorded_at": "2024-01-20T10:30:00Z"
}
```

**Response (201):**
```json
{
  "status": 201,
  "message": "Vital signs recorded successfully",
  "data": { ... }
}
```

---

## Accounting Endpoints

### GET `/accounting/accounts`

Get list of accounts.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "account-uuid",
        "name": "Main Operating Account",
        "type": "bank",
        "description": "Primary hospital account",
        "status": "active",
        "is_active": true,
        "total_payments_amount": 150000.00,
        "created_at": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

---

### POST `/accounting/accounts`

Create new account.

**Request:**
```json
{
  "name": "Payroll Account",
  "type": "bank",
  "description": "Employee salary payments"
}
```

---

### GET `/accounting/payments`

Get list of payments.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "payment-uuid",
        "payment_date": "2024-01-15",
        "pay_to": "Medical Supplies Inc",
        "amount": "5000.00",
        "description": "Monthly supplies",
        "account": {
          "id": "account-uuid",
          "name": "Main Operating Account"
        },
        "payment_date_formatted": "January 15, 2024",
        "amount_formatted": "$5,000.00"
      }
    ]
  }
}
```

---

### GET `/accounting/bills`

Get list of bills.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "data": [
      {
        "id": "bill-uuid",
        "reference": "BILL-2024-001",
        "bill_date": "2024-01-20",
        "amount": "1500.00",
        "status": "pending",
        "payment_mode": "insurance",
        "patient": {
          "id": "patient-uuid",
          "name": "Jane Smith"
        },
        "bill_items": [
          {
            "id": "item-uuid",
            "item_name": "Consultation Fee",
            "qty": 1,
            "price": "500.00",
            "amount": "500.00"
          }
        ],
        "is_paid": false,
        "is_pending": true
      }
    ]
  }
}
```

---

### GET `/accounting/dashboard`

Get accounting dashboard overview.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "total_revenue": 250000.00,
    "total_expenses": 150000.00,
    "outstanding_bills": 35000.00,
    "accounts_count": 5,
    "recent_transactions": [ ... ]
  }
}
```

---

## Dashboard Endpoint

### POST `/admin/dashboard`

Get admin dashboard data.

**Response (200):**
```json
{
  "status": 200,
  "data": {
    "doctor_count": 25,
    "patient_count": 500,
    "receptionist_count": 10,
    "admin_count": 3,
    "recent_appointments": [
      {
        "id": "appt-uuid",
        "patient_name": "Jane Smith",
        "doctor_name": "Dr. John Wilson",
        "date": "2024-01-25",
        "time": "10:30"
      }
    ]
  }
}
```

---

## Error Codes

| Status | Description |
|--------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid/expired token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 422 | Validation Error - Field validation failed |
| 500 | Server Error |

---

## Rate Limiting

The API implements rate limiting:
- 60 requests per minute per user
- 401 response when limit exceeded

---

## Pagination

All list endpoints support pagination:

```json
{
  "data": [...],
  "total": 150,
  "per_page": 12,
  "current_page": 1,
  "last_page": 13
}
```
