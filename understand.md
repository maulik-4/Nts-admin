# NTS Legal Pro: User Roles & Capabilities Specification (`understand.md`)

## 1. Executive Summary & Purpose
This document provides a definitive, granular reference of the **user roles and capabilities** implemented and interpreted in the **NTS Legal Pro** Flutter application. 

The architecture is built on two strict tenets:
1. **Multi-Tenant Isolation**: Users belonging to a law firm can never see, modify, or access the data, documents, or settings of another firm.
2. **Role-Based Access Control (RBAC)**: Within a firm (and at the platform level), access to navigation tabs, dashboards, action buttons, and live backend endpoints is strictly enforced according to the user's role.

---

## 2. The Four User Roles

| Role Key in Backend | Domain Enum | Display Title | Persona & Scope of Authority |
| :--- | :--- | :--- | :--- |
| `super_admin` / `is_superuser: true` | `UserRole.superAdmin` | **Platform Administrator** | Cloud platform owner managing tenant law firms, system health, and global infrastructure. Has zero access to confidential tenant legal cases. |
| `admin` | `UserRole.firmAdmin` | **Firm Administrator** | Managing partner or principal law firm owner. Full administrative, financial, operational, and litigation authority over their firm. |
| `lawyer` | `UserRole.lawyer` | **Advocate / Lawyer** | Practicing legal counsel. Litigates cases, manages clients, files documents, attends hearings, and assigns legal tasks. |
| `staff` | `UserRole.staff` | **Legal Staff / Paralegal** | Operational support. Manages hearing schedules, client intake/coordination, and task execution queues. Strictly barred from financial data, confidential case files, and firm settings. |

---

## 3. Comprehensive Capability Matrix

The table below correlates each application capability to the 4 roles, including the live Django REST Framework (DRF) backend status at `https://api.hphighcourt.site/api/`:

| Functional Area | Capability Identifier | Super Admin | Firm Admin | Lawyer | Staff | Live Backend Contract |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **Platform Tenant Registry** | `viewFirms`, `manageFirms` | ✅ Full | ⛔ Blocked | ⛔ Blocked | ⛔ Blocked | `GET/POST /api/firms/` (Admin only) |
| **Platform System Health** | Global Health & Metrics | ✅ Full | ⛔ Blocked | ⛔ Blocked | ⛔ Blocked | Platform Health Registry |
| **Executive Financials** | `viewFinancials` | ⛔ Blocked | ✅ Full | ⛔ Blocked | ⛔ Blocked | `GET /api/payments/` (403 for Lawyer/Staff) |
| **Record / Manage Payments** | `createPayments` | ⛔ Blocked | ✅ Full | ⛔ 403 Forbidden | ⛔ 403 Forbidden | `POST /api/payments/` (403 for Lawyer/Staff) |
| **Subscription & Usage Quota**| `manageSubscriptions` | ⛔ Blocked | ✅ Full | ⛔ Blocked | ⛔ Blocked | `GET /api/subscriptions/active/`, `/api/clients/usage/` |
| **Team & Member Management** | `manageTeam` | ⛔ Blocked | ✅ Full | ⛔ Blocked | ⛔ Blocked | `GET /api/auth/users/`, `POST /api/auth/add-user/` |
| **Firm Branding & Website** | `manageBranding` | ⛔ Blocked | ✅ Full | ⛔ Blocked | ⛔ Blocked | `GET/PATCH /api/profile/firm/website/` (403 for non-admin) |
| **Cases Management** | `viewCases`, `createCases`, `editCases` | ⛔ Blocked | ✅ Full | ✅ Full | ⛔ 403 Forbidden | `GET/POST /api/cases/` (403 for Staff) |
| **Case Documents & Briefs** | `viewDocuments`, `uploadDocuments` | ⛔ Blocked | ✅ Full | ✅ Full | ⛔ 403 Forbidden | `GET/POST /api/documents/` (403 for Staff) |
| **Client Registry & Intake** | `viewClients`, `manageClients` | ⛔ Blocked | ✅ Full | ✅ Full | ✅ Full | `GET/POST /api/clients/` (200 for firm roles) |
| **Court Hearings & Docket** | `viewHearings`, `manageHearings` | ⛔ Blocked | ✅ Full | ✅ Full | ✅ Full | `GET/POST /api/hearings/` (200 for firm roles) |
| **Tasks Queue & Checklists** | `viewTasks`, `manageTasks` | ⛔ Blocked | ✅ Full | ✅ Assigned | ✅ Primary Tab | `GET/POST /api/tasks/` (200 for firm roles) |
| **Colleague Direct Messages** | Internal Communications | ⛔ Blocked | ✅ Full | ✅ Full | ✅ Full | `GET/POST /api/messages/` (Firm internal) |
| **Support Helpdesk** | Tickets Desk | ⛔ Blocked | ✅ Full | ✅ Full | ✅ Full | `GET/POST /api/support/` (Platform tickets) |
| **Notifications & Alerts** | In-App Notifications | ⛔ Blocked | ✅ Full | ✅ Full | ✅ Full | `GET /api/notifications/` |
| **User Profile & Settings** | Personal Profile | ✅ Platform | ✅ Firm Profile | ✅ Lawyer Profile | ✅ Staff Profile | `GET/PATCH /api/profile/me/` |

---

## 4. In-Depth Interpretation by Role

### A. Super Admin / Platform Administrator
* **Role Representation**: `role == "super_admin"` or `is_superuser == true`
* **Navigation Shell**:
  * Bottom Bar / Rail: `Dashboard` (`/admin/dashboard`), `Tenant Firms` (`/admin/firms`), `Platform Console` (`/admin/more`).
  * Isolated Environment: If a Super Admin attempts to visit `/app/*`, route guards redirect them back to `/admin/dashboard`.
* **Dashboard Experience**:
  * Platform-wide metrics: Total Tenant Firms, Active Subscriptions, Blocked Accounts, System Health status.
  * Tenant firm registry list with quick search and block/unblock toggles.
* **Core Capabilities & Restrictions**:
  * Can view and search all registered law firms across the platform.
  * Can block or unblock non-compliant or expired tenant firms via `/api/firms/{id}/block/` and `/api/firms/{id}/unblock/`.
  * **Strict Boundary**: Super Admin has **no access** to confidential attorney-client matters, case briefs, hearings, or financial records of any firm.

---

### B. Firm Admin (Managing Partner / Firm Owner)
* **Role Representation**: `role == "admin"`
* **Navigation Shell**:
  * Bottom Bar / Rail: `Dashboard` (`/app/dashboard`), `Cases` (`/app/cases`), `Clients` (`/app/clients`), `Hearings` (`/app/hearings`), `More` (`/app/more`).
  * More Tab contains: Team Management, Subscriptions & Quota, Payments & Invoicing, Firm Website Branding, Documents Repository, Messages, Support, Settings.
* **Dashboard Experience**:
  * Executive Command Center: Active Cases, Total Clients, Pending Court Hearings, Revenue Collected, and Outstanding Invoices.
  * Quick Actions: "New Case", "New Client", "Schedule Hearing", "Record Payment".
  * Financial overview cards and recent litigation filings.
* **Core Capabilities**:
  * **Full Financial Authority**: Exclusive authority to view payments, record transactions, and inspect invoices via `/api/payments/`.
  * **Team Management**: Exclusive ability to list firm advocates and staff (`GET /api/auth/users/`), provision new users (`POST /api/auth/add-user/`), and send email invitations (`POST /api/auth/invite/firm/`).
  * **Subscription Management**: Access to active subscription details (`/api/subscriptions/active/`), client usage capacity meter (`/api/clients/usage/`), and tier upgrades (`/api/plans/`).
  * **Public Branding**: Configures firm website tagline, description, theme colors, and public contact information (`/api/profile/firm/website/`).
  * **Full Litigation Access**: Creates, edits, and deletes cases, clients, hearings, documents, and tasks.

---

### C. Lawyer (Advocate / Legal Counsel)
* **Role Representation**: `role == "lawyer"`
* **Navigation Shell**:
  * Bottom Bar / Rail: `Dashboard` (`/app/dashboard`), `Cases` (`/app/cases`), `Clients` (`/app/clients`), `Hearings` (`/app/hearings`), `More` (`/app/more`).
  * More Tab contains: Case Documents, Colleague Messages, Support Desk, Notifications, Profile, Settings.
  * Firm Admin modules (`Team`, `Subscriptions`, `Branding`, `Payments`) are hidden from navigation and protected by route guards.
* **Dashboard Experience**:
  * Courtroom Litigation Workspace: Active Cases in court, Hearings Scheduled this week, Legal Tasks assigned, Documents Filed.
  * Quick Actions: "New Case", "Schedule Hearing", "Upload Brief", "New Client".
  * Courtroom agenda with date, court number, and judge information.
* **Core Capabilities & Restrictions**:
  * **Litigation Authority**: Full read and write access to Cases, Clients, Hearings, and Documents.
  * **Team Tasking**: Can create and assign operational tasks to colleagues or self.
  * **Collaboration**: Can message colleagues and attach case references.
  * **Strict Financial Barrier**: Cannot access `/api/payments/` (backend returns `403 Forbidden`). Route guard redirects `/app/more/payments` to `/app/dashboard`.
  * **Firm Admin Barrier**: Cannot manage firm billing, branding, or user accounts.

---

### D. Staff (Paralegal / Legal Assistant)
* **Role Representation**: `role == "staff"`
* **Navigation Shell**:
  * Bottom Bar / Rail: `Dashboard` (`/app/dashboard`), `Tasks Queue` (`/app/tasks` - **Direct Primary Tab**), `Clients` (`/app/clients`), `Hearings` (`/app/hearings`), `More` (`/app/more`).
  * Note: `Cases` is replaced in the primary navigation by `Tasks Queue` because the live backend returns `403 Forbidden` for staff accessing `/api/cases/`.
* **Dashboard Experience**:
  * Operations Command Center: Pending Tasks queue, Today's Court Hearings for client coordination, Active Clients directory.
  * Interactive task checklist allowing one-tap status updates (Pending → In Progress → Completed).
  * Quick Actions: "New Task", "New Client", "Schedule Hearing".
* **Core Capabilities & Restrictions**:
  * **Operational Coordination**: Full read and write access to Clients and Hearings for client intake, notice delivery, and schedule management.
  * **Task Execution**: Full access to the operational tasks board (`/api/tasks/`).
  * **Strict Confidentiality Barrier**: Barred from accessing Cases (`/api/cases/`) and Documents (`/api/documents/`) (live backend returns `403 Forbidden`). Route guards protect `/app/cases` and `/app/more/documents`.
  * **Strict Financial & Admin Barrier**: Barred from Payments, Team Management, Subscriptions, and Branding.

---

## 5. Architectural Implementation Details

### A. Domain Modeling & Providers
1. **[user_role.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/auth/domain/models/user_role.dart)**:
   * Maps JSON strings (`"super_admin"`, `"admin"`, `"lawyer"`, `"staff"`) and handles boolean flags like `is_superuser`.
   * Provides helper getters: `isSuperAdmin`, `isFirmAdmin`, `isLawyer`, `isStaff`.
2. **[role_capabilities.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/auth/domain/models/role_capabilities.dart)**:
   * Granular capability enum (`UserCapability`) mapping 15 discrete permissions.
   * Riverpod providers: `currentUserRoleProvider`, `userCapabilitiesProvider`, `hasCapabilityProvider(capability)`.

### B. UI Enforcement Mechanisms
1. **Dynamic Shell ([app_shell.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/shell/presentation/screens/app_shell.dart))**:
   * Dynamically constructs navigation tabs based on `userRole`.
   * Displays distinct role badges and color-coded avatars in header.
2. **Declarative UI Gates ([capability_gate.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/shared/widgets/capability_gate.dart))**:
   * `CapabilityGate`: Conditionally renders child widgets (e.g. Floating Action Buttons, edit icons) only if the user possesses the required capability.
   * `RoleGate`: Conditionally renders components matching allowed roles.
3. **Route Guards ([app_router.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/routing/app_router.dart))**:
   * URL-level enforcement preventing unauthorized access even if URLs are directly typed or bookmarked.
   * Redirects unauthorized users to their appropriate dashboard or parent menu.

---

## 6. Live Test Credentials for Verification

The following verified accounts on `https://api.hphighcourt.site/api/` can be used to validate these behaviors:

| Role | Username | Password | Firm ID | Verified Behaviors |
| :--- | :--- | :--- | :---: | :--- |
| **Firm Admin** | `testlawyer_fe69b5` | `TestPassword@123` | 15 | Full access to Team, Subscriptions, Payments, Branding, Cases, Clients, Hearings, Tasks. |
| **Lawyer** | `lawyer_7cc7d` | `TestPassword@123` | 15 | Litigation workspace; blocked from Payments, Team, Subscriptions, and Branding. |
| **Staff** | `staff_7cc7d` | `TestPassword@123` | 15 | Tasks queue primary tab, Clients, Hearings; blocked from Cases, Documents, Payments, Team. |
