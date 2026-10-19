# Implementation Summary & Testing Checkpoints (`changesdone.md`)

This document provides a comprehensive record of all features, architectural updates, and UI/UX flows implemented in the Flutter application as required by `Changes.md`, along with step-by-step testing checkpoints for QA and verification.

---

## 1. Executive Summary

All applicable requirements documented in `Changes.md` have been implemented in-place within the existing Flutter codebase (`c:\Users\MAULIK\Desktop\Internship\Flutter\flutter_application_1`). The implementation preserves the existing architecture (Riverpod state management, GoRouter, Dio networking, and design tokens) while introducing:
- **Client Portal experience** (`/client/...`) with isolated role-based navigation.
- **Document security & granular sharing** with short-lived 300-second signed download tokens.
- **WhatsApp communications** with Meta Cloud API dispatch and Click-to-Chat fallback.
- **Standardized error handling** with `X-Request-ID` correlation tracking and reactive paywall barriers (`FIRM_BLOCKED`, `SUBSCRIPTION_EXPIRED`).
- **Super Admin platform management** for Razorpay gateway configuration and subscription transaction audits.

---

## 2. Implemented Features & Architectural Changes

### 2.1. Client Portal Module (`/client/...`)
- **Client Authentication**:
  - `POST /api/portal/auth/login/`: Dedicated sign-in view ([client_login_screen.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/screens/client_login_screen.dart)) with credentials validation, session persistence, and deep-link routing.
  - `POST /api/portal/auth/accept-invite/`: Portal onboarding view ([client_accept_invite_screen.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/screens/client_accept_invite_screen.dart)) with token extraction from query parameters (`?token=...`), password confirmation, and automatic session activation.
- **Client Dashboard**:
  - `GET /api/portal/hearings/`: Integrated dashboard ([client_dashboard_screen.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/screens/client_dashboard_screen.dart)) featuring:
    - **Next Court Hearing**: Prominent countdown badge (`TODAY`, `TOMORROW`, `IN X DAYS`), hearing notes, and case reference ([next_hearing_card.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/widgets/next_hearing_card.dart)).
    - **Assigned Counsel Card**: Direct phone dial (`tel:`) and email launcher (`mailto:`) for lead lawyers ([assigned_counsel_card.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/widgets/assigned_counsel_card.dart)).
    - **Active Cases Tab**: Clean list view of ongoing representations with court names and case numbers.
    - **Shared Documents Tab**: Real-time search filter and file metadata display ([shared_document_card.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/widgets/shared_document_card.dart)).
- **Secure Document Preview & Download**:
  - `GET /api/portal/documents/:id/link/?disposition=inline`: Requests 300-second expiring signed download tokens on-demand.
  - `GET /api/portal/documents/:id/download/?token=...`: In-app streaming PDF viewer ([client_document_preview_screen.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/client_portal/presentation/screens/client_document_preview_screen.dart)) with direct download to local storage.

### 2.2. Firm Document Security & Sharing
- **Metadata Extensions**: Updated `Document` model with `checksum` (SHA-256), `mime_type`, `file_size`, and `access_policy` ([document_model.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/documents/data/models/document_model.dart)).
- **Document Share Modal**:
  - `POST /api/documents/:id/share/`: Modal ([document_share_dialog.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/documents/presentation/widgets/document_share_dialog.dart)) allowing lawyers to grant access to clients with expiration rules (`Never`, `24 Hours`, `7 Days`, `30 Days`).
  - `POST /api/documents/shares/:id/revoke/`: Revocation control to terminate client access immediately.
- **Client Portal Invite Flow**:
  - `POST /api/clients/:id/invite/`: Dialog ([invite_client_dialog.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/clients/presentation/widgets/invite_client_dialog.dart)) accessible from [client_detail_screen.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/clients/presentation/screens/client_detail_screen.dart) to generate tokenized invitation URLs with copy-to-clipboard.

### 2.3. WhatsApp Communications Module
- **Template-Based Messaging**:
  - `GET /api/communications/whatsapp/templates/`: Dynamic template catalog fetching ([whatsapp_template_model.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/communications/data/models/whatsapp_template_model.dart)).
  - `POST /api/communications/whatsapp/send/`: Composer modal ([whatsapp_composer_modal.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/communications/presentation/widgets/whatsapp_composer_modal.dart)) with dynamic parameter interpolation (`client_name`, `hearing_date`, `court_name`, `case_title`).
  - **Click-to-Chat Fallback**: Automatically launches `https://wa.me/<number>?text=...` if direct Meta Cloud API delivery fails or opt-in is pending.
- **Client Communication Preferences**:
  - `GET/PUT /api/communications/preferences/:id/`: Preference modal ([communication_preference_dialog.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/communications/presentation/widgets/communication_preference_dialog.dart)) to record explicit client WhatsApp consent, preferred channel (`whatsapp`, `sms`, `email`, `both`), and dedicated WhatsApp phone number.

### 2.4. Standardized Error Handling & Paywall Barriers
- **Standardized Error Envelope**:
  - Enhanced [ApiException](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/errors/api_exception.dart) and [ErrorInterceptor](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/network/error_interceptor.dart) to parse `{ success: false, error: { code, message, fieldErrors, requestId } }` as well as top-level DRF formats.
  - Automatically captures `X-Request-ID` or `x-request-id` response headers.
- **Correlation ID UI Chips**:
  - Integrated into [ErrorStateWidget](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/shared/widgets/error_state_widget.dart), [FirmSuspendedScreen](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/screens/firm_suspended_screen.dart), and [SubscriptionExpiredScreen](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/screens/subscription_expired_screen.dart) with tap-to-copy functionality.
- **Global Paywall Barriers**:
  - Interceptor dispatches [FirmBlockedEvent](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/events/app_events.dart) on `FIRM_BLOCKED` and [SubscriptionExpiredEvent](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/events/app_events.dart) on `SUBSCRIPTION_EXPIRED`.
  - [PaywallBarrier](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/widgets/paywall_barrier.dart) overlays non-dismissible full-screen blocks preventing further API interactions until resolved.

### 2.5. Super Admin Platform Billing & Audit
- **Gateway Configuration**:
  - `GET/POST /api/admin/gateway/`: Tab view ([admin_gateway_tab.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/widgets/admin_gateway_tab.dart)) for platform administrators to configure Razorpay `key_id`, `key_secret`, `webhook_secret`, test mode, and active status.
- **Subscription Transactions Audit**:
  - `GET /api/admin/subscriptions/transactions/`: Transaction log ([admin_transactions_tab.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/widgets/admin_transactions_tab.dart)) displaying firm names, plan names, amounts in INR (`₹`), Razorpay order/payment IDs, and status badges.
- **Integrated Admin Screen**:
  - Updated [PlatformPlansScreen](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/screens/platform_plans_screen.dart) with 3 unified tabs: *Subscription Plans*, *Payment Gateway*, and *Transactions Log*.

### 2.6. Core & Shell Enhancements
- **Role Isolation**: Added `UserRole.client` in [user_role.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/auth/domain/models/user_role.dart) and configured [role_guard.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/core/routing/role_guard.dart) so clients cannot access firm lawyer or admin routes.
- **Firm Watermark Restoration**: Restored legal watermark background in [firm_watermark_background.dart](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/shared/widgets/firm_watermark_background.dart) and wired into [AppShell](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/shell/presentation/screens/app_shell.dart).

---

## 3. List of Created & Modified Files

### Created Files (35 files)
| File Path | Description |
|---|---|
| `lib/core/events/app_events.dart` | Event bus for reactive application paywall triggers |
| `lib/features/client_portal/data/models/client_dashboard_model.dart` | Models for client portal dashboard, hearings, cases, counsel |
| `lib/features/client_portal/data/models/client_document_model.dart` | Client shared document model with format/size computation |
| `lib/features/client_portal/data/models/access_link_model.dart` | Model for 300-second expiring download tokens |
| `lib/features/client_portal/data/repositories/client_portal_repository.dart` | API repository handling `/api/portal/...` endpoints |
| `lib/features/client_portal/presentation/providers/client_portal_notifier.dart` | Riverpod providers for client data and document stream |
| `lib/features/client_portal/presentation/screens/client_login_screen.dart` | Client portal login screen with invite redirect link |
| `lib/features/client_portal/presentation/screens/client_accept_invite_screen.dart` | Token activation and registration form |
| `lib/features/client_portal/presentation/screens/client_dashboard_screen.dart` | Multi-tab client dashboard screen |
| `lib/features/client_portal/presentation/screens/client_document_preview_screen.dart` | Inline PDF viewer and device download screen |
| `lib/features/client_portal/presentation/widgets/next_hearing_card.dart` | Upcoming hearing card with days countdown chip |
| `lib/features/client_portal/presentation/widgets/assigned_counsel_card.dart` | Counsel contact card with dial & email launchers |
| `lib/features/client_portal/presentation/widgets/shared_document_card.dart` | Document tile with preview, download, and expiry badges |
| `lib/features/documents/data/models/client_document_access_model.dart` | Document client access record model |
| `lib/features/documents/data/repositories/document_sharing_repository.dart` | Repository for sharing, revoking, and client invites |
| `lib/features/documents/presentation/widgets/document_share_dialog.dart` | Dialog for firm lawyers to share documents with clients |
| `lib/features/clients/presentation/widgets/invite_client_dialog.dart` | Dialog to generate portal invite tokens |
| `lib/features/communications/data/models/whatsapp_template_model.dart` | WhatsApp template catalog item model |
| `lib/features/communications/data/models/whatsapp_message_model.dart` | WhatsApp message dispatch result model |
| `lib/features/communications/data/models/communication_preference_model.dart` | Client notification preference model |
| `lib/features/communications/data/repositories/whatsapp_repository.dart` | Repository for WhatsApp API endpoints |
| `lib/features/communications/presentation/widgets/whatsapp_composer_modal.dart` | Parameterized WhatsApp message composer modal |
| `lib/features/communications/presentation/widgets/communication_preference_dialog.dart` | Preference management modal with consent switch |
| `lib/features/subscriptions/data/models/payment_gateway_model.dart` | Gateway credentials & subscription transactions models |
| `lib/features/subscriptions/presentation/providers/admin_gateway_notifier.dart` | Riverpod providers for admin gateway and audit logs |
| `lib/features/subscriptions/presentation/screens/firm_suspended_screen.dart` | Full-screen paywall for suspended firm accounts |
| `lib/features/subscriptions/presentation/screens/subscription_expired_screen.dart` | Full-screen paywall for lapsed subscriptions |
| `lib/features/subscriptions/presentation/widgets/paywall_barrier.dart` | Global interceptor overlay widget |
| `lib/features/subscriptions/presentation/widgets/admin_gateway_tab.dart` | Tab for configuring Razorpay credentials |
| `lib/features/subscriptions/presentation/widgets/admin_transactions_tab.dart` | Tab for auditing subscription transactions |
| `test/core/errors/api_exception_standardized_test.dart` | Unit tests for error envelopes and correlation IDs |
| `test/features/client_portal/client_portal_models_test.dart` | Unit tests for client dashboard, documents, and signed links |
| `test/features/communications/whatsapp_models_test.dart` | Unit tests for WhatsApp templates and send results |
| `test/features/subscriptions/admin_gateway_models_test.dart` | Unit tests for gateway config and transaction logs |
| `test/features/subscriptions/paywall_screens_test.dart` | Widget tests for FirmSuspendedScreen and SubscriptionExpiredScreen |

### Modified Files (20 files)
| File Path | Description of Changes |
|---|---|
| `lib/core/constants/api_endpoints.dart` | Registered endpoints for Client Portal, Sharing, WhatsApp, and Admin Gateway |
| `lib/core/errors/api_exception.dart` | Standardized error envelope, `errorCode` alias, and `requestId` extractor |
| `lib/core/network/error_interceptor.dart` | Extracted `X-Request-ID` and dispatched `FirmBlockedEvent` / `SubscriptionExpiredEvent` |
| `lib/core/routing/app_router.dart` | Registered `/client/login`, `/client/accept-invite`, `/client/dashboard`, `/client/documents/:id` |
| `lib/core/routing/role_guard.dart` | Added client role redirection to `/client/dashboard` and isolated routes |
| `lib/core/routing/role_menu_config.dart` | Added empty navigation menu for client role |
| `lib/features/auth/domain/models/user_role.dart` | Added `UserRole.client` enum value and parser |
| `lib/features/auth/domain/models/user.dart` | Added `isClient` getter |
| `lib/features/auth/data/models/user_profile.dart` | Added `isClient` getter |
| `lib/features/auth/presentation/providers/auth_notifier.dart` | Added `setAuthenticated(UserProfile)` method |
| `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | Added exhaustive switch handling for `UserRole.client` |
| `lib/features/documents/data/models/document_model.dart` | Added `title`, `checksum`, `mime_type`, `file_size`, `access_policy` |
| `lib/features/clients/presentation/screens/client_detail_screen.dart` | Added WhatsApp message, Share Document, and Invite Client action buttons |
| `lib/features/hearings/presentation/screens/hearing_detail_screen.dart` | Added Send WhatsApp Reminder action button |
| `lib/features/shell/presentation/screens/app_shell.dart` | Restored watermark background wrapping |
| `lib/features/subscriptions/data/repositories/subscriptions_repository.dart` | Added `getPaymentGateway`, `savePaymentGateway`, `getSubscriptionTransactions` |
| `lib/features/subscriptions/presentation/screens/platform_plans_screen.dart` | Refactored into 3 tabs (Plans, Payment Gateway, Transactions) |
| `lib/main.dart` | Wrapped `MaterialApp` inside `PaywallBarrier` |
| `lib/shared/widgets/error_state_widget.dart` | Added Request ID chip with tap-to-copy |
| `lib/shared/widgets/firm_watermark_background.dart` | Restored firm legal seal and name rendering |

---

## 4. API Endpoints Contract Reference

| Endpoint | Method | Headers / Auth | Payload / Parameters | Expected Response |
|---|---|---|---|---|
| `/api/portal/auth/login/` | `POST` | Public | `{ "username_or_email": "...", "password": "..." }` | `{ "token": "...", "user": { "id": 1, "username": "...", ... } }` |
| `/api/portal/auth/accept-invite/` | `POST` | Public | `{ "token": "...", "username": "...", "password": "...", "first_name": "...", "last_name": "..." }` | `{ "token": "...", "user": { "id": 1, ... } }` |
| `/api/portal/hearings/` | `GET` | Bearer Token | None | `{ "client_name": "...", "hearings": [...], "cases": [...], "assigned_lawyers": [...] }` |
| `/api/portal/documents/` | `GET` | Bearer Token | Query: `?search=term` | `[ { "id": 1, "title": "...", "file_size": 1048576, "mime_type": "application/pdf", ... } ]` |
| `/api/portal/documents/:id/link/` | `GET` | Bearer Token | Query: `?disposition=inline` | `{ "download_url": "...", "download_path": "...", "token": "...", "expires_in_seconds": 300 }` |
| `/api/portal/documents/:id/download/` | `GET` | Query Token | Query: `?token=...&disposition=inline` | Binary PDF / file stream bytes |
| `/api/documents/:id/share/` | `POST` | Bearer Token | `{ "client_id": 1, "access_policy": "time_bound", "expires_at": "..." }` | `{ "id": 10, "client_name": "...", "access_policy": "time_bound" }` |
| `/api/documents/shares/:id/revoke/` | `POST` | Bearer Token | None | `{ "success": true }` |
| `/api/clients/:id/invite/` | `POST` | Bearer Token | `{ "email": "client@example.com", "name": "Client Name" }` | `{ "token": "...", "invite_url": "https://.../client/accept-invite?token=..." }` |
| `/api/communications/whatsapp/send/` | `POST` | Bearer Token | `{ "recipient_number": "...", "recipient_name": "...", "template": "...", "template_params": { ... } }` | `{ "id": 1, "status": "sent", "provider": "meta_cloud", "chat_url": "..." }` |
| `/api/communications/whatsapp/templates/` | `GET` | Bearer Token | None | `[ { "name": "hearing_reminder", "label": "Hearing Reminder", "params": [...] } ]` |
| `/api/communications/preferences/:id/` | `GET`/`PUT` | Bearer Token | `{ "preferred_channel": "both", "whatsapp_consent": true, "whatsapp_number": "..." }` | `{ "preferred_channel": "both", "whatsapp_consent": true, ... }` |
| `/api/admin/gateway/` | `GET`/`POST`| Super Admin Token | `{ "provider": "razorpay", "key_id": "...", "key_secret": "...", "is_test_mode": false, "is_active": true }` | `{ "provider": "razorpay", "key_id": "...", ... }` |
| `/api/admin/subscriptions/transactions/` | `GET` | Super Admin Token | None | `[ { "id": 1, "order_id": "...", "firm_name": "...", "amount": 15000, "status": "captured" } ]` |

---

## 5. Automated Test & Static Analysis Results

### 5.1. Static Analysis Check
Command executed:
```bash
flutter analyze
```
**Output:**
```
Analyzing flutter_application_1...
No issues found! (ran in 9.8s)
```
- **Total Diagnostics**: 0 errors, 0 warnings, 0 lints.

### 5.2. Automated Test Suite
Command executed:
```bash
flutter test
```
**Output:**
```
00:19 +214: All tests passed!
```
- **Total Tests Passed**: 214 tests (100% pass rate).
- **Core Coverage**:
  - `test/core/errors/api_exception_standardized_test.dart` (3 tests)
  - `test/core/routing/app_router_test.dart` (12 tests)
  - `test/features/client_portal/client_portal_models_test.dart` (3 tests)
  - `test/features/communications/whatsapp_models_test.dart` (3 tests)
  - `test/features/subscriptions/admin_gateway_models_test.dart` (2 tests)
  - `test/features/subscriptions/paywall_screens_test.dart` (2 tests)
  - Existing suite: All branding, documents, tasks, subscriptions, and shell tests passing.

---

## 6. Manual & QA Testing Checkpoints

Follow these step-by-step checkpoints to manually verify each workflow on a test build or device.

### Checkpoint 1: Client Portal Login & Navigation
- [ ] **Step 1**: Launch the application.
- [ ] **Step 2**: Tap **"Client Portal Access"** on the main login screen or navigate to `/client/login`.
- [ ] **Step 3**: Verify the screen displays the branded Client Portal header with username/email and password fields.
- [ ] **Step 4**: Enter invalid credentials. Verify an inline error message appears without crashing.
- [ ] **Step 5**: Enter valid client credentials and submit. Verify navigation routes directly to `/client/dashboard`.
- [ ] **Step 6**: Verify that entering firm admin URLs (e.g. `/app/dashboard` or `/admin/plans`) while logged in as a client redirects back to `/client/dashboard`.

### Checkpoint 2: Client Invitation Acceptance Flow
- [ ] **Step 1**: Log in as a Firm Admin or Lawyer.
- [ ] **Step 2**: Open any client's detail page (`/app/clients/:id`).
- [ ] **Step 3**: Tap the **"Invite to Portal"** action button.
- [ ] **Step 4**: Confirm or edit the client email and full name, then tap **"Generate Client Invite"**.
- [ ] **Step 5**: Verify a success dialog displays the invitation link (`/client/accept-invite?token=...`) and copy it to clipboard.
- [ ] **Step 6**: Open the URL in the app or paste the token into `/client/accept-invite`.
- [ ] **Step 7**: Verify the token field is pre-filled, fill in username, first name, last name, and password, then tap **"Activate Portal Account"**.
- [ ] **Step 8**: Verify immediate redirection into the Client Dashboard.

### Checkpoint 3: Client Dashboard Feed
- [ ] **Step 1**: Log in as an invited client.
- [ ] **Step 2**: Verify the **"Next Court Hearing"** card displays:
  - Hearing date and time.
  - Court name (e.g., "High Court Hall 3").
  - Countdown chip (e.g. `TODAY`, `TOMORROW`, or `IN X DAYS`).
- [ ] **Step 3**: Verify the **"Assigned Legal Counsel"** card displays the lawyer's name and email.
- [ ] **Step 4**: Tap the **"Call"** button; verify device phone dialer opens with the lawyer's number.
- [ ] **Step 5**: Tap the **"Email"** button; verify email composer opens with counsel's email.
- [ ] **Step 6**: Switch to the **"Active Cases"** tab; verify case numbers and statuses match client representations.
- [ ] **Step 7**: Switch to the **"Documents"** tab; test typing into the search field to filter documents dynamically.

### Checkpoint 4: Secure Document Viewing & 300s Signed Token Expiration
- [ ] **Step 1**: On the Client Dashboard documents tab, tap **"View Document"** on a shared PDF.
- [ ] **Step 2**: Verify the app navigates to `/client/documents/:id`.
- [ ] **Step 3**: Verify that the document viewer loads and displays the PDF pages in-app.
- [ ] **Step 4**: Tap the **"Save to Device"** action in the app bar; verify download completes and a confirmation snackbar appears.
- [ ] **Step 5**: Inspect network requests to confirm the signed URL had a `token` parameter and `expires_in_seconds: 300`.

### Checkpoint 5: Lawyer Document Sharing Modal
- [ ] **Step 1**: Log in as a Firm Admin or Lawyer.
- [ ] **Step 2**: Open a client profile and tap **"Share Document"**.
- [ ] **Step 3**: Select a document from the dropdown.
- [ ] **Step 4**: Choose an expiration policy:
  - `No Expiration (Indefinite)`
  - `24 Hours`
  - `7 Days`
  - `30 Days`
- [ ] **Step 5**: Tap **"Confirm & Share Document"**.
- [ ] **Step 6**: Verify the client's shared documents list immediately reflects the newly shared item with correct expiration badge.
- [ ] **Step 7**: Tap **"Revoke"** next to the shared file; verify access is cancelled and the file disappears from the client's portal.

### Checkpoint 6: WhatsApp Messaging & Opt-In Guard
- [ ] **Step 1**: On a Client Detail or Hearing Detail screen, tap **"WhatsApp"** / **"Send WhatsApp Reminder"**.
- [ ] **Step 2**: If the client has not opted in, verify an orange banner prompts: *"Client has not explicitly opted in to WhatsApp notices"*.
- [ ] **Step 3**: Tap **"Update Preferences"**, toggle **"WhatsApp Consent"** ON, enter a valid phone number, and tap **"Save Preferences"**.
- [ ] **Step 4**: Open the WhatsApp composer again; select the **"Hearing Reminder"** template.
- [ ] **Step 5**: Verify template parameters (`Case Title`, `Hearing Date`, `Court Name`) are populated.
- [ ] **Step 6**: Tap **"Send WhatsApp Notice"**.
- [ ] **Step 7**: If Meta Cloud API credentials are live, verify the message status shows `sent`. If running in local test mode, verify WhatsApp Click-to-Chat opens with the pre-filled text.

### Checkpoint 7: Standardized Error Envelopes & Correlation ID
- [ ] **Step 1**: Trigger any server error (e.g., submit an invalid form or enter non-existent ID).
- [ ] **Step 2**: Verify the error dialog or inline error widget displays the user-friendly message.
- [ ] **Step 3**: Verify a grey chip appears displaying `Ref: <request-id>`.
- [ ] **Step 4**: Tap the chip; verify a snackbar confirms *"Request ID copied to clipboard"*.

### Checkpoint 8: Paywall Barrier — `FIRM_BLOCKED`
- [ ] **Step 1**: Simulate or send a 403 API response with `{ "error": { "code": "FIRM_BLOCKED", "message": "Your firm has been suspended." } }`.
- [ ] **Step 2**: Verify the full-screen [FirmSuspendedScreen](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/screens/firm_suspended_screen.dart) displays immediately.
- [ ] **Step 3**: Verify navigation is blocked and back button does not dismiss the paywall.
- [ ] **Step 4**: Verify the **"Request Reference"** chip displays the correlation ID.
- [ ] **Step 5**: Tap **"Email Support"**; verify mailto composer opens addressed to `support@vidhanta.com`.
- [ ] **Step 6**: Tap **"Sign Out"**; verify the user is logged out and returned to the clean login screen.

### Checkpoint 9: Paywall Barrier — `SUBSCRIPTION_EXPIRED`
- [ ] **Step 1**: Simulate or send an API response with `{ "error": { "code": "SUBSCRIPTION_EXPIRED", "message": "Your firm trial has lapsed." } }`.
- [ ] **Step 2**: Verify the full-screen [SubscriptionExpiredScreen](file:///c:/Users/MAULIK/Desktop/Internship/Flutter/flutter_application_1/lib/features/subscriptions/presentation/screens/subscription_expired_screen.dart) displays immediately.
- [ ] **Step 3**: For Firm Admins: Verify the **"Renew Firm Subscription"** card and **"View Subscription Plans"** CTA are visible.
- [ ] **Step 4**: For Staff/Lawyers: Verify the message instructs contacting the firm administrator.

### Checkpoint 10: Super Admin Payment Gateway & Transactions Log
- [ ] **Step 1**: Log in as Super Admin (`is_superuser: true` or `role: 'super_admin'`).
- [ ] **Step 2**: Navigate to `/app/more/plans` (Platform Plans).
- [ ] **Step 3**: Verify three tabs are available:
  - *Subscription Plans*
  - *Payment Gateway*
  - *Transactions Log*
- [ ] **Step 4**: Switch to **"Payment Gateway"** tab:
  - Enter Key ID: `rzp_test_sample123`
  - Enter Key Secret: `test_secret_abc`
  - Toggle **"Test Mode (Sandbox)"** ON.
  - Toggle **"Gateway Enabled"** ON.
  - Tap **"Save Gateway Settings"**; verify success snackbar.
- [ ] **Step 5**: Switch to **"Transactions Log"** tab:
  - Verify list of firm subscription transactions loads with firm name, plan name, formatted INR amount (e.g. `₹15,000.00`), status badge (`captured`), and creation date.
  - Pull down to refresh list.

---

## 7. Quality & Verification Sign-Off

- **Codebase Integrity**: Modified in-place within the existing Flutter project; no dummy screens or placeholder architectures.
- **Backend Adherence**: Uses verified endpoints matching Django REST Framework contracts and `Changes.md`.
- **Static Analysis**: `flutter analyze` passed with **0 issues**.
- **Automated Tests**: `flutter test` passed with **214/214 tests**.
- **Security Check**: No hardcoded API keys or unmasked secrets in logs or source files.
