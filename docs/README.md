# IGE Hospital - Technical Documentation

> **Version:** 1.0.0
> **Last Updated:** November 2024
> **Platform:** Flutter Cross-Platform (Web, iOS, Android, macOS)
> **API Base:** `https://api.igehospital.com/api`

## Executive Summary

IGE Hospital is a comprehensive Flutter-based hospital management system designed for multi-platform deployment. The application implements role-based access control (RBAC) with four user types: Admin, Doctor, Receptionist, and Patient. It leverages GetX for state management and routing, Provider for theme management, and communicates with a RESTful API backend.

---

## Documentation Index

### Core Documentation

| Document | Description |
|----------|-------------|
| [01-ARCHITECTURE.md](./01-ARCHITECTURE.md) | System architecture, design patterns, and technical decisions |
| [02-PROJECT-STRUCTURE.md](./02-PROJECT-STRUCTURE.md) | Complete directory structure and file organization |
| [03-STATE-MANAGEMENT.md](./03-STATE-MANAGEMENT.md) | GetX and Provider implementation details |
| [04-API-REFERENCE.md](./04-API-REFERENCE.md) | Complete API endpoint documentation |
| [05-AUTHENTICATION.md](./05-AUTHENTICATION.md) | Authentication flow and token management |
| [06-AUTHORIZATION-RBAC.md](./06-AUTHORIZATION-RBAC.md) | Role-based access control implementation |
| [07-DATA-MODELS.md](./07-DATA-MODELS.md) | Data structures and model definitions |
| [08-SERVICES.md](./08-SERVICES.md) | Service layer documentation |
| [09-CONTROLLERS.md](./09-CONTROLLERS.md) | GetX controllers documentation |
| [10-UI-COMPONENTS.md](./10-UI-COMPONENTS.md) | Reusable widgets and components |
| [11-ROUTING.md](./11-ROUTING.md) | Navigation and middleware |
| [12-THEMING.md](./12-THEMING.md) | Color system and theme management |
| [13-DEVELOPMENT-GUIDE.md](./13-DEVELOPMENT-GUIDE.md) | Development setup and guidelines |
| [14-DEPLOYMENT.md](./14-DEPLOYMENT.md) | Build and deployment procedures |
| [15-TESTING.md](./15-TESTING.md) | Testing strategy and implementation |
| [16-TROUBLESHOOTING.md](./16-TROUBLESHOOTING.md) | Common issues and solutions |
| [17-SECURITY.md](./17-SECURITY.md) | Security considerations and best practices |
| [18-PERFORMANCE.md](./18-PERFORMANCE.md) | Performance optimization guidelines |

---

## Quick Start for Developers

### Prerequisites

- Flutter SDK 3.6.1+
- Dart SDK 3.6.1+
- IDE: VS Code or Android Studio
- Git

### Setup Commands

```bash
# Clone repository
git clone <repository-url>
cd IgeHospital

# Install dependencies
flutter pub get

# Run development server
flutter run

# Build for production
flutter build web --release
flutter build apk --release
```

### Environment Configuration

The application connects to:
- **Production API:** `https://api.igehospital.com/api`
- No environment-specific configuration files required

---

## Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Flutter | 3.6.1+ |
| Language | Dart | 3.6.1+ |
| State Management | GetX | 4.6.6 |
| Theme Management | Provider | 6.1.2 |
| HTTP Client | http | 1.3.0 |
| Local Storage | shared_preferences | 2.5.2 |
| Image Handling | cached_network_image | 3.4.1 |
| SVG Support | flutter_svg | 2.0.17 |
| Internationalization | intl | 0.20.2 |
| Data Tables | expandable_datatable | 0.0.7 |

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        IGE HOSPITAL APP                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   WIDGETS   │  │   PAGES     │  │      DIALOGS            │ │
│  │  (Reusable) │  │  (Screens)  │  │  (Forms & Modals)       │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
│         └────────────────┴──────────────────────┘               │
│                          │                                       │
│  ┌───────────────────────┴───────────────────────┐              │
│  │              CONTROLLERS (GetX)               │              │
│  │   AuthController | PatientController | etc.   │              │
│  └───────────────────────┬───────────────────────┘              │
│                          │                                       │
│  ┌───────────────────────┴───────────────────────┐              │
│  │               SERVICES (GetX)                 │              │
│  │   AuthService | PatientService | etc.         │              │
│  └───────────────────────┬───────────────────────┘              │
│                          │                                       │
│  ┌───────────────────────┴───────────────────────┐              │
│  │              HTTP CLIENT (Singleton)          │              │
│  │   Token injection | Auto-refresh | 401 handling│             │
│  └───────────────────────┬───────────────────────┘              │
│                          │                                       │
└──────────────────────────┼───────────────────────────────────────┘
                           │
                           ▼
                 ┌─────────────────────┐
                 │    REST API         │
                 │  api.igehospital.com│
                 └─────────────────────┘
```

---

## User Roles & Permissions

| Role | Access Level | Key Capabilities |
|------|--------------|------------------|
| **Admin** | Full | Manage all users, view analytics, system settings, full accounting |
| **Doctor** | Medical | Manage patients, appointments, consultations, vital signs |
| **Receptionist** | Patient Care | Create/edit patients, view consultations, profile access |
| **Patient** | Self-Service | View own profile, book appointments, join consultations |

---

## Key Features

### Patient Management
- Patient registration and records
- Medical history tracking
- Vital signs monitoring
- Document management

### Appointment System
- Schedule management
- Doctor availability
- Department-based booking
- Status tracking

### Live Consultations
- Video consultation scheduling
- Join/start/end sessions
- Meeting integration (Zoom/Teams)
- Recording support

### Accounting Module
- Account management
- Payment tracking
- Bill generation
- Financial dashboards

### Role-Based Access
- Middleware-based route protection
- Permission-wrapped UI components
- Granular action control
- Role normalization

---

## Contact & Support

For technical questions or issues:
1. Review the [Troubleshooting Guide](./16-TROUBLESHOOTING.md)
2. Check the [Development Guide](./13-DEVELOPMENT-GUIDE.md)
3. Contact the development team

---

*This documentation is maintained by the IGE Hospital development team.*
