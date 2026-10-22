import os
import sys
import html
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

PRIMARY_COLOR = colors.HexColor("#0F172A")    # Deep Navy / Slate 900
SECONDARY_COLOR = colors.HexColor("#1E3A8A")  # Royal Blue 900
WA_GREEN = colors.HexColor("#16A34A")         # WhatsApp Green (Deep / legible for print)
WA_GREEN_LIGHT = colors.HexColor("#F0FDF4")   # WhatsApp Light Tint
ACCENT_GOLD = colors.HexColor("#B45309")      # Amber / Gold accent
BORDER_COLOR = colors.HexColor("#CBD5E1")     # Slate 300
BG_LIGHT = colors.HexColor("#F8FAFC")         # Slate 50
TEXT_MAIN = colors.HexColor("#1E293B")        # Slate 800
TEXT_MUTED = colors.HexColor("#64748B")       # Slate 500


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

        # Running Header
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(SECONDARY_COLOR)
        self.drawString(36, 810, "NTS LEGAL PRO")
        self.setFont("Helvetica", 8)
        self.setFillColor(TEXT_MUTED)
        self.drawString(110, 810, "|   WhatsApp Automated Communication & Reminders Specification")
        self.drawRightString(559, 810, "OFFICIAL SPECIFICATION")
        
        self.setStrokeColor(BORDER_COLOR)
        self.setLineWidth(0.6)
        self.line(36, 804, 559, 804)

        # Running Footer
        self.line(36, 42, 559, 42)
        self.drawString(36, 30, "Platform: NTS Legal Pro (Flutter & Django REST) | Standard: Meta WhatsApp Cloud API / Twilio")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(SECONDARY_COLOR)
        self.drawRightString(559, 30, page_str)
        self.restoreState()


def get_custom_styles():
    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(
        name='CoverTitle',
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=PRIMARY_COLOR,
        alignment=0,
        spaceAfter=10,
    ))

    styles.add(ParagraphStyle(
        name='CoverSubtitle',
        fontName='Helvetica',
        fontSize=12,
        leading=16,
        textColor=TEXT_MUTED,
        alignment=0,
        spaceAfter=20,
    ))

    styles.add(ParagraphStyle(
        name='DocH1',
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=PRIMARY_COLOR,
        spaceBefore=14,
        spaceAfter=8,
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        name='DocH2',
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=SECONDARY_COLOR,
        spaceBefore=10,
        spaceAfter=5,
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        name='DocH3',
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=TEXT_MAIN,
        spaceBefore=6,
        spaceAfter=3,
        keepWithNext=True,
    ))

    styles.add(ParagraphStyle(
        name='DocBody',
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=TEXT_MAIN,
        spaceAfter=5,
    ))

    styles.add(ParagraphStyle(
        name='DocBodyBold',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=12,
        textColor=TEXT_MAIN,
        spaceAfter=5,
    ))

    styles.add(ParagraphStyle(
        name='BulletItem',
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=TEXT_MAIN,
        leftIndent=14,
        firstLineIndent=-10,
        spaceAfter=3,
    ))

    styles.add(ParagraphStyle(
        name='TableHeader',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=colors.white,
        alignment=0,
    ))

    styles.add(ParagraphStyle(
        name='TableCell',
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=TEXT_MAIN,
    ))

    styles.add(ParagraphStyle(
        name='TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=TEXT_MAIN,
    ))

    styles.add(ParagraphStyle(
        name='TableCellCode',
        fontName='Courier',
        fontSize=7,
        leading=9.5,
        textColor=SECONDARY_COLOR,
    ))

    styles.add(ParagraphStyle(
        name='WhatsAppBubble',
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=colors.HexColor("#064E3B"), # Deep dark green
    ))

    styles.add(ParagraphStyle(
        name='CodeSnippet',
        fontName='Courier',
        fontSize=7,
        leading=9.5,
        textColor=colors.HexColor("#0F172A"),
    ))

    return styles


def sanitize_text(text):
    """Sanitize and format text for ReportLab XML paragraph engine."""
    if text is None:
        return ""
    # Escape basic XML entities
    text = html.escape(str(text))
    # Support basic bolding if marked with *
    return text


def create_callout_box(content_paragraphs, title="WhatsApp Message Template Preview", border_color=WA_GREEN, bg_color=WA_GREEN_LIGHT):
    """Creates a stylized message preview card resembling a WhatsApp chat bubble."""
    card_content = [
        Paragraph(f"<b>{html.escape(title)}</b>", ParagraphStyle(
            'BubbleTitle',
            fontName='Helvetica-Bold',
            fontSize=8,
            leading=10,
            textColor=border_color,
            spaceAfter=4,
        ))
    ]
    card_content.extend(content_paragraphs)

    card_table = Table([[card_content]], colWidths=[523])
    card_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), bg_color),
        ('BOX', (0, 0), (-1, -1), 1, border_color),
        ('ROUNDEDCORNERS', [4, 4, 4, 4]),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    return card_table


def create_code_box(code_text, title="API Payload / Schema Contract"):
    lines = [Paragraph(html.escape(line), ParagraphStyle(
        'CodeLine',
        fontName='Courier',
        fontSize=6.5,
        leading=8.5,
        textColor=colors.HexColor("#0F172A"),
    )) for line in code_text.strip().split("\n")]

    content = [
        Paragraph(f"<b>{html.escape(title)}</b>", ParagraphStyle(
            'CodeTitle',
            fontName='Helvetica-Bold',
            fontSize=7.5,
            leading=9.5,
            textColor=SECONDARY_COLOR,
            spaceAfter=4,
        ))
    ] + lines

    card_table = Table([[content]], colWidths=[523])
    card_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.7, colors.HexColor("#94A3B8")),
        ('ROUNDEDCORNERS', [3, 3, 3, 3]),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    return card_table


def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=46,
        bottomMargin=46,
    )

    styles = get_custom_styles()
    story = []

    # ==========================================
    # COVER PAGE
    # ==========================================
    story.append(Spacer(1, 20))
    # Brand Top Banner Table
    banner_data = [[
        Paragraph("<b>NTS LEGAL PRO ENTERPRISE</b>", ParagraphStyle('BnrL', fontName='Helvetica-Bold', fontSize=10, textColor=colors.HexColor("#16A34A"))),
        Paragraph("<b>COMMUNICATION MODULE SPECIFICATION</b>", ParagraphStyle('BnrR', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#64748B"), alignment=2))
    ]]
    banner_tbl = Table(banner_data, colWidths=[260, 263])
    banner_tbl.setStyle(TableStyle([
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LINEBELOW', (0, 0), (-1, -1), 1, colors.HexColor("#E2E8F0")),
    ]))
    story.append(banner_tbl)
    story.append(Spacer(1, 25))

    story.append(Paragraph("WhatsApp Automated Notification & Reminder Specification", styles['CoverTitle']))
    story.append(Paragraph(
        "A Granular Technical Architecture for Sector-Wise Dynamic Variables, Multi-Stage Court Hearing Cadences, Secure Tokenized Document Distribution, Billing Reminders, and SaaS Firm Subscription Lifecycles.",
        styles['CoverSubtitle']
    ))

    story.append(HRFlowable(width="100%", thickness=1.5, color=SECONDARY_COLOR, spaceBefore=5, spaceAfter=20))

    # Metadata Grid
    meta_data = [
        [
            Paragraph("<b>Document Version:</b>", styles['TableCellBold']),
            Paragraph("1.0.0 (Production Blueprint)", styles['TableCell']),
            Paragraph("<b>Target Platform:</b>", styles['TableCellBold']),
            Paragraph("NTS Legal Pro (Flutter + Django REST)", styles['TableCell']),
        ],
        [
            Paragraph("<b>Date of Release:</b>", styles['TableCellBold']),
            Paragraph("October 2026", styles['TableCell']),
            Paragraph("<b>Provider Standards:</b>", styles['TableCellBold']),
            Paragraph("Meta WhatsApp Cloud API & Twilio", styles['TableCell']),
        ],
        [
            Paragraph("<b>Document Scope:</b>", styles['TableCellBold']),
            Paragraph("Full Multi-Sector Reminders & Templates", styles['TableCell']),
            Paragraph("<b>Security Model:</b>", styles['TableCellBold']),
            Paragraph("SHA-256 Checksums & Signed Tokens (300s)", styles['TableCell']),
        ],
        [
            Paragraph("<b>Opt-In Compliance:</b>", styles['TableCellBold']),
            Paragraph("Explicit Affirmative Consent Required", styles['TableCell']),
            Paragraph("<b>Fallback Provider:</b>", styles['TableCellBold']),
            Paragraph("WhatsApp Click-to-Chat (wa.me) Deep Link", styles['TableCell']),
        ],
    ]
    meta_table = Table(meta_data, colWidths=[110, 150, 110, 153])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 0.8, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 25))

    # Executive Summary Card
    exec_text = [
        Paragraph("<b>EXECUTIVE ARCHITECTURAL SUMMARY</b>", ParagraphStyle('ExH', fontName='Helvetica-Bold', fontSize=9, textColor=PRIMARY_COLOR, spaceAfter=4)),
        Paragraph(
            "This specification governs the automated WhatsApp communications pipeline integrated within the NTS Legal Pro platform. "
            "It addresses end-to-end client engagement and firm administration: automated court hearing alert cadences (7-day preparation, 24-hour urgent reminder, same-day 2-hour morning alert), "
            "confidential document access grants with cryptographically signed URLs, fee invoicing and payment confirmations, task deadlines, and firm subscription paywall warnings. "
            "All outbound messaging is designed to conform with Meta's Utility template guidelines and respect recipient communication preferences.",
            styles['DocBody']
        )
    ]
    exec_table = Table([[exec_text]], colWidths=[523])
    exec_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F8FAFC")),
        ('BOX', (0, 0), (-1, -1), 1, SECONDARY_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 12),
    ]))
    story.append(exec_table)

    story.append(Spacer(1, 20))

    # Table of Contents Summary
    story.append(Paragraph("<b>SPECIFICATION MODULES AT A GLANCE</b>", styles['DocH3']))
    toc_data = [
        [Paragraph("<b>Module</b>", styles['TableHeader']), Paragraph("<b>Scope & Core Operational Impact</b>", styles['TableHeader'])],
        [Paragraph("<b>1. Compliance & Architecture</b>", styles['TableCellBold']), Paragraph("Meta Cloud API rules, Utility templates, 24-hr service window, and typography.", styles['TableCell'])],
        [Paragraph("<b>2. Variable Dictionary</b>", styles['TableCellBold']), Paragraph("System dynamic parameters (clients, cases, dates, secure links, subscriptions).", styles['TableCell'])],
        [Paragraph("<b>3. Case Registration</b>", styles['TableCellBold']), Paragraph("New matter onboarding, advocate assignment, and litigation stage tracking.", styles['TableCell'])],
        [Paragraph("<b>4. Court Hearing Cadence</b>", styles['TableCellBold']), Paragraph("3-tier timely alerts: T-7 days, T-24 hours, T-2 hours morning call, and adjournments.", styles['TableCell'])],
        [Paragraph("<b>5. Document Sharing</b>", styles['TableCellBold']), Paragraph("Signed token URLs (300s expiration), upload requests, and revocation notices.", styles['TableCell'])],
        [Paragraph("<b>6. Invoicing & Retainers</b>", styles['TableCellBold']), Paragraph("Fee invoices, T-3 days due reminders, payment receipts, and gateway links.", styles['TableCell'])],
        [Paragraph("<b>7. Firm Subscription Lifecycle</b>", styles['TableCellBold']), Paragraph("Plan ending alerts (T-7d, T-24h), paywall suspension notices, and quota alerts.", styles['TableCell'])],
        [Paragraph("<b>8. Tasks & Appointments</b>", styles['TableCellBold']), Paragraph("Court limitation filing deadlines, consultation booking, and 2-hour reminders.", styles['TableCell'])],
        [Paragraph("<b>9. Dispatch & Scheduling</b>", styles['TableCellBold']), Paragraph("Celery Beat daily cron schedule, DND protection window, and API contracts.", styles['TableCell'])],
    ]
    toc_table = Table(toc_data, colWidths=[160, 363])
    toc_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY_COLOR),
        ('BOX', (0, 0), (-1, -1), 0.6, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.4, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(toc_table)

    story.append(PageBreak())

    # ==========================================
    # SECTION 1: ARCHITECTURE & COMPLIANCE
    # ==========================================
    story.append(Paragraph("1. Architecture & Compliance Overview", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "WhatsApp Business Platform enforces stringent operational criteria to ensure high deliverability and prevent unsolicited communications. "
        "The NTS Legal Pro communication engine is engineered around three compliance pillars:",
        styles['DocBody']
    ))

    story.append(Paragraph("• <b>Template Categorization (Meta Standards):</b> All automated reminders must be registered and approved under the <b>UTILITY</b> category. Utility messages relate to a specific transaction, legal proceeding, hearing update, shared document, or billing schedule. Authentication passcodes are categorized under <b>AUTHENTICATION</b>.", styles['BulletItem']))
    story.append(Paragraph("• <b>Affirmative Consent (Opt-in Mandate):</b> Automated messages may only be delivered to clients who have explicitly granted consent recorded in <code>CommunicationPreference.whatsapp_consent = true</code>. The system automatically halts message dispatch if consent is absent or withdrawn.", styles['BulletItem']))
    story.append(Paragraph("• <b>24-Hour Customer Service Window:</b> Inbound replies from clients open a 24-hour conversational window during which advocates and staff can send non-templated free-form responses via the web/mobile app without incurring template charges.", styles['BulletItem']))
    story.append(Paragraph("• <b>Do-Not-Disturb (DND) Safeguards:</b> Automated cron jobs restrict non-emergency client dispatches between <b>21:00 (09:00 PM)</b> and <b>08:00 (08:00 AM)</b> local time.", styles['BulletItem']))

    story.append(Spacer(1, 10))

    # ==========================================
    # SECTION 2: GLOBAL VARIABLE DICTIONARY
    # ==========================================
    story.append(Paragraph("2. Global Dynamic Variable Dictionary", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "Dynamic parameters are substituted at runtime before payload transmission to Twilio or the Meta Cloud API. "
        "The table below specifies the canonical naming convention and corresponding database sources:",
        styles['DocBody']
    ))

    var_table_data = [
        [
            Paragraph("<b>Variable</b>", styles['TableHeader']),
            Paragraph("<b>Type</b>", styles['TableHeader']),
            Paragraph("<b>Backend Model Field</b>", styles['TableHeader']),
            Paragraph("<b>Example Value</b>", styles['TableHeader']),
            Paragraph("<b>Functional Description</b>", styles['TableHeader']),
        ],
        [
            Paragraph("<code>{{client_name}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("Client.name / UserProfile", styles['TableCell']),
            Paragraph("Rajesh Sharma", styles['TableCellBold']),
            Paragraph("Full name of client or party", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{client_phone}}</code>", styles['TableCellCode']),
            Paragraph("E.164", styles['TableCell']),
            Paragraph("Client.phone", styles['TableCell']),
            Paragraph("+919816012345", styles['TableCellBold']),
            Paragraph("Validated phone with country code", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{case_title}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("Case.title", styles['TableCell']),
            Paragraph("Sharma vs State of H.P.", styles['TableCellBold']),
            Paragraph("Official lawsuit caption/title", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{case_number}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("Case.case_number", styles['TableCell']),
            Paragraph("CWP-2026/0942", styles['TableCellBold']),
            Paragraph("Court filing or CNR number", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{court_name}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("Hearing.court_name", styles['TableCell']),
            Paragraph("High Court of H.P. (Court 3)", styles['TableCellBold']),
            Paragraph("Court venue or tribunal chamber", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{hearing_date}}</code>", styles['TableCellCode']),
            Paragraph("Date", styles['TableCell']),
            Paragraph("Hearing.date", styles['TableCell']),
            Paragraph("28 Oct 2026", styles['TableCellBold']),
            Paragraph("Formatted calendar hearing date", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{hearing_time}}</code>", styles['TableCellCode']),
            Paragraph("Time", styles['TableCell']),
            Paragraph("Hearing.start_time", styles['TableCell']),
            Paragraph("10:30 AM", styles['TableCellBold']),
            Paragraph("Listed cause list bench time", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{lawyer_name}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("UserProfile.full_name", styles['TableCell']),
            Paragraph("Adv. V. K. Katoch", styles['TableCellBold']),
            Paragraph("Lead counsel representing matter", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{document_title}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("Document.title", styles['TableCell']),
            Paragraph("Signed_Rejoinder.pdf", styles['TableCellBold']),
            Paragraph("Name of shared litigation brief", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{document_link}}</code>", styles['TableCellCode']),
            Paragraph("URL", styles['TableCell']),
            Paragraph("Signed Token Generator", styles['TableCell']),
            Paragraph("https://app.../dl/t_9f8e", styles['TableCellBold']),
            Paragraph("Time-limited secure link (300s)", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{invoice_amount}}</code>", styles['TableCellCode']),
            Paragraph("Currency", styles['TableCell']),
            Paragraph("Invoice.total_amount", styles['TableCell']),
            Paragraph("₹25,000.00", styles['TableCellBold']),
            Paragraph("Total fee due with symbol", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{payment_link}}</code>", styles['TableCellCode']),
            Paragraph("URL", styles['TableCell']),
            Paragraph("Razorpay Order URL", styles['TableCell']),
            Paragraph("https://rzp.io/l/inv_x912", styles['TableCellBold']),
            Paragraph("Instant checkout link", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{plan_name}}</code>", styles['TableCellCode']),
            Paragraph("String", styles['TableCell']),
            Paragraph("SubscriptionPlan.name", styles['TableCell']),
            Paragraph("Professional Tier (Annual)", styles['TableCellBold']),
            Paragraph("Law firm SaaS tier", styles['TableCell']),
        ],
        [
            Paragraph("<code>{{days_remaining}}</code>", styles['TableCellCode']),
            Paragraph("Integer", styles['TableCell']),
            Paragraph("Calculated Delta", styles['TableCell']),
            Paragraph("7", styles['TableCellBold']),
            Paragraph("Days until workspace paywall", styles['TableCell']),
        ],
    ]

    var_table = Table(var_table_data, colWidths=[95, 45, 115, 115, 153])
    var_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY_COLOR),
        ('BOX', (0, 0), (-1, -1), 0.6, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.4, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT]),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(var_table)

    story.append(PageBreak())

    # ==========================================
    # SECTION 3: SECTOR 1 - CASE REGISTRATION
    # ==========================================
    story.append(Paragraph("3. Sector 1: Legal Case Registration & Client Representation", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "When an advocate onboard a new client or logs a fresh court filing, automated notifications establish immediate trust, verify representation, and provide seamless access to the self-service client portal.",
        styles['DocBody']
    ))

    # Template 1.1
    story.append(Paragraph("3.1 Case Registration & Client Onboarding Confirmation", styles['DocH2']))
    meta_info_1_1 = [
        [Paragraph("<b>Trigger Event:</b> Lawyer creates new case (<code>POST /api/cases/</code>)", styles['TableCell']),
         Paragraph("<b>Schedule:</b> Real-time (Immediate)", styles['TableCell'])],
        [Paragraph("<b>Meta Template ID:</b> <code>legal_case_welcome_v1</code>", styles['TableCell']),
         Paragraph("<b>Category:</b> UTILITY | <b>Recipient:</b> Client", styles['TableCell'])],
        [Paragraph("<b>Required Variables:</b> <code>{{client_name}}</code>, <code>{{firm_name}}</code>, <code>{{case_title}}</code>, <code>{{case_number}}</code>, <code>{{case_type}}</code>, <code>{{lawyer_name}}</code>, <code>{{lawyer_phone}}</code>, <code>{{portal_url}}</code>", styles['TableCell']), ""]
    ]
    t1_1_meta = Table(meta_info_1_1, colWidths=[261, 262])
    t1_1_meta.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 0.5, BORDER_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('SPAN', (0, 2), (1, 2)),
    ]))
    story.append(t1_1_meta)
    story.append(Spacer(1, 5))

    msg_1_1 = [
        Paragraph("[CASE] <b>Case Registration Confirmation</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,", styles['WhatsAppBubble']),
        Paragraph("We are pleased to inform you that <b>{{firm_name}}</b> has formally registered your legal matter in our practice docket.", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("<b>Case Details:</b><br/>"
                  "• <b>Title:</b> {{case_title}}<br/>"
                  "• <b>Filing / Case No.:</b> {{case_number}}<br/>"
                  "• <b>Case Type:</b> {{case_type}}<br/>"
                  "• <b>Lead Advocate:</b> {{lawyer_name}}<br/>"
                  "• <b>Direct Contact:</b> {{lawyer_phone}}", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Track real-time hearings and court orders in your Client Portal:<br/>"
                  "<b>Link:</b> {{portal_url}}", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("Warm regards,<br/><b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_1_1, "Template: legal_case_welcome_v1"))
    story.append(Spacer(1, 10))

    # Template 1.2
    story.append(Paragraph("3.2 Legal Counsel / Advocate Assignment Notice", styles['DocH2']))
    msg_1_2 = [
        Paragraph("[ADVOCATE] <b>Advocate Assigned to Your Case</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,", styles['WhatsAppBubble']),
        Paragraph("<b>{{lawyer_name}}</b> has been designated as your lead advocate for <b>{{case_title}}</b> (No. {{case_number}}).", styles['WhatsAppBubble']),
        Paragraph("• Mobile: {{lawyer_phone}}<br/>• Office: {{firm_name}}", styles['WhatsAppBubble']),
        Paragraph("Your counsel is reviewing your briefs and will reach out with the litigation strategy.", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_1_2, "Template: legal_counsel_assigned_v1"))
    story.append(Spacer(1, 15))

    # ==========================================
    # SECTION 4: SECTOR 2 - COURT HEARINGS
    # ==========================================
    story.append(Paragraph("4. Sector 2: Court Hearings & Docket Alerts (Timely Cadence)", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "Court proceedings carry severe non-appearance penalties (dismissal in default or ex-parte orders). "
        "The system enforces a <b>3-tier progressive reminder schedule</b> that guarantees complete preparedness:",
        styles['DocBody']
    ))

    # Cadence Timeline Diagram Box
    cadence_data = [
        [Paragraph("<b>STAGE 1: T - 7 DAYS</b>", styles['TableHeader']),
         Paragraph("<b>STAGE 2: T - 24 HOURS</b>", styles['TableHeader']),
         Paragraph("<b>STAGE 3: T - 2 HOURS (TODAY)</b>", styles['TableHeader'])],
        [Paragraph("<b>Fires: 09:30 AM (7 Days Prior)</b><br/>Focus: Document gathering, affidavit preparation, pre-hearing conference.", styles['TableCell']),
         Paragraph("<b>Fires: 10:00 AM (1 Day Prior)</b><br/>Focus: Courtroom number, presiding bench, cause list item, arrival time.", styles['TableCell']),
         Paragraph("<b>Fires: 2 Hours Prior to Bench</b><br/>Focus: Immediate check-in with advocate inside court premises.", styles['TableCell'])],
    ]
    cadence_table = Table(cadence_data, colWidths=[174, 174, 175])
    cadence_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), WA_GREEN),
        ('BOX', (0, 0), (-1, -1), 0.8, WA_GREEN),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(cadence_table)
    story.append(Spacer(1, 10))

    # Template 2.1: 7-Day Alert
    story.append(Paragraph("4.1 Advance Court Hearing Alert (T - 7 Days)", styles['DocH2']))
    msg_2_1 = [
        Paragraph("[HEARING] <b>Upcoming Court Hearing Notice (7 Days Away)</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "This is an advance notice that your matter <b>{{case_title}}</b> ({{case_number}}) is scheduled for hearing in one week.", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("<b>Hearing Details:</b><br/>"
                  "• <b>Date:</b> {{hearing_date}}<br/>"
                  "• <b>Court / Bench:</b> {{court_name}}<br/>"
                  "• <b>Presiding:</b> {{judge_name}}<br/>"
                  "• <b>Lead Counsel:</b> {{lawyer_name}}", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("<b>Preparation Instructions:</b><br/>{{hearing_notes}}", styles['WhatsAppBubble']),
        Paragraph("Please contact {{lawyer_name}} to finalize preparation.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_2_1, "Template: hearing_reminder_7days_v1"))
    story.append(Spacer(1, 10))

    # Template 2.2: 24-Hour Urgent Alert
    story.append(Paragraph("4.2 Critical Hearing Reminder (T - 24 Hours)", styles['DocH2']))
    msg_2_2 = [
        Paragraph("[URGENT] <b>Court Hearing Scheduled for Tomorrow</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "Your case <b>{{case_title}}</b> ({{case_number}}) is listed for hearing <b>TOMORROW</b>.", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("• <b>Date:</b> {{hearing_date}} at <b>{{hearing_time}}</b><br/>"
                  "• <b>Courtroom:</b> {{court_name}}<br/>"
                  "• <b>Judge:</b> {{judge_name}}", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("<b>Critical Instructions:</b><br/>{{hearing_notes}}", styles['WhatsAppBubble']),
        Paragraph("Kindly arrive at least <b>30 minutes prior</b> to the scheduled call. For urgent assistance, reach your counsel directly at <b>{{lawyer_phone}}</b>.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_2_2, "Template: hearing_reminder_24h_v1", border_color=colors.HexColor("#DC2626"), bg_color=colors.HexColor("#FEF2F2")))
    story.append(Spacer(1, 10))

    # Template 2.3: Same-Day 2-Hour Alert
    story.append(Paragraph("4.3 Same-Day Morning Alert (T - 2 Hours Prior)", styles['DocH2']))
    msg_2_3 = [
        Paragraph("[TODAY] <b>Today's Court Hearing Alert</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "Your hearing for Case <b>#{{case_number}}</b> is scheduled for <b>TODAY at {{hearing_time}}</b>.", styles['WhatsAppBubble']),
        Paragraph("• <b>Venue:</b> {{court_name}}<br/>"
                  "• <b>Your Advocate:</b> {{lawyer_name}} ({{lawyer_phone}})", styles['WhatsAppBubble']),
        Paragraph("Please ensure you are present inside the courtroom premises and coordinate with counsel upon entry.", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_2_3, "Template: hearing_reminder_same_day_v1"))
    story.append(Spacer(1, 10))

    # Template 2.4: Rescheduled Hearing
    story.append(Paragraph("4.4 Hearing Rescheduled / Adjourned Notice", styles['DocH2']))
    msg_2_4 = [
        Paragraph("[UPDATE] <b>Court Hearing Rescheduled</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "The hearing for <b>{{case_title}}</b> ({{case_number}}) previously listed on {{old_date}} has been rescheduled by the court.", styles['WhatsAppBubble']),
        Paragraph("• <b>New Date:</b> {{new_date}} at {{new_time}}<br/>"
                  "• <b>Court:</b> {{court_name}}<br/>"
                  "• <b>Reason / Order:</b> {{adjournment_reason}}", styles['WhatsAppBubble']),
        Paragraph("Our team has updated your docket. Next steps will be communicated by your counsel.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_2_4, "Template: hearing_rescheduled_v1"))

    story.append(PageBreak())

    # ==========================================
    # SECTION 5: SECTOR 3 - DOCUMENT SHARING
    # ==========================================
    story.append(Paragraph("5. Sector 3: Secure Document Sharing & Evidence Access", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "To safeguard advocate-client privilege and satisfy ISO 27001 data integrity standards, static download URLs are prohibited. "
        "All file access links transmitted via WhatsApp utilize <b>cryptographically signed tokens with a strict 300-second (5 minute) validity window</b>. "
        "Permanent access is provided securely within the authenticated Client Portal.",
        styles['DocBody']
    ))

    # Template 3.1
    story.append(Paragraph("5.1 Lawyer Shares Confidential Legal Brief", styles['DocH2']))
    msg_3_1 = [
        Paragraph("[DOCUMENT] <b>New Legal Document Shared With You</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "<b>{{shared_by_name}}</b> has securely shared a confidential legal document with you regarding <b>{{case_title}}</b>.", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("• <b>Document:</b> {{document_title}}<br/>"
                  "• <b>Access Window:</b> Valid for {{expiry_days}} days", styles['WhatsAppBubble']),
        Spacer(1, 2),
        Paragraph("<b>How to Access Securely:</b><br/>"
                  "Click below to authenticate and review your document in the portal:<br/>"
                  "{{portal_url}}", styles['WhatsAppBubble']),
        Paragraph("If you did not anticipate receiving this document, please alert our office.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_3_1, "Template: document_shared_v1"))
    story.append(Spacer(1, 10))

    # Template 3.2
    story.append(Paragraph("5.2 Action Required: Client Signature / Upload Request", styles['DocH2']))
    msg_3_2 = [
        Paragraph("[ACTION REQUIRED] <b>Document Submission Needed</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "Your counsel <b>{{lawyer_name}}</b> requires you to submit the following document for <b>{{case_title}}</b>:", styles['WhatsAppBubble']),
        Paragraph("• <b>Required File:</b> {{requested_document}}<br/>"
                  "• <b>Filing Deadline:</b> {{due_date}}<br/>"
                  "• <b>Instructions:</b> {{instructions}}", styles['WhatsAppBubble']),
        Paragraph("Please upload scanned copies directly to your secure client portal:<br/>"
                  "{{portal_url}}<br/>"
                  "Timely submission is critical to filing compliance in court.", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_3_2, "Template: document_upload_requested_v1", border_color=ACCENT_GOLD, bg_color=colors.HexColor("#FFFBEB")))
    story.append(Spacer(1, 10))

    # Template 3.3
    story.append(Paragraph("5.3 Document Sharing Expiration Alert (48 Hours Prior)", styles['DocH2']))
    msg_3_3 = [
        Paragraph("[EXPIRY NOTICE] <b>Shared Document Access Expiring Soon</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "Access to <b>{{document_title}}</b> (Case: {{case_title}}) will expire on <b>{{expiry_date}}</b>.", styles['WhatsAppBubble']),
        Paragraph("Please download or review your copy before the window closes:<br/>"
                  "{{portal_url}}<br/>"
                  "Contact your advocate if you need extended access.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_3_3, "Template: document_expiry_warning_v1"))

    story.append(Spacer(1, 15))

    # ==========================================
    # SECTION 6: SECTOR 4 - BILLING & INVOICING
    # ==========================================
    story.append(Paragraph("6. Sector 4: Billing, Retainers & Client Invoicing", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "Automated billing reminders accelerate fee collections while maintaining clear professional communication with clients.",
        styles['DocBody']
    ))

    # Template 4.1
    story.append(Paragraph("6.1 New Legal Fee Invoice Raised", styles['DocH2']))
    msg_4_1 = [
        Paragraph("[INVOICE] <b>New Fee Invoice from {{firm_name}}</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "An invoice has been raised for legal services rendered in <b>{{case_title}}</b>.", styles['WhatsAppBubble']),
        Paragraph("• <b>Invoice No.:</b> {{invoice_number}}<br/>"
                  "• <b>Amount Due:</b> <b>{{invoice_amount}}</b><br/>"
                  "• <b>Due Date:</b> {{due_date}}", styles['WhatsAppBubble']),
        Paragraph("<b>Pay Online Instantly (UPI, Cards, NetBanking):</b><br/>"
                  "{{payment_link}}<br/>"
                  "Thank you for choosing {{firm_name}}.", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_4_1, "Template: invoice_raised_v1"))
    story.append(Spacer(1, 10))

    # Template 4.2
    story.append(Paragraph("6.2 Payment Confirmation & Official Receipt", styles['DocH2']))
    msg_4_2 = [
        Paragraph("[RECEIPT] <b>Payment Confirmation & Receipt</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "We gratefully acknowledge receipt of your payment for Invoice <b>#{{invoice_number}}</b>.", styles['WhatsAppBubble']),
        Paragraph("• <b>Amount Paid:</b> <b>{{amount_paid}}</b><br/>"
                  "• <b>Transaction Ref:</b> {{payment_reference}}<br/>"
                  "• <b>Date:</b> {{payment_date}}<br/>"
                  "• <b>Status:</b> Confirmed & Settled", styles['WhatsAppBubble']),
        Paragraph("Your updated account statement is available in your client portal.<br/>— <b>{{firm_name}} Accounts</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_4_2, "Template: payment_receipt_v1"))

    story.append(PageBreak())

    # ==========================================
    # SECTION 7: SECTOR 5 - SUBSCRIPTION LIFECYCLE
    # ==========================================
    story.append(Paragraph("7. Sector 5: SaaS Subscription & Law Firm Plan Lifecycle", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "NTS Legal Pro enforces global workspace paywalls (<code>FirmAccessPermission</code>). When a firm subscription expires, "
        "lawyers and staff are locked out of cases and documents. An automated reminder sequence alerts the <b>Firm Admin / Managing Partner</b> "
        "well in advance to maintain continuous business continuity.",
        styles['DocBody']
    ))

    # Template 5.1
    story.append(Paragraph("7.1 Law Firm Subscription Ending (7 Days Prior)", styles['DocH2']))
    msg_5_1 = [
        Paragraph("[NOTICE] <b>Law Firm Subscription Expires in 7 Days</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{admin_name}}</b>,<br/>"
                  "Your NTS Legal Pro subscription for <b>{{firm_name}}</b> ({{plan_name}}) expires on <b>{{plan_end_date}}</b> ({{days_remaining}} days remaining).", styles['WhatsAppBubble']),
        Paragraph("<b>Impact of Expiration:</b><br/>"
                  "To ensure advocates and staff continue accessing case briefs, court schedules, and client portals without interruption, please renew prior to expiration.", styles['WhatsAppBubble']),
        Paragraph("<b>Renew Your Plan Online:</b><br/>"
                  "{{renewal_url}}<br/>— <b>NTS Legal Pro Billing Desk</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_5_1, "Template: firm_plan_expiring_7days_v1", border_color=ACCENT_GOLD, bg_color=colors.HexColor("#FFFBEB")))
    story.append(Spacer(1, 10))

    # Template 5.2
    story.append(Paragraph("7.2 Urgent: Subscription Expires Tomorrow (24 Hours Prior)", styles['DocH2']))
    msg_5_2 = [
        Paragraph("[URGENT] <b>Your Firm Subscription Expires Tomorrow</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{admin_name}}</b>,<br/>"
                  "The subscription for <b>{{firm_name}}</b> ({{plan_name}}) expires on <b>{{plan_end_date}}</b>.", styles['WhatsAppBubble']),
        Paragraph("<b>After Tomorrow:</b><br/>"
                  "• Advocates & staff will be blocked from accessing case files.<br/>"
                  "• Client portal access will be temporarily locked.<br/>"
                  "• Automated WhatsApp court hearing reminders will pause.", styles['WhatsAppBubble']),
        Paragraph("Avoid service disruption by renewing your workspace immediately:<br/>"
                  "{{renewal_url}}<br/>— <b>NTS Legal Pro Platform Operations</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_5_2, "Template: firm_plan_expiring_24h_v1", border_color=colors.HexColor("#DC2626"), bg_color=colors.HexColor("#FEF2F2")))
    story.append(Spacer(1, 10))

    # Template 5.3
    story.append(Paragraph("7.3 Subscription Expired & Workspace Locked (Paywall Active)", styles['DocH2']))
    msg_5_3 = [
        Paragraph("[PAYWALL] <b>Service Alert: {{firm_name}} Subscription Expired</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{admin_name}}</b>,<br/>"
                  "Your subscription has ended. Workspace operations have been restricted pursuant to platform policy (<code>SUBSCRIPTION_EXPIRED</code>).", styles['WhatsAppBubble']),
        Paragraph("Your case data, files, and dockets remain completely safe. A <b>{{grace_days}}-day grace period</b> is active.", styles['WhatsAppBubble']),
        Paragraph("<b>Reactivate Full Law Firm Workspace:</b><br/>"
                  "{{renewal_url}}<br/>"
                  "Access will be restored immediately upon checkout.<br/>— <b>NTS Legal Pro Billing</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_5_3, "Template: firm_plan_expired_paywall_v1", border_color=PRIMARY_COLOR, bg_color=BG_LIGHT))
    story.append(Spacer(1, 10))

    # Template 5.4
    story.append(Paragraph("7.4 Storage & Client Quota Threshold Alert (80% / 100%)", styles['DocH2']))
    msg_5_4 = [
        Paragraph("[CAPACITY] <b>Capacity Limit Notice: {{firm_name}}</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{admin_name}}</b>,<br/>"
                  "Your firm has utilized <b>{{used_amount}} of {{max_limit}}</b> of your {{quota_type}} capacity under {{plan_name}}.", styles['WhatsAppBubble']),
        Paragraph("Upgrade your tier seamlessly to avoid onboarding or upload disruptions:<br/>"
                  "{{upgrade_url}}<br/>— <b>NTS Legal Pro Platform Monitor</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_5_4, "Template: quota_threshold_alert_v1"))

    story.append(PageBreak())

    # ==========================================
    # SECTION 8: SECTORS 6 & 7 - TASKS & APPOINTMENTS
    # ==========================================
    story.append(Paragraph("8. Sectors 6 & 7: Tasks, Limitations & Appointments", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph("8.1 Court Limitation Period & Filing Deadline Alert", styles['DocH2']))
    msg_6_1 = [
        Paragraph("[DEADLINE] <b>CRITICAL: Court Filing Deadline Approaching</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{recipient_name}}</b>,<br/>"
                  "Priority alert regarding an essential filing deadline in <b>{{case_title}}</b> ({{case_number}}):", styles['WhatsAppBubble']),
        Paragraph("• <b>Action Item:</b> {{task_title}}<br/>"
                  "• <b>Deadline:</b> <b>{{deadline_date}} by {{deadline_time}}</b><br/>"
                  "• <b>Forum / Registry:</b> {{court_name}}", styles['WhatsAppBubble']),
        Paragraph("Ensure all pleadings, court fees, and certified annexures are lodged prior to registry closure.<br/>— <b>{{firm_name}} Operations</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_6_1, "Template: legal_filing_deadline_v1", border_color=colors.HexColor("#DC2626"), bg_color=colors.HexColor("#FEF2F2")))
    story.append(Spacer(1, 10))

    story.append(Paragraph("8.2 Legal Consultation Booking Confirmation & 2-Hour Alert", styles['DocH2']))
    msg_7_1 = [
        Paragraph("[APPOINTMENT] <b>Legal Consultation Confirmed</b>", styles['WhatsAppBubble']),
        Spacer(1, 3),
        Paragraph("Dear <b>{{client_name}}</b>,<br/>"
                  "Your legal consultation with <b>{{lawyer_name}}</b> is confirmed.", styles['WhatsAppBubble']),
        Paragraph("• <b>Mode:</b> {{consultation_type}}<br/>"
                  "• <b>Date & Time:</b> {{appointment_date}} at {{appointment_time}}<br/>"
                  "• <b>Venue / Conference Link:</b> {{venue_or_link}}", styles['WhatsAppBubble']),
        Paragraph("Please keep all relevant contracts, notices, and police/revenue reports handy.<br/>— <b>{{firm_name}}</b>", styles['WhatsAppBubble'])
    ]
    story.append(create_callout_box(msg_7_1, "Template: consultation_confirmed_v1"))
    story.append(Spacer(1, 15))

    # ==========================================
    # SECTION 9: DISPATCH SCHEDULING GRID
    # ==========================================
    story.append(Paragraph("9. Automated Dispatch Architecture & Scheduling Grid", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "Automated dispatches execute via Celery Beat background workers scheduled throughout the working day. "
        "Strict rate-limiting prevents carrier throttling while honoring consumer DND windows:",
        styles['DocBody']
    ))

    cron_data = [
        [Paragraph("<b>Time (IST)</b>", styles['TableHeader']),
         Paragraph("<b>Frequency</b>", styles['TableHeader']),
         Paragraph("<b>Sector / Domain</b>", styles['TableHeader']),
         Paragraph("<b>Automated Action & Target Evaluation</b>", styles['TableHeader'])],
        [Paragraph("<b>00:05 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Subscriptions", styles['TableCell']), Paragraph("Identifies expired plans (<code>end_date &lt; today</code>); flags paywall; sends Paywall Notice.", styles['TableCell'])],
        [Paragraph("<b>08:30 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Court Hearings", styles['TableCell']), Paragraph("Dispatches Same-Day 2-Hour Alerts for hearings listed between 10:00 AM and 01:00 PM.", styles['TableCell'])],
        [Paragraph("<b>09:00 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Subscriptions", styles['TableCell']), Paragraph("Dispatches 7-day and 24-hour expiration warnings to Firm Managing Partners.", styles['TableCell'])],
        [Paragraph("<b>09:30 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Court Hearings", styles['TableCell']), Paragraph("Dispatches 7-day advance preparation alerts for hearings scheduled in T - 7 days.", styles['TableCell'])],
        [Paragraph("<b>10:00 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Court Hearings", styles['TableCell']), Paragraph("Dispatches 24-hour critical hearing checklists for tomorrow's court cause lists.", styles['TableCell'])],
        [Paragraph("<b>10:30 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Document Sharing", styles['TableCell']), Paragraph("Scans documents expiring in 48 hours; alerts clients to download files.", styles['TableCell'])],
        [Paragraph("<b>11:00 AM</b>", styles['TableCellBold']), Paragraph("Daily", styles['TableCell']),
         Paragraph("Invoicing", styles['TableCell']), Paragraph("Scans unpaid invoices due in 3 days; dispatches friendly fee settlement reminders.", styles['TableCell'])],
        [Paragraph("<b>Every 15m</b>", styles['TableCellBold']), Paragraph("Interval", styles['TableCell']),
         Paragraph("Consultations", styles['TableCell']), Paragraph("Evaluates client consultations scheduled within next 120 minutes; dispatches 2h reminders.", styles['TableCell'])],
        [Paragraph("<b>Real-time</b>", styles['TableCellBold']), Paragraph("On-Event", styles['TableCell']),
         Paragraph("Cases & Documents", styles['TableCell']), Paragraph("Instant webhook/API triggers for case registration, document sharing, and payment receipts.", styles['TableCell'])],
    ]
    cron_table = Table(cron_data, colWidths=[65, 55, 95, 308])
    cron_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY_COLOR),
        ('BOX', (0, 0), (-1, -1), 0.6, BORDER_COLOR),
        ('INNERGRID', (0, 0), (-1, -1), 0.4, colors.HexColor("#E2E8F0")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(cron_table)

    story.append(PageBreak())

    # ==========================================
    # SECTION 10: API PAYLOAD CONTRACTS
    # ==========================================
    story.append(Paragraph("10. Payload Data Contracts & API Integration", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "Below are the verified JSON request and response payloads conforming to the Django REST backend implementation at <code>POST /api/communications/whatsapp/send/</code>:",
        styles['DocBody']
    ))

    req_payload = """POST /api/communications/whatsapp/send/
Content-Type: application/json
Authorization: Bearer <jwt_access_token>

{
  "recipient_number": "+919816012345",
  "recipient_name": "Rajesh Sharma",
  "template": "hearing_reminder",
  "template_params": {
    "client_name": "Rajesh Sharma",
    "case_title": "Sharma vs State of H.P.",
    "hearing_date": "28 Oct 2026",
    "hearing_time": "10:30 AM",
    "court_name": "High Court of H.P. (Court 3)",
    "firm_name": "Apex Legal Associates"
  },
  "client_id": 14,
  "case_id": 7
}"""
    story.append(create_code_box(req_payload, "HTTP Request Payload (Backend API)"))
    story.append(Spacer(1, 10))

    resp_payload = """HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": 108,
  "recipient_number": "+919816012345",
  "recipient_name": "Rajesh Sharma",
  "template": "hearing_reminder",
  "body": "📋 *Hearing Reminder*\\n\\nDear Rajesh Sharma...",
  "provider": "twilio",
  "provider_message_id": "SMa8f192b0c34e71829019238475aabbcc",
  "status": "sent",
  "failure_code": "",
  "failure_reason": "",
  "sent_at": "2026-10-21T09:30:00Z",
  "delivered_at": null,
  "read_at": null,
  "created_at": "2026-10-21T09:30:00Z",
  "chat_url": null
}"""
    story.append(create_code_box(resp_payload, "HTTP 201 Response (Successful Gateway Dispatch)"))
    story.append(Spacer(1, 10))

    fallback_payload = """HTTP/1.1 200 OK (Click-to-Chat Fallback when Twilio Credentials Unset)

{
  "id": 109,
  "recipient_number": "+919816012345",
  "template": "hearing_reminder",
  "provider": "click_to_chat",
  "status": "pending",
  "chat_url": "https://wa.me/919816012345?text=%F0%9F%93%8B%20%2AHearing%20Reminder%2A..."
}"""
    story.append(create_code_box(fallback_payload, "Fallback Mode (Direct WhatsApp App Launch)"))
    story.append(Spacer(1, 15))

    # ==========================================
    # SECTION 11: CONSENT & DELIVERY LIFECYCLE
    # ==========================================
    story.append(Paragraph("11. Opt-In Consent, DND & Webhook Lifecycle", styles['DocH1']))
    story.append(HRFlowable(width="100%", thickness=1, color=SECONDARY_COLOR, spaceBefore=2, spaceAfter=8))

    story.append(Paragraph(
        "1. <b>Consent Enforcement:</b> The backend executes <code>CommunicationPreference.whatsapp_consent</code> validation prior to every dispatch. If opted-out, a <code>403 Forbidden</code> is returned.",
        styles['DocBody']
    ))
    story.append(Paragraph(
        "2. <b>Delivery Webhook Receipts:</b> Asynchronous callbacks update message delivery state in <code>WhatsAppMessage</code>: "
        "<code>queued</code> → <code>sent</code> (carrier accepted) → <code>delivered</code> (double tick) → <code>read</code> (blue tick) or <code>failed</code>.",
        styles['DocBody']
    ))
    story.append(Paragraph(
        "3. <b>Automated Unsubscribe:</b> Inbound messages containing <code>STOP</code>, <code>UNSUBSCRIBE</code>, or <code>OPT OUT</code> automatically set <code>whatsapp_consent = false</code> and record an immutable audit entry.",
        styles['DocBody']
    ))

    # Signoff Box
    story.append(Spacer(1, 15))
    signoff_data = [
        [Paragraph("<b>SPECIFICATION APPROVAL & RELEASE</b>", styles['DocH3'])],
        [Paragraph("<b>Status:</b> Approved for Deployment | <b>Systems:</b> NTS Legal Pro Flutter App & DRF Backend<br/>"
                   "<b>Reviewed By:</b> Principal Legal Platform Architect | <b>Version:</b> 1.0.0", styles['TableCell'])]
    ]
    signoff_tbl = Table(signoff_data, colWidths=[523])
    signoff_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 0.8, SECONDARY_COLOR),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(signoff_tbl)

    # Build Document with NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF built successfully: {filename}")


if __name__ == "__main__":
    out_pdf = "WhatsApp_Automated_Communication_Specification.pdf"
    build_pdf(out_pdf)
