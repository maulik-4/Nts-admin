import 'package:flutter/material.dart';

import '../../../../../core/theme/lex_colors.dart';

class PreviewDashboardView extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;
  final bool isMobile;

  const PreviewDashboardView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final subtextColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final cardBg = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    final primaryBtnText =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role Welcome Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        primaryColor.withValues(alpha: 0.35),
                        LexColors.surfaceDark,
                      ]
                    : [primaryColor.withValues(alpha: 0.08), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Adv. Jane Doe',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Principal Managing Partner • Litigation Workspace',
                        style: TextStyle(
                          fontSize: 10,
                          color: subtextColor,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: accentColor, width: 0.8),
                  ),
                  child: Text(
                    'Firm Admin',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? accentColor : primaryColor,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4 Metric Cards Grid (2x2)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Cases',
                  value: '28',
                  icon: Icons.gavel_rounded,
                  iconColor: primaryColor,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Clients',
                  value: '142',
                  icon: Icons.people_alt_rounded,
                  iconColor: accentColor,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Hearings (Week)',
                  value: '6',
                  icon: Icons.event_note_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'Billed Revenue',
                  value: '\$48.5k',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: LexColors.success,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: primaryBtnText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+ New Case',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryBtnText,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor, width: 1.2),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+ Client',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? accentColor : primaryColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Recent Litigation Activity
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Case Matters & Filings',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'View all (28)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildActivityItem(
            title: 'Sharma vs. State of Maharashtra',
            subtitle: 'Commercial Division · High Court',
            status: 'In Progress',
            statusColor: LexColors.warning,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          const SizedBox(height: 6),
          _buildActivityItem(
            title: 'Estate of Henderson Probate',
            subtitle: 'Civil Dispute #2026/0144 • District Court',
            status: 'Scheduled',
            statusColor: const Color(0xFF38BDF8),
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subtextColor: subtextColor,
          ),
          const SizedBox(height: 6),
          _buildActivityItem(
            title: 'Metropolis Housing Acquisition',
            subtitle: 'Brief Filed • Ready for Order',
            status: 'Completed',
            statusColor: LexColors.success,
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            subtextColor: subtextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: statusColor,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewCasesView extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;

  const PreviewCasesView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final subtextColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final cardBg = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Litigation Cases Docket',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 14, color: subtextColor),
                const SizedBox(width: 6),
                Text(
                  'Search case by title, CNR, or advocate...',
                  style: TextStyle(
                    fontSize: 9,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildCaseCard(
            'State vs. R. Verma',
            'Criminal Appeal #104/2026',
            'Courtroom 4 • Hon. Judge K. Soni',
            'Hearing: Tomorrow',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildCaseCard(
            'Oberoi Infra vs. Tech Park',
            'Commercial Arbitration #42/2025',
            'Arbitration Tribunal B',
            'Filing Reply',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildCaseCard(
            'Gupta Family Trust Settlement',
            'Civil Suit #891/2024',
            'High Court Principal Bench',
            'Under Mediation',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(
    String title,
    String caseNo,
    String court,
    String status,
    Color primary,
    Color accent,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  '$caseNo • $court',
                  style: TextStyle(
                    fontSize: 8,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? accent : primary,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewClientsView extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;

  const PreviewClientsView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final subtextColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final cardBg = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Directory (142)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          _buildClientTile(
            'Rajesh Malhotra',
            'Managing Director • Apex Corp',
            '3 Active Cases',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildClientTile(
            'Sarah Jenkins',
            'Chief Legal Officer • Nexus Global',
            '5 Active Cases',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildClientTile(
            'Harish Singhania',
            'Private Individual Matter',
            '1 Active Case',
            primaryColor,
            accentColor,
            cardBg,
            borderColor,
            textColor,
            subtextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildClientTile(
    String name,
    String role,
    String matters,
    Color primary,
    Color accent,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: primary.withValues(alpha: 0.15),
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 8,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
          Text(
            matters,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: accent,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewHearingsView extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;

  const PreviewHearingsView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final subtextColor = isDarkMode
        ? LexColors.textSecondaryDark
        : LexColors.textSecondaryLight;
    final cardBg = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Court Docket & Hearings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          _buildHearingItem(
            '10:30 AM',
            'High Court #4',
            'State vs. Verma',
            'Final Arguments',
            cardBg,
            borderColor,
            textColor,
            subtextColor,
            accentColor,
          ),
          const SizedBox(height: 6),
          _buildHearingItem(
            '02:00 PM',
            'Tribunal B',
            'Oberoi Infra Arbitration',
            'Cross-Examination',
            cardBg,
            borderColor,
            textColor,
            subtextColor,
            accentColor,
          ),
          const SizedBox(height: 6),
          _buildHearingItem(
            'Tomorrow',
            'District Court #1',
            'Estate of Henderson',
            'Admission Hearing',
            cardBg,
            borderColor,
            textColor,
            subtextColor,
            accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHearingItem(
    String time,
    String courtroom,
    String matter,
    String purpose,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subtextColor,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: accent,
                fontFamily: fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matter,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  '$courtroom • $purpose',
                  style: TextStyle(
                    fontSize: 8,
                    color: subtextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewMoreView extends StatelessWidget {
  final Color primaryColor;
  final Color accentColor;
  final String fontFamily;
  final bool isDarkMode;

  const PreviewMoreView({
    super.key,
    required this.primaryColor,
    required this.accentColor,
    required this.fontFamily,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode
        ? LexColors.textPrimaryDark
        : LexColors.slatePrimary;
    final cardBg = isDarkMode ? LexColors.surfaceDark : LexColors.surfaceLight;
    final borderColor = isDarkMode
        ? LexColors.borderDark
        : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Firm Administration Modules',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildModuleCard(
                  'Documents',
                  Icons.folder_outlined,
                  '124 Files',
                  cardBg,
                  borderColor,
                  textColor,
                  primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModuleCard(
                  'Team Members',
                  Icons.group_outlined,
                  '8 Advocates',
                  cardBg,
                  borderColor,
                  textColor,
                  accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildModuleCard(
                  'Billing & Payments',
                  Icons.receipt_long_outlined,
                  '\$48.5k Billed',
                  cardBg,
                  borderColor,
                  textColor,
                  LexColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModuleCard(
                  'Firm Settings',
                  Icons.tune_rounded,
                  'Active',
                  cardBg,
                  borderColor,
                  textColor,
                  const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    String title,
    IconData icon,
    String count,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFamily: fontFamily,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
