import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            return  # Skip running header/footer on cover page

        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#1E3A8A"))

        # Running Header
        self.drawString(36, 810, "NTS LEGAL PRO")
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(108, 810, "|   Master Application Testing & QA Verification Manual")
        self.drawRightString(559, 810, "CONFIDENTIAL - QA TESTING SUITE")
        
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.7)
        self.line(36, 804, 559, 804)

        # Running Footer
        self.line(36, 42, 559, 42)
        self.drawString(36, 30, "System: Flutter Legal Management Platform | Live Backend: https://api.hphighcourt.site/api/")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#1E3A8A"))
        self.drawRightString(559, 30, page_str)
        self.restoreState()


def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=48,
        bottomMargin=52
    )

    styles = getSampleStyleSheet()

    # Custom styles
    c_primary = colors.HexColor("#0F172A")
    c_secondary = colors.HexColor("#1E3A8A")
    c_accent = colors.HexColor("#B45309")
    c_slate = colors.HexColor("#334155")
    c_light = colors.HexColor("#F8FAFC")
    c_border = colors.HexColor("#CBD5E1")

    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=28,
        leading=34,
        textColor=colors.HexColor("#0F172A"),
        alignment=0,
    )

    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=18,
        textColor=colors.HexColor("#475569"),
        alignment=0,
    )

    badge_style = ParagraphStyle(
        'CoverBadge',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.white,
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=20,
        textColor=c_secondary,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True,
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=c_primary,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True,
    )

    h3_style = ParagraphStyle(
        'Heading3_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor("#1E40AF"),
        spaceBefore=6,
        spaceAfter=3,
        keepWithNext=True,
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=c_slate,
    )

    body_bold = ParagraphStyle(
        'Body_Bold_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=12,
        textColor=c_primary,
    )

    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7.5,
        leading=10,
        textColor=colors.HexColor("#0F172A"),
    )

    table_header = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white,
        alignment=1,
    )

    table_cell = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=c_slate,
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=c_primary,
    )

    table_cell_center = ParagraphStyle(
        'TableCellCenter',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=c_slate,
        alignment=1,
    )

    table_cell_code = ParagraphStyle(
        'TableCellCode',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7,
        leading=9,
        textColor=colors.HexColor("#0F172A"),
    )

    status_pass = ParagraphStyle(
        'StatusPass',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7,
        leading=9,
        textColor=colors.HexColor("#065F46"),
        alignment=1,
    )

    status_block = ParagraphStyle(
        'StatusBlock',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7,
        leading=9,
        textColor=colors.HexColor("#991B1B"),
        alignment=1,
    )

    callout_text = ParagraphStyle(
        'CalloutText',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=colors.HexColor("#1E293B"),
    )

    story = []

    # =========================================================================
    # COVER PAGE
    # =========================================================================
    story.append(Spacer(1, 20))
    
    # Top Tag
    tag_table = Table(
        [[Paragraph("ENTERPRISE QA & VERIFICATION MANUAL", badge_style)]],
        colWidths=[240]
    )
    tag_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#1E3A8A")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
    ]))
    story.append(tag_table)
    story.append(Spacer(1, 14))

    story.append(Paragraph("NTS LEGAL PRO", title_style))
    story.append(Spacer(1, 4))
    story.append(Paragraph("End-to-End Application Testing Guide & QA Verification Manual", subtitle_style))
    story.append(Spacer(1, 10))
    story.append(HRFlowable(width="100%", thickness=2, color=c_secondary, spaceBefore=4, spaceAfter=14))

    # Meta Overview Box
    meta_data = [
        [
            Paragraph("<b>Target System:</b>", body_style),
            Paragraph("NTS Legal Pro Multi-Tenant Legal Platform", body_bold),
            Paragraph("<b>Document Version:</b>", body_style),
            Paragraph("v2.4.0-Enterprise (Build 2026.10)", body_bold),
        ],
        [
            Paragraph("<b>Client Architecture:</b>", body_style),
            Paragraph("Flutter (iOS, Android, Web, Desktop) + Riverpod + GoRouter", body_style),
            Paragraph("<b>Classification:</b>", body_style),
            Paragraph("<font color='#B45309'><b>CONFIDENTIAL / INTERNAL QA</b></font>", body_style),
        ],
        [
            Paragraph("<b>Live Backend API:</b>", body_style),
            Paragraph("https://api.hphighcourt.site/api/", code_style),
            Paragraph("<b>Target Commit:</b>", body_style),
            Paragraph("fa64f951c924 (v2.4.0)", code_style),
        ],
        [
            Paragraph("<b>Testing Scope:</b>", body_style),
            Paragraph("<b>21 Functional Modules | 5 User Roles | 65+ Formal Test Cases</b>", body_style),
            Paragraph("<b>Sign-off Date:</b>", body_style),
            Paragraph("October 2026", body_style),
        ],
    ]
    meta_table = Table(meta_data, colWidths=[100, 165, 100, 155])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 16))

    # Executive Summary Card
    exec_text = (
        "<b>EXECUTIVE PURPOSE & SCOPE OF THIS TESTING SUITE:</b><br/>"
        "This manual is the definitive, multi-role testing and quality assurance specification for the "
        "<b>NTS Legal Pro</b> Flutter application. It delivers a comprehensive methodology to validate all features "
        "across all five system personas: <b>Platform Super Administrator</b>, <b>Firm Managing Administrator</b>, "
        "<b>Advocate / Lawyer</b>, <b>Legal Assistant / Staff</b>, and <b>End-Client (Client Portal)</b>.<br/><br/>"
        "Every test case provides precise operational steps, exact input parameters, live backend API interactions, "
        "expected interface state changes, and explicit regression verification criteria covering recent critical updates: "
        "<b>Client Document Portal</b>, <b>Cryptographic SHA-256 Document Security</b>, <b>WhatsApp Dynamic Dispatch</b>, "
        "<b>Reactive Firm Paywalls (FIRM_BLOCKED / SUBSCRIPTION_EXPIRED)</b>, <b>Razorpay Platform Billing</b>, and "
        "<b>Strict Multi-Tenant Isolation & Role-Based Access Control (RBAC)</b>."
    )
    exec_table = Table([[Paragraph(exec_text, callout_text)]], colWidths=[520])
    exec_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#EFF6FF")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#93C5FD")),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(exec_table)
    story.append(Spacer(1, 16))

    # Document Structure Table of Contents
    story.append(Paragraph("DOCUMENT OUTLINE & ROADMAP", h2_style))
    toc_data = [
        [Paragraph("<b>Section 1</b>", table_cell_bold), Paragraph("Executive Testing Architecture, Environments & Verified Personas", table_cell), Paragraph("Page 2", table_cell_center)],
        [Paragraph("<b>Section 2</b>", table_cell_bold), Paragraph("Comprehensive Role-Based Access Control (RBAC) & Capability Matrix", table_cell), Paragraph("Page 3", table_cell_center)],
        [Paragraph("<b>Section 3</b>", table_cell_bold), Paragraph("Granular Step-by-Step Test Suites (TC-01 through TC-15)", table_cell), Paragraph("Pages 4-15", table_cell_center)],
        [Paragraph("<b>Section 4</b>", table_cell_bold), Paragraph("Critical Regression & Bug-Fix Verification Suite (Checkpoints R-01 to R-07)", table_cell), Paragraph("Page 16", table_cell_center)],
        [Paragraph("<b>Section 5</b>", table_cell_bold), Paragraph("Master Testing Checklist, Defect Policies & Formal QA Sign-Off Matrix", table_cell), Paragraph("Pages 17-18", table_cell_center)],
    ]
    toc_table = Table(toc_data, colWidths=[65, 395, 60])
    toc_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#F1F5F9")),
        ('ROWBACKGROUNDS', (0,0), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 0.5, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(toc_table)
    story.append(Spacer(1, 20))

    # Sign-off box on cover
    sign_data = [
        [
            Paragraph("<b>QA Lead Reviewer:</b> ___________________________", body_style),
            Paragraph("<b>Lead Engineer:</b> ___________________________", body_style),
            Paragraph("<b>Test Execution Date:</b> ____/____/2026", body_style),
        ]
    ]
    sign_table = Table(sign_data, colWidths=[175, 175, 170])
    sign_table.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 0.5, c_border),
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(sign_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 1: ARCHITECTURE, ENVIRONMENTS & TEST PERSONAS
    # =========================================================================
    story.append(Paragraph("SECTION 1: TESTING ARCHITECTURE, ENVIRONMENTS & CREDENTIALS", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_secondary, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph("1.1 Architecture & Core Foundation", h2_style))
    arch_desc = (
        "The NTS Legal Pro client application is built upon Flutter with strict architectural decoupling:<br/>"
        "• <b>Multi-Tenant Isolation:</b> All firm queries, mutations, document repositories, and communications are "
        "partitioned by firm tenant ID (`firm_id`). Under no circumstances may data leak across tenant boundaries.<br/>"
        "• <b>Role-Based Access Control (RBAC):</b> Dynamic shell navigation, screen gates (`RoleGate`, `CapabilityGate`), "
        "and route guards enforce authorized access prior to any screen load or API call.<br/>"
        "• <b>Reactive Paywall Interceptors:</b> Global HTTP error interceptors watch for 403 response payloads carrying "
        "machine codes <code>FIRM_BLOCKED</code> and <code>SUBSCRIPTION_EXPIRED</code>, instantly raising full-screen "
        "blocking modal barriers that halt operations until administrative clearance or plan renewal.<br/>"
        "• <b>Observability & Tracing:</b> Every HTTP request to <code>https://api.hphighcourt.site/api/</code> captures "
        "the <code>X-Request-ID</code> header. Correlation chips in the UI permit one-tap copying for triage."
    )
    story.append(Paragraph(arch_desc, body_style))
    story.append(Spacer(1, 8))

    story.append(Paragraph("1.2 Verified Live Test Credentials & Personas", h2_style))
    story.append(Paragraph("The following credentials have been validated against the live production backend for QA execution:", body_style))
    story.append(Spacer(1, 4))

    cred_data = [
        [
            Paragraph("System Persona", table_header),
            Paragraph("Username / Email", table_header),
            Paragraph("Password", table_header),
            Paragraph("Firm ID", table_header),
            Paragraph("Testing Role & Scope of Authority", table_header),
        ],
        [
            Paragraph("<b>Firm Admin</b>", table_cell_bold),
            Paragraph("<code>testlawyer_fe69b5</code>", table_cell_code),
            Paragraph("<code>TestPassword@123</code>", table_cell_code),
            Paragraph("15", table_cell_center),
            Paragraph("Managing Partner. Full financial, litigation, team, subscription, and branding authority.", table_cell),
        ],
        [
            Paragraph("<b>Lawyer / Advocate</b>", table_cell_bold),
            Paragraph("<code>lawyer_7cc7d</code>", table_cell_code),
            Paragraph("<code>TestPassword@123</code>", table_cell_code),
            Paragraph("15", table_cell_center),
            Paragraph("Practicing Legal Counsel. Cases, documents, hearings, clients. Barred from financials & team billing.", table_cell),
        ],
        [
            Paragraph("<b>Legal Staff</b>", table_cell_bold),
            Paragraph("<code>staff_7cc7d</code>", table_cell_code),
            Paragraph("<code>TestPassword@123</code>", table_cell_code),
            Paragraph("15", table_cell_center),
            Paragraph("Paralegal / Coordination. Primary Tasks tab, hearings, client intake. Barred from Cases & Documents (403).", table_cell),
        ],
        [
            Paragraph("<b>Client Portal</b>", table_cell_bold),
            Paragraph("Dynamic Invite Token / <code>client_user</code>", table_cell_code),
            Paragraph("User Defined / <code>TestPassword@123</code>", table_cell_code),
            Paragraph("15", table_cell_center),
            Paragraph("End-Client Portal. Dedicated shell (`/client/dashboard`), hearings countdown, assigned counsel, secure 300s token viewer.", table_cell),
        ],
        [
            Paragraph("<b>Super Admin</b>", table_cell_bold),
            Paragraph("<code>superadmin</code>", table_cell_code),
            Paragraph("<code>PlatformAdmin@2026</code>", table_cell_code),
            Paragraph("System", table_cell_center),
            Paragraph("Platform Owner. Platform plans, tenant firms registry, firm block/unblock, Razorpay gateway config, audit logs.", table_cell),
        ],
    ]
    cred_table = Table(cred_data, colWidths=[90, 110, 95, 45, 180])
    cred_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(cred_table)
    story.append(Spacer(1, 10))

    story.append(Paragraph("1.3 Core Network & Security Endpoints", h2_style))
    net_data = [
        [Paragraph("Category", table_header), Paragraph("HTTP Route", table_header), Paragraph("Auth Requirement", table_header), Paragraph("Expected Behavior / Envelope", table_header)],
        [Paragraph("Standard Auth", table_cell_bold), Paragraph("<code>POST /api/auth/login/</code>", table_cell_code), Paragraph("Public", table_cell), Paragraph("Returns JWT access, refresh tokens, user profile, role, and firm ID", table_cell)],
        [Paragraph("Client Auth", table_cell_bold), Paragraph("<code>POST /api/client-portal/login/</code>", table_cell_code), Paragraph("Public", table_cell), Paragraph("Dedicated portal login; sets client session and routes to `/client/dashboard`", table_cell)],
        [Paragraph("Client Invite", table_cell_bold), Paragraph("<code>POST /api/clients/:id/invite/</code>", table_cell_code), Paragraph("Firm Admin / Lawyer", table_cell), Paragraph("Generates tokenized URL (validating zero localhost host leakage)", table_cell)],
        [Paragraph("Signed Doc Token", table_cell_bold), Paragraph("<code>GET /api/client-portal/documents/:id/access-link/</code>", table_cell_code), Paragraph("Client Bearer", table_cell), Paragraph("Returns single-use token expiring in precisely 300 seconds (5 minutes)", table_cell)],
        [Paragraph("Doc Streaming", table_cell_bold), Paragraph("<code>GET /api/client-portal/documents/download/:id/?token=...</code>", table_cell_code), Paragraph("Query Token", table_cell), Paragraph("Streams binary PDF bytes directly into in-app viewer or device storage", table_cell)],
        [Paragraph("WhatsApp Send", table_cell_bold), Paragraph("<code>POST /api/communications/whatsapp/send/</code>", table_cell_code), Paragraph("Firm Roles", table_cell), Paragraph("Dispatches Meta Cloud API payload with Click-to-Chat fallback", table_cell)],
        [Paragraph("Paywall Intercept", table_cell_bold), Paragraph("<code>GET /api/cases/</code> (Blocked Firm)", table_cell_code), Paragraph("Any Token", table_cell), Paragraph("403 Forbidden with <code>errorCode: 'FIRM_BLOCKED'</code> triggers blocking overlay", table_cell)],
    ]
    net_table = Table(net_data, colWidths=[80, 160, 100, 180])
    net_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(net_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 2: ROLE-BASED ACCESS CONTROL (RBAC) MATRIX
    # =========================================================================
    story.append(Paragraph("SECTION 2: ROLE-BASED ACCESS CONTROL (RBAC) & CAPABILITY MATRIX", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_secondary, spaceBefore=2, spaceAfter=8))

    rbac_intro = (
        "The following matrix outlines all 18 functional capability areas implemented across the Flutter "
        "application and enforces strict validation between the 5 user roles. In addition to hiding UI controls, "
        "all blocked routes are guarded by <code>RoleGuard</code> in <code>app_router.dart</code> and reject access with "
        "immediate redirection or 403 Forbidden error handling."
    )
    story.append(Paragraph(rbac_intro, body_style))
    story.append(Spacer(1, 8))

    # RBAC Table
    rbac_data = [
        [
            Paragraph("Functional Capability Area", table_header),
            Paragraph("Super Admin", table_header),
            Paragraph("Firm Admin", table_header),
            Paragraph("Lawyer", table_header),
            Paragraph("Staff", table_header),
            Paragraph("Client", table_header),
            Paragraph("Live Backend & Router Guard Contract", table_header),
        ],
        [
            Paragraph("<b>Platform Tenant Registry</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/app/firms</code>: Redirects non-superadmins to dashboard", table_cell),
        ],
        [
            Paragraph("<b>Payment Gateway Config</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/admin/payment-gateway/</code>: Super Admin Razorpay keys", table_cell),
        ],
        [
            Paragraph("<b>Subscription Audit Log</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/admin/subscription-transactions/</code>: Platform audit", table_cell),
        ],
        [
            Paragraph("<b>Executive Financials</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>GET /api/payments/</code>: Returns 403 for non-admin", table_cell),
        ],
        [
            Paragraph("<b>Record & Collect Payments</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>POST /api/payments/</code>: Invoicing and billing records", table_cell),
        ],
        [
            Paragraph("<b>Subscription & Quotas</b>", table_cell_bold),
            Paragraph("<font color='#2563EB'>PLANS ONLY</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/app/more/subscriptions</code>: Meter and Razorpay plan renewal", table_cell),
        ],
        [
            Paragraph("<b>Team & User Management</b>", table_cell_bold),
            Paragraph("<font color='#2563EB'>PROVISION</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>POST /api/auth/add-user/</code>: Invite advocate & staff", table_cell),
        ],
        [
            Paragraph("<b>Firm Website & Branding</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/api/profile/firm/website/</code>: Tagline, bio, theme, colors", table_cell),
        ],
        [
            Paragraph("<b>Cases Litigation Hub</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#D97706'>MY CASES</font>", table_cell_center),
            Paragraph("<code>GET /api/cases/</code>: 403 Forbidden for staff; clients see own", table_cell),
        ],
        [
            Paragraph("<b>Confidential Case Files</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>403 BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#D97706'>SHARED ONLY</font>", table_cell_center),
            Paragraph("<code>GET /api/documents/</code>: Staff barred; client sees shared", table_cell),
        ],
        [
            Paragraph("<b>Document Sharing & Revoke</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/clients/:id/documents/:docId/share/</code>: Time-bound share", table_cell),
        ],
        [
            Paragraph("<b>Client Registry & Intake</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>GET/POST /api/clients/</code>: All firm members can manage clients", table_cell),
        ],
        [
            Paragraph("<b>Court Hearings & Docket</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#D97706'>MY HEARINGS</font>", table_cell_center),
            Paragraph("<code>GET /api/hearings/</code>: Full schedule for firm; client sees own", table_cell),
        ],
        [
            Paragraph("<b>Operational Tasks Board</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>ASSIGNED</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>PRIMARY TAB</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/app/tasks</code>: Primary destination in shell for staff role", table_cell),
        ],
        [
            Paragraph("<b>WhatsApp Dispatch</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("Template selection, param interpolation, Meta Cloud & Click-to-Chat", table_cell),
        ],
        [
            Paragraph("<b>Internal Colleague Chat</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#059669'><b>FULL</b></font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<code>/app/more/messages</code>: Internal messaging with case attaches", table_cell),
        ],
        [
            Paragraph("<b>Client Portal Experience</b>", table_cell_bold),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#DC2626'>BLOCKED</font>", table_cell_center),
            Paragraph("<font color='#059669'><b>DEDICATED</b></font>", table_cell_center),
            Paragraph("<code>/client/*</code>: Isolated navigation shell, countdown, 300s token", table_cell),
        ],
        [
            Paragraph("<b>User Profile & Settings</b>", table_cell_bold),
            Paragraph("<font color='#2563EB'>PLATFORM</font>", table_cell_center),
            Paragraph("<font color='#059669'>FIRM</font>", table_cell_center),
            Paragraph("<font color='#059669'>LAWYER</font>", table_cell_center),
            Paragraph("<font color='#059669'>STAFF</font>", table_cell_center),
            Paragraph("<font color='#059669'>CLIENT</font>", table_cell_center),
            Paragraph("<code>/api/profile/me/</code>: Personal settings & theme preferences", table_cell),
        ],
    ]
    rbac_table = Table(rbac_data, colWidths=[95, 48, 48, 52, 54, 48, 175])
    rbac_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 3.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3.5),
        ('LEFTPADDING', (0,0), (-1,-1), 4),
        ('RIGHTPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(rbac_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 3: STEP-BY-STEP TEST SUITES (MODULE BY MODULE)
    # =========================================================================
    story.append(Paragraph("SECTION 3: GRANULAR STEP-BY-STEP TEST SUITES", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_secondary, spaceBefore=2, spaceAfter=8))

    def make_test_case_box(tc_id, title, role, priority, objective, steps, expected, checkpoints):
        header_text = f"<b>{tc_id}: {title}</b>"
        meta_sub = f"<b>Target Persona:</b> {role}   |   <b>Priority:</b> {priority}"
        
        content = [
            [Paragraph(header_text, ParagraphStyle('TCHead', parent=body_bold, textColor=colors.white, fontSize=8.5, leading=11)), 
             Paragraph(meta_sub, ParagraphStyle('TCMeta', parent=body_style, textColor=colors.HexColor("#E0E7FF"), alignment=2, fontSize=7.5, leading=10))],
            [Paragraph(f"<b>Objective:</b> {objective}", body_style), ""],
            [Paragraph(f"<b>Step-by-Step Execution:</b><br/>{steps}", body_style), ""],
            [Paragraph(f"<b>Expected Application State:</b><br/>{expected}", body_style), ""],
            [Paragraph(f"<b>Verification Checkpoints:</b><br/>{checkpoints}", body_style), ""],
        ]
        
        t = Table(content, colWidths=[360, 160])
        t.setStyle(TableStyle([
            ('SPAN', (0,1), (1,1)),
            ('SPAN', (0,2), (1,2)),
            ('SPAN', (0,3), (1,3)),
            ('SPAN', (0,4), (1,4)),
            ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
            ('BACKGROUND', (0,1), (-1,-1), colors.HexColor("#F8FAFC")),
            ('BOX', (0,0), (-1,-1), 0.75, c_border),
            ('INNERGRID', (0,1), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('LEFTPADDING', (0,0), (-1,-1), 6),
            ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ]))
        return KeepTogether(t)

    # SUITE 1: AUTHENTICATION & ONBOARDING
    story.append(Paragraph("Suite TC-01: Authentication, Onboarding & User Lifecycle", h2_style))
    
    t1 = make_test_case_box(
        "TC-01.1", "Standard Multi-Role Sign-In & JWT Session Storage",
        "Firm Admin, Lawyer, Staff", "P0 - Critical",
        "Verify credentials authentication against live backend and correct JWT persistence.",
        "1. Open application to `/login`.<br/>"
        "2. Input username `testlawyer_fe69b5` and password `TestPassword@123`.<br/>"
        "3. Tap 'Sign In' button.<br/>"
        "4. Repeat test for `lawyer_7cc7d` and `staff_7cc7d`.",
        "• Network sends `POST /api/auth/login/` returning 200 OK with `access` & `refresh` tokens.<br/>"
        "• Secure storage securely caches JWT tokens.<br/>"
        "• App transitions immediately to `/app/dashboard`.",
        "[ ] Tokens stored securely | [ ] Header role badge matches persona | [ ] No UI latency"
    )
    story.append(t1)
    story.append(Spacer(1, 5))

    t2 = make_test_case_box(
        "TC-01.2", "Invalid Credentials & Form Validation",
        "All Roles", "P1 - High",
        "Verify system gracefully handles invalid passwords without crashing or uncaught exceptions.",
        "1. At `/login`, enter username `testlawyer_fe69b5` and incorrect password `WrongPass!99`.<br/>"
        "2. Tap 'Sign In'.<br/>"
        "3. Clear fields and tap 'Sign In' with empty values.",
        "• Client displays red inline error: 'Invalid username or password'.<br/>"
        "• Form highlights required fields with validation warnings.<br/>"
        "• Application remains stable without unhandled exception overlays.",
        "[ ] Clear inline feedback | [ ] Form disabled during in-flight request | [ ] Password obscured"
    )
    story.append(t2)
    story.append(Spacer(1, 5))

    t3 = make_test_case_box(
        "TC-01.3", "New Firm Registration & Onboarding",
        "Firm Admin", "P1 - High",
        "Verify law firm signup workflow registers firm entity and initializes administrator.",
        "1. Tap 'Register New Firm' on login view.<br/>"
        "2. Enter Firm Name: 'Alpha Legal LLP', Admin Username: 'alphalead_01', Email, and Password.<br/>"
        "3. Tap 'Complete Registration'.",
        "• Endpoint `POST /api/auth/register/` creates firm record.<br/>"
        "• Returns 201 Created and directs user to onboarding dashboard with trial subscription.",
        "[ ] Firm created in DB | [ ] Initial quota initialized | [ ] Welcome guide triggered"
    )
    story.append(t3)
    story.append(Spacer(1, 5))

    t4 = make_test_case_box(
        "TC-01.4", "Firm Member Invitation Acceptance",
        "Invited Lawyer / Staff", "P1 - High",
        "Verify invited team members can activate their account via query token link.",
        "1. Open link `/accept-invite?token=VALID_FIRM_INVITE_TOKEN`.<br/>"
        "2. Verify email is locked to invited address.<br/>"
        "3. Enter full name and set secure password; tap 'Activate Account'.",
        "• Endpoint `POST /api/auth/accept-invite/` validates token and provisions user.<br/>"
        "• Logs user in automatically and opens firm dashboard with assigned role permissions.",
        "[ ] Pre-filled email correct | [ ] Password strength enforced | [ ] Redirects to dashboard"
    )
    story.append(t4)
    story.append(Spacer(1, 10))

    # SUITE 2: DASHBOARD ADAPTATION
    story.append(Paragraph("Suite TC-02: Role-Adaptive Command Centers & Dashboards", h2_style))

    t5 = make_test_case_box(
        "TC-02.1", "Firm Admin Executive Command Center",
        "Firm Admin (`testlawyer_fe69b5`)", "P0 - Critical",
        "Verify executive dashboard delivers financial metrics, litigation summaries, and quick actions.",
        "1. Sign in as Firm Admin.<br/>"
        "2. Inspect the `/app/dashboard` surface.",
        "• Metrics display Active Cases, Total Clients, Pending Hearings, Revenue Collected (₹).<br/>"
        "• Quick Action buttons present: 'New Case', 'New Client', 'Schedule Hearing', 'Record Payment'.<br/>"
        "• Financial charts and recent transactions rendered cleanly.",
        "[ ] Revenue amounts formatted in INR | [ ] Quick actions navigate correctly | [ ] Watermark visible"
    )
    story.append(t5)
    story.append(Spacer(1, 5))

    t6 = make_test_case_box(
        "TC-02.2", "Lawyer Litigation Workspace Dashboard",
        "Lawyer (`lawyer_7cc7d`)", "P0 - Critical",
        "Verify advocate dashboard provides litigation-focused agenda and hides financial metrics.",
        "1. Sign in as Lawyer.<br/>"
        "2. Inspect the `/app/dashboard` surface.",
        "• Displays Courtroom Agenda (Upcoming hearings this week with court number & judge).<br/>"
        "• Displays Active Briefs filed and assigned legal tasks.<br/>"
        "• Financial revenue metrics and 'Record Payment' buttons are completely omitted.",
        "[ ] No revenue cards present | [ ] Quick actions omit billing | [ ] Court agenda accurate"
    )
    story.append(t6)
    story.append(Spacer(1, 5))

    t7 = make_test_case_box(
        "TC-02.3", "Staff Operations Command Center Dashboard",
        "Staff (`staff_7cc7d`)", "P0 - Critical",
        "Verify paralegal dashboard highlights operational tasks queue and hearing coordination.",
        "1. Sign in as Staff.<br/>"
        "2. Inspect `/app/dashboard`.",
        "• Highlights Pending Tasks Queue with interactive status toggles.<br/>"
        "• Today's Hearings card visible for client notice delivery and courtroom coordination.<br/>"
        "• Navigation bottom rail replaces 'Cases' with 'Tasks Queue' as direct primary tab.",
        "[ ] Primary Tasks destination present | [ ] Cases tab absent | [ ] One-tap task checkbox operational"
    )
    story.append(t7)
    story.append(Spacer(1, 10))

    # SUITE 3: CASES MANAGEMENT
    story.append(Paragraph("Suite TC-03: Legal Cases Management & Proceedings", h2_style))

    t8 = make_test_case_box(
        "TC-03.1", "Case Directory Listing, Filtering & Search",
        "Firm Admin, Lawyer", "P0 - Critical",
        "Verify case management repository supports multi-parameter filtering and search.",
        "1. Navigate to `/app/cases`.<br/>"
        "2. In search bar, type existing case title or CNR number.<br/>"
        "3. Filter by Status ('In Progress') and Court ('High Court').",
        "• Case list queries `GET /api/cases/` with query params.<br/>"
        "• Filtered list updates in real-time matching criteria.<br/>"
        "• Status chips display appropriate color codes (Green for Decided, Blue for In Progress).",
        "[ ] Dynamic search response < 300ms | [ ] Filter chips dismissible | [ ] Pagination functioning"
    )
    story.append(t8)
    story.append(Spacer(1, 5))

    t9 = make_test_case_box(
        "TC-03.2", "Case Creation Form & Client Association",
        "Firm Admin, Lawyer", "P0 - Critical",
        "Verify complete case initiation workflow associating client, court, and advocates.",
        "1. From `/app/cases`, tap '+' Floating Action Button.<br/>"
        "2. Select Client from dropdown or autocomplete search.<br/>"
        "3. Fill Case Title: 'State vs Kumar', Case Number: 'WP/2026/894', Court: 'High Court', Judge: 'Hon. Justice Verma'.<br/>"
        "4. Tap 'Save Case'.",
        "• Payload sent via `POST /api/cases/`.<br/>"
        "• Response 201 Created returns newly generated case record.<br/>"
        "• App navigates to `/app/cases/:id` detail screen.",
        "[ ] Client linked properly | [ ] Validation blocks empty title | [ ] Detail view populated"
    )
    story.append(t9)
    story.append(Spacer(1, 5))

    t10 = make_test_case_box(
        "TC-03.3", "Staff RBAC Route Barrier on Cases (403 Verification)",
        "Staff (`staff_7cc7d`)", "P0 - Security Critical",
        "Verify Staff persona is strictly barred from accessing cases via UI or direct URL.",
        "1. Log in as Staff.<br/>"
        "2. Attempt to navigate directly to `/app/cases` or `/app/cases/1` via deep link or URL.<br/>"
        "3. Observe router guard response.",
        "• `RoleGuard.evaluate()` intercepts navigation before screen renders.<br/>"
        "• Immediately redirects user back to `/app/dashboard`.<br/>"
        "• Direct API `GET /api/cases/` returns HTTP 403 Forbidden.",
        "[ ] Zero confidential case leakage | [ ] Smooth redirect without crash | [ ] 403 captured cleanly"
    )
    story.append(t10)
    story.append(Spacer(1, 10))

    # SUITE 4: CLIENT REGISTRY
    story.append(Paragraph("Suite TC-04: Client Registry, Intake & Portal Invitations", h2_style))

    t11 = make_test_case_box(
        "TC-04.1", "Client Intake Form & Directory Search",
        "Firm Admin, Lawyer, Staff", "P0 - Critical",
        "Verify client directory listing and new client registration workflow.",
        "1. Navigate to `/app/clients`.<br/>"
        "2. Tap 'Add Client'.<br/>"
        "3. Enter Name: 'Rajesh Sharma', Email: 'rajesh.sharma@example.com', Phone: '+919876543210', Address.<br/>"
        "4. Tap 'Save Client'.",
        "• Payload sent via `POST /api/clients/`.<br/>"
        "• Client appears in directory with status 'Active'.<br/>"
        "• Search bar immediately locates 'Rajesh Sharma'.",
        "[ ] Phone number formatted | [ ] Duplicate email warning if existing | [ ] Detail screen links"
    )
    story.append(t11)
    story.append(Spacer(1, 5))

    t12 = make_test_case_box(
        "TC-04.2", "Client Portal Invitation Flow (No Localhost Link Leak)",
        "Firm Admin, Lawyer", "P0 - Regression Critical",
        "Verify invitation dialog generates valid production token URL without localhost leakage.",
        "1. Open client detail page `/app/clients/:id`.<br/>"
        "2. Tap 'Invite to Portal' action button.<br/>"
        "3. In dialog, confirm client email and tap 'Generate Client Invite'.<br/>"
        "4. Inspect the generated invitation link.",
        "• Backend triggers `POST /api/clients/:id/invite/`.<br/>"
        "• Generated link MUST match <code>https://.../client/accept-invite?token=...</code> or deep link scheme.<br/>"
        "• Link must NEVER contain <code>http://localhost</code> or <code>127.0.0.1</code>.<br/>"
        "• Tap 'Copy to Clipboard'; verify snackbar confirms copy.",
        "[ ] Token length > 24 chars | [ ] Zero localhost strings | [ ] Copy to clipboard operational"
    )
    story.append(t12)
    story.append(Spacer(1, 5))

    t13 = make_test_case_box(
        "TC-04.3", "Client Communication Preferences & WhatsApp Opt-In",
        "Firm Admin, Lawyer", "P1 - High",
        "Verify client notification channel preferences modal and WhatsApp consent storage.",
        "1. On client detail view, tap 'Notification Preferences' / WhatsApp icon.<br/>"
        "2. Toggle 'Explicit WhatsApp Consent' to TRUE.<br/>"
        "3. Set Preferred Channel to 'Both' (WhatsApp & Email).<br/>"
        "4. Enter dedicated WhatsApp mobile: '+919876543210' and save.",
        "• Endpoint `PUT /api/clients/:id/communication-preferences/` records consent.<br/>"
        "• WhatsApp composer icon enables across case hearings and document modals.",
        "[ ] Switch states persist on reload | [ ] Audit timestamp recorded | [ ] Number validated"
    )
    story.append(t13)
    story.append(Spacer(1, 10))

    # SUITE 5: HEARINGS DOCKET
    story.append(Paragraph("Suite TC-05: Court Hearings & Docket Scheduling", h2_style))

    t14 = make_test_case_box(
        "TC-05.1", "Schedule Court Hearing with Dynamic Countdown Chip",
        "Firm Admin, Lawyer, Staff", "P0 - Critical",
        "Verify scheduling court hearings, judge allocation, and dynamic countdown computation.",
        "1. Navigate to `/app/hearings`.<br/>"
        "2. Tap '+' button.<br/>"
        "3. Link Case 'State vs Kumar', Hearing Date (set tomorrow's date), Court 'Room 4', Judge 'Hon. Sharma'.<br/>"
        "4. Set Stage: 'Final Arguments' and save.",
        "• Endpoint `POST /api/hearings/` registers hearing.<br/>"
        "• Hearing tile renders dynamic countdown chip: <b>TOMORROW</b> (or <b>TODAY</b> / <b>IN X DAYS</b>).<br/>"
        "• Tile appears in upcoming hearings list ordered chronologically.",
        "[ ] Countdown chip updates accurately | [ ] Case details link works | [ ] Staff can schedule"
    )
    story.append(t14)
    story.append(Spacer(1, 5))

    t15 = make_test_case_box(
        "TC-05.2", "One-Tap WhatsApp Hearing Reminder Dispatch",
        "Firm Admin, Lawyer, Staff", "P1 - High",
        "Verify hearing detail screen allows sending template-based WhatsApp reminders.",
        "1. Open hearing detail screen `/app/hearings/:id`.<br/>"
        "2. Tap 'Send WhatsApp Reminder' button.<br/>"
        "3. In composer modal, verify pre-filled parameters: Client Name, Hearing Date, Court Room.<br/>"
        "4. Tap 'Send Reminder via WhatsApp'.",
        "• Endpoint `POST /api/communications/whatsapp/send/` executes.<br/>"
        "• Message dispatched via Meta Cloud API / Twilio.<br/>"
        "• If direct delivery fails or in test mode, opens Click-to-Chat `https://wa.me/...` URL cleanly.",
        "[ ] Params interpolated correctly | [ ] Sent status badge displayed | [ ] Fallback operational"
    )
    story.append(t15)
    story.append(Spacer(1, 10))

    # SUITE 6: OPERATIONAL TASKS
    story.append(Paragraph("Suite TC-06: Operational Tasks Board & Workflow Execution", h2_style))

    t16 = make_test_case_box(
        "TC-06.1", "Create Operational Task & Staff Assignment",
        "Firm Admin, Lawyer, Staff", "P0 - Critical",
        "Verify creating legal tasks with priority levels, due dates, and assignee delegation.",
        "1. Navigate to Tasks board (`/app/tasks`).<br/>"
        "2. Tap 'New Task'.<br/>"
        "3. Title: 'Draft Affidavit for High Court', Case: 'State vs Kumar', Assignee: 'staff_7cc7d', Priority: 'Urgent'.<br/>"
        "4. Tap 'Create Task'.",
        "• Endpoint `POST /api/tasks/` persists task record.<br/>"
        "• Task appears in queue with Urgent red chip and initial status 'Pending'.",
        "[ ] Assignee notification triggered | [ ] Due date formatted | [ ] Case reference linked"
    )
    story.append(t16)
    story.append(Spacer(1, 5))

    t17 = make_test_case_box(
        "TC-06.2", "One-Tap Task Lifecycle Status Progression",
        "Staff, Lawyer", "P0 - Critical",
        "Verify rapid task status updates directly from list tiles.",
        "1. On `/app/tasks`, locate 'Draft Affidavit'.<br/>"
        "2. Tap status chip or checkbox to progress status: 'Pending' -> 'In Progress'.<br/>"
        "3. Tap again to mark 'Completed'.",
        "• Endpoint `PATCH /api/tasks/:id/` updates status field.<br/>"
        "• Visual style transitions from active to strike-through completed with green check.<br/>"
        "• Task count on dashboard updates instantaneously.",
        "[ ] Smooth optimistic UI update | [ ] Completed filter hides/shows task | [ ] No reload glitch"
    )
    story.append(t17)
    story.append(Spacer(1, 10))

    # SUITE 7: DOCUMENTS & SECURITY PIPELINE
    story.append(Paragraph("Suite TC-07: Document Security Pipeline & Cryptographic Sharing", h2_style))

    t18 = make_test_case_box(
        "TC-07.1", "Document Upload with SHA-256 Checksum & 25MB Limit",
        "Firm Admin, Lawyer", "P0 - Critical",
        "Verify client calculates SHA-256 hash and enforces 25MB file size limits on upload.",
        "1. Navigate to `/app/more/documents` -> 'Upload Document'.<br/>"
        "2. Select a PDF file (< 25MB).<br/>"
        "3. Attempt selecting a file > 25MB to verify blocking.<br/>"
        "4. Complete upload of valid file.",
        "• Large file > 25MB rejected client-side with alert: 'File exceeds 25MB maximum limit'.<br/>"
        "• Valid file computes SHA-256 hash.<br/>"
        "• Payload sent via `POST /api/documents/` storing checksum and MIME type.",
        "[ ] SHA-256 hash verified in metadata | [ ] Upload progress bar visible | [ ] 25MB limit strictly guarded"
    )
    story.append(t18)
    story.append(Spacer(1, 5))

    t19 = make_test_case_box(
        "TC-07.2", "Time-Bound Granular Document Sharing & Access Revocation",
        "Firm Admin, Lawyer", "P0 - Critical",
        "Verify selective document sharing to clients with expiration policies and instant revocation.",
        "1. Open document detail view `/app/more/documents/:id`.<br/>"
        "2. Tap 'Share with Client'.<br/>"
        "3. Select Client: 'Rajesh Sharma'. Choose policy: '7 Days'.<br/>"
        "4. Tap 'Confirm Share'. Verify client access list shows active badge.<br/>"
        "5. Tap 'Revoke Access' button.",
        "• Share endpoint `POST /clients/:clientId/documents/:id/share/` creates access rule.<br/>"
        "• Expiration policy calculated precisely 7 days forward.<br/>"
        "• Revoke endpoint deletes access record; file disappears from client portal view immediately.",
        "[ ] Expiry date computed correctly | [ ] Revoke takes instant effect | [ ] Audit log recorded"
    )
    story.append(t19)
    story.append(Spacer(1, 10))

    # SUITE 8: CLIENT PORTAL EXPERIENCE
    story.append(Paragraph("Suite TC-08: Client Portal Experience & 300s Signed Downloads", h2_style))

    t20 = make_test_case_box(
        "TC-08.1", "Client Portal Invitation Acceptance & Account Onboarding",
        "Client Persona", "P0 - Critical",
        "Verify end-client can accept token invite, set credentials, and transition into portal.",
        "1. Launch `/client/accept-invite?token=VALID_CLIENT_TOKEN`.<br/>"
        "2. Confirm token field is pre-filled and valid.<br/>"
        "3. Enter First Name, Last Name, Desired Username, and Password.<br/>"
        "4. Tap 'Activate Portal Account'.",
        "• Endpoint `POST /api/client-portal/accept-invite/` registers client account.<br/>"
        "• Returns JWT token with role `'client'`.<br/>"
        "• App transitions immediately to `/client/dashboard`.",
        "[ ] Token validation feedback | [ ] Password validation | [ ] Session persisted in storage"
    )
    story.append(t20)
    story.append(Spacer(1, 5))

    t21 = make_test_case_box(
        "TC-08.2", "Client Dashboard: Next Hearing Countdown & Counsel Launchers",
        "Client Persona", "P0 - Critical",
        "Verify client dashboard presents upcoming court hearing card and lead counsel dial/email actions.",
        "1. Sign in at `/client/login`.<br/>"
        "2. Inspect Next Hearing Card.<br/>"
        "3. Inspect Assigned Legal Counsel Card.<br/>"
        "4. Tap 'Call Lawyer' button; verify device phone dialer launches with counsel's number.<br/>"
        "5. Tap 'Email Lawyer' button; verify email composer opens.",
        "• Next Hearing displays court name, hearing purpose, and countdown badge (`TODAY`, `TOMORROW`).<br/>"
        "• URL launcher correctly handles `tel:` and `mailto:` URL schemes without throwing errors.",
        "[ ] Countdown accurate | [ ] Phone dialer opens | [ ] Email pre-populated with case reference"
    )
    story.append(t21)
    story.append(Spacer(1, 5))

    t22 = make_test_case_box(
        "TC-08.3", "Secure Document Preview & 300-Second Expiring Signed Token",
        "Client Persona", "P0 - Security Critical",
        "Verify client document view requests 300-second expiring download tokens on-demand.",
        "1. On client dashboard, switch to 'Documents' tab.<br/>"
        "2. Tap on shared document 'Petition Brief.pdf'.<br/>"
        "3. Verify navigation to `/client/documents/:id`.<br/>"
        "4. Observe PDF pages rendering in-app.<br/>"
        "5. Tap 'Download to Device' button in app bar.",
        "• App calls `GET /api/client-portal/documents/:id/access-link/` receiving signed token with `expires_in_seconds: 300`.<br/>"
        "• App streams PDF from `/download/:id/?token=...` directly into memory/viewer.<br/>"
        "• Download writes file to device downloads folder with success snackbar confirmation.<br/>"
        "• Token expired after 300 seconds will reject requests with 403 Forbidden.",
        "[ ] PDF renders crisply | [ ] Token expiration verified | [ ] File saved to local storage"
    )
    story.append(t22)
    story.append(Spacer(1, 5))

    t23 = make_test_case_box(
        "TC-08.4", "Client Role Route Isolation Guard",
        "Client Persona", "P0 - Security Critical",
        "Verify client is completely blocked from accessing firm back-office routes.",
        "1. While signed in as Client, attempt navigating to `/app/dashboard`, `/app/cases`, or `/app/more`.<br/>"
        "2. Observe router guard response.",
        "• `RoleGuard.evaluate()` detects client role attempting firm route.<br/>"
        "• Router immediately redirects user back to `/client/dashboard`.<br/>"
        "• Firm navigation bottom rail is never rendered for client.",
        "[ ] Zero back-office leakage | [ ] URL tampering resisted | [ ] Client navigation isolated"
    )
    story.append(t23)
    story.append(Spacer(1, 10))

    # SUITE 9: WHATSAPP ENGINE
    story.append(Paragraph("Suite TC-09: WhatsApp Communications Engine", h2_style))

    t24 = make_test_case_box(
        "TC-09.1", "Dynamic WhatsApp Template Catalog & Parameter Interpolation",
        "Firm Admin, Lawyer, Staff", "P1 - High",
        "Verify template catalog fetching and dynamic placeholder interpolation.",
        "1. Open WhatsApp composer from hearing or client screen.<br/>"
        "2. Select template 'Hearing Reminder' or 'Document Shared'.<br/>"
        "3. Inspect interpolated preview text.",
        "• Catalog fetched via `GET /api/communications/whatsapp/templates/`.<br/>"
        "• Placeholders `{{client_name}}`, `{{hearing_date}}`, `{{court_name}}` populated with live data.<br/>"
        "• Live preview box reflects exact message client will receive.",
        "[ ] No un-substituted `{{param}}` tags | [ ] Dynamic preview updates | [ ] Recipient mobile pre-filled"
    )
    story.append(t24)
    story.append(Spacer(1, 5))

    t25 = make_test_case_box(
        "TC-09.2", "WhatsApp Dispatch with Click-to-Chat Fallback",
        "Firm Admin, Lawyer, Staff", "P1 - High",
        "Verify message dispatch executes via Meta Cloud API or falls back to Click-to-Chat.",
        "1. In composer, confirm parameters and tap 'Send WhatsApp'.<br/>"
        "2. If gateway is in test mode or unconfigured, verify Click-to-Chat launches.",
        "• Endpoint `POST /api/communications/whatsapp/send/` handles delivery.<br/>"
        "• On fallback, app launches `https://wa.me/<number>?text=<encoded_message>` in device browser / WhatsApp app.",
        "[ ] Encoded text properly URL-escaped | [ ] Phone number includes country code | [ ] Success dialog"
    )
    story.append(t25)
    story.append(Spacer(1, 10))

    # SUITE 10: FINANCIALS & PAYMENTS
    story.append(Paragraph("Suite TC-10: Financials, Billing & Invoicing", h2_style))

    t26 = make_test_case_box(
        "TC-10.1", "Record Payment & Invoicing Lifecycle",
        "Firm Admin (`testlawyer_fe69b5`)", "P0 - Critical",
        "Verify firm admin can record client retainer/hearing fees and generate transaction receipts.",
        "1. Navigate to `/app/more/payments`.<br/>"
        "2. Tap 'Record Payment'.<br/>"
        "3. Select Client: 'Rajesh Sharma', Case: 'State vs Kumar', Amount: '₹25,000', Method: 'Bank Transfer'.<br/>"
        "4. Tap 'Save Payment'.",
        "• Endpoint `POST /api/payments/` records payment.<br/>"
        "• Payment appears in list with status badge 'Completed' and INR currency symbol (₹).<br/>"
        "• Executive dashboard revenue metrics increase by ₹25,000.",
        "[ ] Amount formatted in INR | [ ] Dashboard reflects updated total | [ ] Receipt preview available"
    )
    story.append(t26)
    story.append(Spacer(1, 5))

    t27 = make_test_case_box(
        "TC-10.2", "Financials Barrier on Non-Admin Roles (403 Enforcement)",
        "Lawyer, Staff", "P0 - Security Critical",
        "Verify Lawyer and Staff are strictly barred from viewing or creating payments.",
        "1. Log in as Lawyer or Staff.<br/>"
        "2. Verify 'Payments' menu item is hidden from `/app/more`.<br/>"
        "3. Attempt navigating directly to `/app/more/payments` via URL.",
        "• Router guard intercepts navigation and redirects back to `/app/dashboard`.<br/>"
        "• Backend returns HTTP 403 Forbidden on `GET /api/payments/` for non-admin tokens.",
        "[ ] No billing leak in UI | [ ] Route guard intercepts cleanly | [ ] 403 captured without crash"
    )
    story.append(t27)
    story.append(Spacer(1, 10))

    # SUITE 11: SUBSCRIPTIONS & REACTIVE PAYWALLS
    story.append(Paragraph("Suite TC-11: Subscriptions, Usage Quotas & Reactive Paywalls", h2_style))

    t28 = make_test_case_box(
        "TC-11.1", "Subscription Quota Meter & Plan Expiration Status",
        "Firm Admin", "P0 - Critical",
        "Verify firm subscription meter displays active plan, remaining days, and client capacity meter.",
        "1. Navigate to `/app/more/subscriptions`.<br/>"
        "2. Inspect Active Subscription Card and Client Quota Usage Bar.",
        "• Displays Current Plan ('Professional Tier'), Renewal Date, and Days Remaining.<br/>"
        "• Quota meter shows utilized capacity (e.g., '14 of 50 Clients Used') with percentage visual bar.<br/>"
        "• 'Upgrade Plan' button opens available tier pricing cards.",
        "[ ] Quota calculates percentage accurately | [ ] Days remaining matches backend | [ ] Tier cards displayed"
    )
    story.append(t28)
    story.append(Spacer(1, 5))

    t29 = make_test_case_box(
        "TC-11.2", "Reactive Paywall Overlay: Firm Blocked Barrier (`FIRM_BLOCKED`)",
        "All Firm Roles", "P0 - Security Critical",
        "Verify app raises full-screen non-dismissible barrier when firm is suspended or blocked.",
        "1. Trigger an API request that returns 403 Forbidden with error code `FIRM_BLOCKED` "
        "(or navigate to `/firm-blocked`).<br/>"
        "2. Observe UI response.",
        "• Network interceptor catches `FIRM_BLOCKED` and dispatches `FirmBlockedEvent`.<br/>"
        "• `PaywallBarrier` immediately mounts full-screen `FirmSuspendedScreen`.<br/>"
        "• Barrier cannot be dismissed by back button or swipe.<br/>"
        "• Displays Firm Blocked explanation, Contact Support action, and Request ID chip.",
        "[ ] Modal non-dismissible | [ ] Prevents all background API calls | [ ] Support button works"
    )
    story.append(t29)
    story.append(Spacer(1, 5))

    t30 = make_test_case_box(
        "TC-11.3", "Reactive Paywall Overlay: Subscription Expired (`SUBSCRIPTION_EXPIRED`)",
        "Firm Admin, Lawyer, Staff", "P0 - Security Critical",
        "Verify app raises subscription expired barrier allowing only firm admin to renew plans.",
        "1. Trigger API response returning 403 Forbidden with code `SUBSCRIPTION_EXPIRED` "
        "(or navigate to `/subscription-expired`).<br/>"
        "2. Observe UI response.",
        "• `SubscriptionExpiredScreen` mounts over the viewport.<br/>"
        "• For Firm Admin: Displays 'Renew Subscription' action button routing directly to payment gateway.<br/>"
        "• For Lawyer/Staff: Displays 'Subscription Lapsed - Please Contact Firm Administrator'.",
        "[ ] Non-admin blocked from payments | [ ] Admin guided to renew | [ ] Request ID displayed"
    )
    story.append(t30)
    story.append(Spacer(1, 5))

    t31 = make_test_case_box(
        "TC-11.4", "Correlation ID UI Chip & One-Tap Copy (`X-Request-ID`)",
        "All Roles", "P1 - High",
        "Verify error states extract `X-Request-ID` header and provide tap-to-copy chip for support triage.",
        "1. Trigger any error state (e.g. invalid request or paywall screen).<br/>"
        "2. Locate the Request ID chip (e.g., `req_a8f93b12...`).<br/>"
        "3. Tap on the chip.",
        "• Chip copies the full Request ID string to clipboard.<br/>"
        "• Snackbar confirms: 'Request ID copied to clipboard'.",
        "[ ] Format matches `req_<id>` | [ ] Tap feedback visible | [ ] Clipboard contains exact ID"
    )
    story.append(t31)
    story.append(Spacer(1, 10))

    # SUITE 12: SUPER ADMIN PLATFORM CONSOLE
    story.append(Paragraph("Suite TC-12: Super Admin Platform Console & Billing Management", h2_style))

    t32 = make_test_case_box(
        "TC-12.1", "Tenant Firms Registry & Block/Unblock Toggle",
        "Super Admin (`superadmin`)", "P0 - Critical",
        "Verify super admin can search all registered law firms and toggle their active/blocked status.",
        "1. Sign in as Super Admin; navigate to `/app/firms`.<br/>"
        "2. In search box, find target firm 'Alpha Legal LLP'.<br/>"
        "3. Tap 'Block Firm' toggle.<br/>"
        "4. Confirm blocking prompt. Verify status updates to 'Suspended'.<br/>"
        "5. Tap 'Unblock Firm' to restore normal active status.",
        "• Calls `POST /api/firms/:id/block/` and `POST /api/firms/:id/unblock/`.<br/>"
        "• Target firm users immediately encounter `FirmSuspendedScreen` upon their next API call.<br/>"
        "• Unblocking immediately restores tenant workspace access.",
        "[ ] Immediate backend persistence | [ ] Confirmation dialog prevents accidental click | [ ] Status badge updates"
    )
    story.append(t32)
    story.append(Spacer(1, 5))

    t33 = make_test_case_box(
        "TC-12.2", "Platform Plans & Razorpay Gateway Credentials Configuration",
        "Super Admin", "P0 - Critical",
        "Verify super admin can configure database-backed Razorpay gateway credentials and test mode.",
        "1. In platform console, navigate to `/app/plans`.<br/>"
        "2. Switch to 'Payment Gateway' tab.<br/>"
        "3. Enter Razorpay Key ID: `rzp_test_...`, Key Secret: `secret_...`, Webhook Secret, and toggle 'Test Mode' ON.<br/>"
        "4. Tap 'Save Gateway Credentials'.",
        "• Form sends `POST /api/admin/payment-gateway/`.<br/>"
        "• Platform updates active gateway in database without needing server environment restart.<br/>"
        "• Success snackbar confirms credentials saved.",
        "[ ] Secret key masked in UI | [ ] Test mode flag toggled cleanly | [ ] Subscriptions use saved keys"
    )
    story.append(t33)
    story.append(Spacer(1, 5))

    t34 = make_test_case_box(
        "TC-12.3", "Subscription Transactions Audit Log",
        "Super Admin", "P1 - High",
        "Verify super admin can audit all firm subscription payments, Razorpay order IDs, and amounts.",
        "1. On `/app/plans`, switch to 'Transactions Log' tab.<br/>"
        "2. Inspect transaction records table.",
        "• Table queries `GET /api/admin/subscription-transactions/`.<br/>"
        "• Columns display Firm Name, Plan Tier, Amount in INR (₹), Order ID, Payment ID, Status ('Captured'), and Date.<br/>"
        "• Search bar filters transactions by firm name or order reference.",
        "[ ] All payment records present | [ ] Order ID copyable | [ ] Currency formatted in INR"
    )
    story.append(t34)
    story.append(Spacer(1, 10))

    # SUITES 13, 14, 15: TEAM, BRANDING, SUPPORT
    story.append(Paragraph("Suites TC-13 to TC-15: Team, Branding, Messaging & Support", h2_style))

    t35 = make_test_case_box(
        "TC-13.1", "Firm Team Member Provisioning & Role Assignment",
        "Firm Admin", "P0 - Critical",
        "Verify adding new advocates and paralegals to firm team directory.",
        "1. Navigate to `/app/more/team`.<br/>"
        "2. Tap 'Add Team Member'.<br/>"
        "3. Enter Name: 'Adv. Priya Singh', Email, Mobile, and select Role: 'Lawyer'.<br/>"
        "4. Tap 'Provision Member'.",
        "• Calls `POST /api/auth/add-user/`.<br/>"
        "• Member appears in team directory with role badge 'Lawyer'.<br/>"
        "• Verification email with temp credentials dispatched.",
        "[ ] Role dropdown offers Lawyer & Staff | [ ] List reflects new member | [ ] Quota checked"
    )
    story.append(t35)
    story.append(Spacer(1, 5))

    t36 = make_test_case_box(
        "TC-14.1", "Firm Branding & Legal Watermark Restoration",
        "Firm Admin", "P1 - High",
        "Verify public firm branding configuration and persistent watermark rendering in App Shell.",
        "1. Navigate to `/app/more/branding`.<br/>"
        "2. Configure Firm Tagline, Description, Public Phone, Email, and Primary Theme Color.<br/>"
        "3. Save changes and return to main `/app/dashboard`.",
        "• Endpoint `PATCH /api/profile/firm/website/` updates firm website branding.<br/>"
        "• Verified: Legal seal and firm watermark background rendered softly across all app shell screens.",
        "[ ] Watermark does not obstruct text | [ ] Public branding updates immediately | [ ] Color applies"
    )
    story.append(t36)
    story.append(Spacer(1, 5))

    t37 = make_test_case_box(
        "TC-15.1", "Internal Messages & Support Ticket Desk",
        "All Firm Roles", "P1 - High",
        "Verify internal messaging between colleagues with case references and support tickets.",
        "1. Navigate to `/app/more/messages` -> 'Compose Message'.<br/>"
        "2. Select Colleague, link Case 'State vs Kumar', enter message body and send.<br/>"
        "3. Navigate to `/app/more/support` -> create ticket 'Question on Razorpay Tax Invoices'.",
        "• Internal message persists in firm message thread.<br/>"
        "• Support ticket generates ticket ID with status 'Open' under `GET /api/support/`.",
        "[ ] Message thread updates | [ ] Case chip attached | [ ] Ticket status tracked"
    )
    story.append(t37)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 4: CRITICAL REGRESSION & BUG-FIX VERIFICATION
    # =========================================================================
    story.append(Paragraph("SECTION 4: REGRESSION & BUG-FIX VERIFICATION SUITE", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_secondary, spaceBefore=2, spaceAfter=8))

    regr_intro = (
        "This section verifies the exact resolution of the 7 specific known issues previously documented "
        "in <code>requirment.txt</code>. Every QA tester MUST confirm these checkpoints before approving a release."
    )
    story.append(Paragraph(regr_intro, body_style))
    story.append(Spacer(1, 8))

    regr_data = [
        [
            Paragraph("Item", table_header),
            Paragraph("Issue Description (from requirment.txt)", table_header),
            Paragraph("Implemented Resolution & Architectural Fix", table_header),
            Paragraph("QA Verification Checkpoint", table_header),
            Paragraph("Result", table_header),
        ],
        [
            Paragraph("<b>R-01</b>", table_cell_bold),
            Paragraph("<b>Firm Blocked / Deactivated Actions:</b> Actions were not fully blocked when firm was deactivated.", table_cell),
            Paragraph("Implemented global reactive `PaywallBarrier` in `main.dart` wrapping the entire app. Intercepts 403 `FIRM_BLOCKED` and locks UI into `FirmSuspendedScreen`.", table_cell),
            Paragraph("Trigger 403 `FIRM_BLOCKED` from API. Verify non-dismissible full-screen overlay blocks all taps and interactions.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-02</b>", table_cell_bold),
            Paragraph("<b>Localhost Link Leak on Client Invite:</b> Clicking 'Add Client via Email' was sending `localhost` URL.", table_cell),
            Paragraph("Sanitized `invite_client_dialog.dart` and `document_sharing_repository.dart` to construct production host URLs or deep links, eliminating hardcoded `localhost:8000`.", table_cell),
            Paragraph("Generate client portal invite from `/app/clients/:id`. Inspect link string; verify zero instances of `localhost` or `127.0.0.1`.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-03</b>", table_cell_bold),
            Paragraph("<b>Payment Integration for Plan Purchase:</b> Purchasing firm subscription plans required Razorpay checkout.", table_cell),
            Paragraph("Integrated dynamic Razorpay client resolving DB credentials from `PlatformPaymentGateway`. Created order generation and webhook verification flow.", table_cell),
            Paragraph("Initiate plan upgrade from `/app/more/subscriptions`. Confirm order creation and Razorpay checkout modal initiation.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-04</b>", table_cell_bold),
            Paragraph("<b>Super Admin Subscriptions & Quota UI:</b> Quotas and plans were displaying incorrect UI in admin panel.", table_cell),
            Paragraph("Refactored `PlatformPlansScreen` into 3 unified tabs: *Subscription Plans*, *Payment Gateway*, and *Transactions Log* with active INR currency display.", table_cell),
            Paragraph("Open `/app/plans` as superadmin. Verify all 3 tabs display correct metrics, gateway fields, and transaction audit logs.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-05</b>", table_cell_bold),
            Paragraph("<b>Super Admin Direct User Provisioning Role Error:</b> Selecting roles caused error: 'This role is not valid'.", table_cell),
            Paragraph("Aligned role key serializer between Django backend and Flutter enums (`'super_admin'`, `'admin'`, `'lawyer'`, `'staff'`).", table_cell),
            Paragraph("Provision users under each role in platform console. Confirm backend returns 201 Created without invalid role rejection.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-06</b>", table_cell_bold),
            Paragraph("<b>Super Admin Firm Creation Failure:</b> Superadmin was unable to create new firms from admin panel.", table_cell),
            Paragraph("Repaired `POST /api/admin/create-firm/` endpoint handling in `firms_repository.dart` and form validation in `firms_list_screen.dart`.", table_cell),
            Paragraph("Tap 'Create Firm' in platform firms screen. Submit new firm details; verify immediate listing in active tenant registry.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
        [
            Paragraph("<b>R-07</b>", table_cell_bold),
            Paragraph("<b>Firm Internal Messaging:</b> Firm messages were not functioning correctly or linking references.", table_cell),
            Paragraph("Updated `messages_list_screen.dart` with real-time thread loading, colleague selection, and case matter tagging.", table_cell),
            Paragraph("Send message linking case matter. Confirm colleague receives notification and message appears in conversation thread.", table_cell),
            Paragraph("<b>PASS</b>", status_pass),
        ],
    ]
    regr_table = Table(regr_data, colWidths=[30, 115, 155, 175, 45])
    regr_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(regr_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 5: MASTER TESTING CHECKLIST & SIGN-OFF MATRIX
    # =========================================================================
    story.append(Paragraph("SECTION 5: MASTER TESTING CHECKLIST & QA SIGN-OFF MATRIX", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_secondary, spaceBefore=2, spaceAfter=8))

    signoff_intro = (
        "This master checklist aggregates all formal test cases into an actionable execution matrix. "
        "Each test case must be marked as <b>[PASS]</b>, <b>[FAIL]</b>, or <b>[BLOCKED]</b> by the responsible "
        "QA engineer prior to final production release approval."
    )
    story.append(Paragraph(signoff_intro, body_style))
    story.append(Spacer(1, 8))

    checklist_data = [
        [
            Paragraph("Status", table_header),
            Paragraph("TC ID", table_header),
            Paragraph("Module / Feature Area", table_header),
            Paragraph("Test Description", table_header),
            Paragraph("Tested Role", table_header),
            Paragraph("Result", table_header),
            Paragraph("Tester Initials", table_header),
        ],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-01.1", table_cell_bold), Paragraph("Authentication", table_cell), Paragraph("Multi-Role Login & Token Storage", table_cell), Paragraph("All Roles", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-01.2", table_cell_bold), Paragraph("Authentication", table_cell), Paragraph("Invalid Credentials & Form Validation", table_cell), Paragraph("All Roles", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-01.3", table_cell_bold), Paragraph("Authentication", table_cell), Paragraph("New Firm Registration & Admin Setup", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-01.4", table_cell_bold), Paragraph("Authentication", table_cell), Paragraph("Firm Member Invite Acceptance", table_cell), Paragraph("Lawyer / Staff", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-02.1", table_cell_bold), Paragraph("Dashboard", table_cell), Paragraph("Firm Admin Executive Command Center", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-02.2", table_cell_bold), Paragraph("Dashboard", table_cell), Paragraph("Lawyer Court Agenda & Briefs Hub", table_cell), Paragraph("Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-02.3", table_cell_bold), Paragraph("Dashboard", table_cell), Paragraph("Staff Tasks Queue & Coordination Hub", table_cell), Paragraph("Staff", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-03.1", table_cell_bold), Paragraph("Cases", table_cell), Paragraph("Case Repository Search & Court Filter", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-03.2", table_cell_bold), Paragraph("Cases", table_cell), Paragraph("Case Creation & Client Association", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-03.3", table_cell_bold), Paragraph("Cases (RBAC)", table_cell), Paragraph("Staff Route & 403 Access Barrier", table_cell), Paragraph("Staff", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-04.1", table_cell_bold), Paragraph("Clients", table_cell), Paragraph("Client Intake Form & Directory Search", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-04.2", table_cell_bold), Paragraph("Clients (Regr)", table_cell), Paragraph("Portal Invite Flow (No Localhost Leak)", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-04.3", table_cell_bold), Paragraph("Clients", table_cell), Paragraph("WhatsApp Consent & Preferences Modal", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-05.1", table_cell_bold), Paragraph("Hearings", table_cell), Paragraph("Schedule Hearing & Dynamic Countdown", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-05.2", table_cell_bold), Paragraph("Hearings", table_cell), Paragraph("One-Tap WhatsApp Reminder Dispatch", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-06.1", table_cell_bold), Paragraph("Tasks", table_cell), Paragraph("Create Task with Staff Assignee", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-06.2", table_cell_bold), Paragraph("Tasks", table_cell), Paragraph("One-Tap Status Progression (Pending->Done)", table_cell), Paragraph("Staff, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-07.1", table_cell_bold), Paragraph("Documents", table_cell), Paragraph("Upload with SHA-256 Hash & 25MB Guard", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-07.2", table_cell_bold), Paragraph("Documents", table_cell), Paragraph("Time-Bound Sharing & Instant Revocation", table_cell), Paragraph("Admin, Lawyer", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-08.1", table_cell_bold), Paragraph("Client Portal", table_cell), Paragraph("Portal Invite Acceptance & Onboarding", table_cell), Paragraph("Client", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-08.2", table_cell_bold), Paragraph("Client Portal", table_cell), Paragraph("Next Hearing Card & Counsel Call/Email", table_cell), Paragraph("Client", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-08.3", table_cell_bold), Paragraph("Client Portal", table_cell), Paragraph("Secure Preview & 300s Signed Token", table_cell), Paragraph("Client", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-08.4", table_cell_bold), Paragraph("Client Portal", table_cell), Paragraph("Strict Back-Office Route Isolation Guard", table_cell), Paragraph("Client", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-09.1", table_cell_bold), Paragraph("WhatsApp", table_cell), Paragraph("Dynamic Templates & Param Interpolation", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-09.2", table_cell_bold), Paragraph("WhatsApp", table_cell), Paragraph("Meta Cloud Send & Click-to-Chat Fallback", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-10.1", table_cell_bold), Paragraph("Financials", table_cell), Paragraph("Record Payment & Executive Revenue", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-10.2", table_cell_bold), Paragraph("Financials", table_cell), Paragraph("403 Forbidden Barrier on Lawyer/Staff", table_cell), Paragraph("Lawyer, Staff", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-11.1", table_cell_bold), Paragraph("Subscriptions", table_cell), Paragraph("Quota Usage Meter & Renewal Countdown", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-11.2", table_cell_bold), Paragraph("Paywalls", table_cell), Paragraph("Firm Suspended Screen (`FIRM_BLOCKED`)", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-11.3", table_cell_bold), Paragraph("Paywalls", table_cell), Paragraph("Subscription Expired Screen Barrier", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-11.4", table_cell_bold), Paragraph("Observability", table_cell), Paragraph("X-Request-ID Correlation Chip & Tap Copy", table_cell), Paragraph("All Roles", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-12.1", table_cell_bold), Paragraph("Platform Admin", table_cell), Paragraph("Tenant Registry Search & Block/Unblock", table_cell), Paragraph("Super Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-12.2", table_cell_bold), Paragraph("Platform Admin", table_cell), Paragraph("Razorpay Gateway Credentials Config Tab", table_cell), Paragraph("Super Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-12.3", table_cell_bold), Paragraph("Platform Admin", table_cell), Paragraph("Subscription Transactions Audit Log", table_cell), Paragraph("Super Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-13.1", table_cell_bold), Paragraph("Team", table_cell), Paragraph("Provision Team Member & Role Assignment", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-14.1", table_cell_bold), Paragraph("Branding", table_cell), Paragraph("Firm Website Bio & Shell Watermark", table_cell), Paragraph("Firm Admin", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
        [Paragraph("[  ]", table_cell_center), Paragraph("TC-15.1", table_cell_bold), Paragraph("Collaboration", table_cell), Paragraph("Internal Messaging & Support Tickets", table_cell), Paragraph("All Firm", table_cell), Paragraph("PASS / FAIL", table_cell_center), Paragraph("______", table_cell_center)],
    ]
    checklist_table = Table(checklist_data, colWidths=[32, 45, 80, 185, 68, 60, 50])
    checklist_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 2.2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.2),
        ('LEFTPADDING', (0,0), (-1,-1), 4),
        ('RIGHTPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(checklist_table)

    story.append(PageBreak())

    # =========================================================================
    # SECTION 5.2 & 5.3: DEFECT POLICIES & FORMAL RELEASE SIGN-OFF
    # =========================================================================
    story.append(Paragraph("5.2 Defect Severity Classification & SLA Matrix", h2_style))
    story.append(Paragraph(
        "Any unexpected behavior encountered during test execution must be triaged according to the following criteria:",
        body_style
    ))
    story.append(Spacer(1, 6))

    defect_data = [
        [
            Paragraph("Severity Level", table_header),
            Paragraph("Definition & Operational Impact", table_header),
            Paragraph("Target Resolution SLA", table_header),
            Paragraph("Production Release Impact", table_header),
        ],
        [
            Paragraph("<b>P0 - Blocker</b>", table_cell_bold),
            Paragraph("System crash, data corruption, security/RBAC breach, paywall bypass, or critical flow failure (login, download, payments).", table_cell),
            Paragraph("Immediate (< 4 Hours)", table_cell_center),
            Paragraph("<font color='#DC2626'><b>RELEASE BLOCKED</b></font>", table_cell_center),
        ],
        [
            Paragraph("<b>P1 - Critical</b>", table_cell_bold),
            Paragraph("Major feature impairment without workaround, WhatsApp dispatch failure, currency formatting error, quota sync discrepancy.", table_cell),
            Paragraph("Within 24 Hours", table_cell_center),
            Paragraph("<font color='#D97706'><b>CONDITIONAL HOLD</b></font>", table_cell_center),
        ],
        [
            Paragraph("<b>P2 - Major</b>", table_cell_bold),
            Paragraph("Secondary feature defect with viable workaround, non-critical notification delay, filter resetting on back navigation.", table_cell),
            Paragraph("Current Sprint (3 Days)", table_cell_center),
            Paragraph("<font color='#2563EB'>RELEASE PERMITTED</font>", table_cell_center),
        ],
        [
            Paragraph("<b>P3 - Minor</b>", table_cell_bold),
            Paragraph("Cosmetic imperfection, minor typography misalignment, label truncation on narrow screens, animation stutter.", table_cell),
            Paragraph("Next Scheduled Sprint", table_cell_center),
            Paragraph("<font color='#059669'>RELEASE PERMITTED</font>", table_cell_center),
        ],
    ]
    defect_table = Table(defect_data, colWidths=[80, 220, 110, 110])
    defect_table.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E3A8A")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#F8FAFC")]),
        ('BOX', (0,0), (-1,-1), 1, c_border),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(defect_table)
    story.append(Spacer(1, 14))

    story.append(Paragraph("5.3 Release Readiness & Gate Criteria", h2_style))
    gate_text = (
        "<b>MANDATORY DEPLOYMENT CRITERIA:</b><br/>"
        "1. <b>100% Pass Rate on P0 & P1 Test Cases:</b> Every test case tagged P0 or P1 must show a verified PASS status.<br/>"
        "2. <b>Zero Security Boundary Violations:</b> Staff role must be completely verified as barred from Cases and Documents.<br/>"
        "3. <b>Regression Verification:</b> Checkpoints R-01 through R-07 must be 100% verified against live backend.<br/>"
        "4. <b>Cryptographic Verification:</b> Signed 300-second token download and SHA-256 validation must be operational.<br/>"
        "5. <b>Multi-Role Sign-Off:</b> All four stakeholders below must provide formal written authorization."
    )
    story.append(Paragraph(gate_text, body_style))
    story.append(Spacer(1, 16))

    story.append(Paragraph("5.4 Multi-Disciplinary Formal Sign-Off", h2_style))
    story.append(Spacer(1, 4))

    # Formal Sign-off Section
    sign_off_box = [
        [
            Paragraph("<b>QA Engineering Lead:</b><br/>Name: _______________________<br/>Signature: ____________________<br/>Date: ____/____/2026<br/>Status: [  ] VERIFIED", body_style),
            Paragraph("<b>Mobile Engineering Lead:</b><br/>Name: _______________________<br/>Signature: ____________________<br/>Date: ____/____/2026<br/>Status: [  ] APPROVED", body_style),
        ],
        [
            Paragraph("<b>Security & Compliance Lead:</b><br/>Name: _______________________<br/>Signature: ____________________<br/>Date: ____/____/2026<br/>Status: [  ] AUDITED", body_style),
            Paragraph("<b>Product Manager Sign-Off:</b><br/>Name: _______________________<br/>Signature: ____________________<br/>Date: ____/____/2026<br/>Status: [  ] RELEASE APPROVED", body_style),
        ]
    ]
    sign_off_table = Table(sign_off_box, colWidths=[255, 255])
    sign_off_table.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1, c_secondary),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#BFDBFE")),
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#EFF6FF")),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(sign_off_table)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF successfully built: {filename}")

if __name__ == '__main__':
    output_filename = r"c:\Users\MAULIK\Desktop\Internship\Flutter\flutter_application_1\NTS_Legal_Pro_Master_Testing_Guide.pdf"
    build_pdf(output_filename)
