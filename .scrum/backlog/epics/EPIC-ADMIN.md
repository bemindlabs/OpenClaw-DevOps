# EPIC-ADMIN: Admin Dashboard

## Epic Overview

| Field           | Value           |
| --------------- | --------------- |
| **Epic ID**     | EPIC-ADMIN      |
| **Title**       | Admin Dashboard |
| **Status**      | In Progress     |
| **Priority**    | High            |
| **Phase**       | MVP             |
| **Owner**       | Frontend Team   |
| **Start Date**  | 2026-02-08      |
| **Target Date** | 2026-03-29      |

## Description

This epic covers the development of the Admin Dashboard (Assistant Portal), a Next.js-based administration interface for managing the OpenClaw platform. The dashboard provides real-time service monitoring, log viewing, chat-based service management, and system configuration through a modern, intuitive interface with Google OAuth authentication.

## Business Value

- **Operational Efficiency**: Centralized management of all services
- **Real-time Visibility**: Instant awareness of system health
- **Security**: Role-based access with OAuth authentication
- **Productivity**: Chat-based interface for quick operations

## Success Criteria

1. Google OAuth authentication working for configured domains
2. Real-time service health monitoring
3. Live log streaming with filtering
4. Chat interface connected to gateway
5. Mobile-responsive admin UI
6. Role-based access control implemented

## Dependencies

- Gateway service for backend operations
- Google OAuth credentials configured
- MongoDB for session storage
- Redis for real-time features

## Technical Requirements

### IEEE-STD-ADMIN-001: Authentication

- Google OAuth 2.0 integration
- Domain-restricted access (ALLOWED_OAUTH_DOMAINS)
- JWT session management via NextAuth.js
- Secure cookie handling

### IEEE-STD-ADMIN-002: Real-time Features

- WebSocket connection to gateway
- Live service health updates
- Log streaming with filters
- Chat message delivery

### IEEE-STD-ADMIN-003: UI/UX Standards

- Tailwind CSS + shadcn/ui components
- Dark mode support
- Responsive design (mobile-first)
- Accessible components (ARIA)

## Stories

| Story ID | Title                    | Priority | Points | Status |
| -------- | ------------------------ | -------- | ------ | ------ |
| US-015   | Google OAuth Integration | Critical | 5      | Ready  |
| US-016   | Service Health Dashboard | High     | 5      | Ready  |
| US-017   | Log Viewer Component     | High     | 5      | Ready  |
| US-018   | Chat Interface           | Medium   | 8      | Ready  |

## Page Structure

```
/                     # Redirect to /dashboard
/api/auth/*           # NextAuth.js routes
/dashboard            # Main dashboard
/dashboard/services   # Service health grid
/dashboard/logs       # Log viewer
/dashboard/chat       # Chat interface (future)
/dashboard/settings   # System settings (future)
```

## Component Architecture

```
app/
  layout.tsx              # Root layout with auth
  page.tsx                # Redirect to dashboard
  dashboard/
    layout.tsx            # Dashboard layout with nav
    page.tsx              # Dashboard overview
    services/page.tsx     # Service grid
    logs/page.tsx         # Log viewer

components/
  ui/                     # shadcn/ui components
  auth/
    login-button.tsx      # OAuth login
    user-menu.tsx         # User dropdown
  services/
    service-card.tsx      # Service status card
    service-grid.tsx      # Service grid layout
    health-badge.tsx      # Health indicator
  logs/
    log-viewer.tsx        # Log streaming component
    log-filters.tsx       # Filter controls
  chat/
    message-list.tsx      # Chat messages
    message-input.tsx     # Chat input
    message-bubble.tsx    # Individual message

hooks/
  use-services.ts         # Service data hook
  use-socket.ts           # WebSocket hook
  use-logs.ts             # Log streaming hook

lib/
  auth.ts                 # NextAuth config
  socket.ts               # Socket.io client
  constants.ts            # App constants
```

## Authentication Flow

```
+------------------+
|   User Access    |
|   /dashboard     |
+------------------+
        |
        v
+------------------+
|  NextAuth Check  |
|  Session Valid?  |
+------------------+
     |         |
     No       Yes
     |         |
     v         v
+--------+  +--------+
| Google |  | Access |
| OAuth  |  | Granted|
+--------+  +--------+
     |
     v
+------------------+
| Domain Whitelist |
|    Check         |
+------------------+
     |         |
   Fail      Pass
     |         |
     v         v
+--------+  +--------+
| Access |  | Create |
| Denied |  | Session|
+--------+  +--------+
```

## Real-time Architecture

```
+------------------+
|  Admin Dashboard |
|    (Browser)     |
+------------------+
        |
        | WebSocket
        v
+------------------+
|     Gateway      |
|   Socket.io      |
+------------------+
        |
   +----+----+
   |         |
   v         v
+------+  +------+
|Health|  | Logs |
|Events|  |Stream|
+------+  +------+
```

## Risks

| Risk                           | Probability | Impact | Mitigation                      |
| ------------------------------ | ----------- | ------ | ------------------------------- |
| OAuth domain misconfiguration  | Medium      | High   | Clear documentation, validation |
| WebSocket disconnection        | Medium      | Medium | Auto-reconnect with backoff     |
| Log volume overwhelming UI     | High        | Medium | Pagination, filtering           |
| Session expiration during work | Low         | Medium | Token refresh, save state       |

## Acceptance Criteria

- [ ] Google OAuth login works for allowed domains
- [ ] Unauthorized domains are rejected with clear message
- [ ] Service health updates within 5s of state change
- [ ] Logs stream in real-time with <1s delay
- [ ] UI is responsive on mobile devices
- [ ] Session persists across page refreshes
- [ ] User can log out and session is cleared

---

_Last Updated: 2026-02-08_
