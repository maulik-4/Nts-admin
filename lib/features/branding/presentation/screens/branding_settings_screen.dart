import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../../shared/widgets/lex_text_field.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../providers/branding_notifier.dart';

class BrandingSettingsScreen extends ConsumerStatefulWidget {
  const BrandingSettingsScreen({super.key});

  @override
  ConsumerState<BrandingSettingsScreen> createState() =>
      _BrandingSettingsScreenState();
}

class _BrandingSettingsScreenState
    extends ConsumerState<BrandingSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taglineCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _accentColorCtrl = TextEditingController();
  bool _websiteEnabled = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _taglineCtrl.dispose();
    _aboutCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _accentColorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(brandingNotifierProvider.notifier).updateBranding({
        'tagline': _taglineCtrl.text.trim(),
        'about_text': _aboutCtrl.text.trim(),
        'website_phone': _phoneCtrl.text.trim(),
        'website_email': _emailCtrl.text.trim(),
        'whatsapp_number': _whatsappCtrl.text.trim(),
        'accent_color': _accentColorCtrl.text.trim().isNotEmpty
            ? _accentColorCtrl.text.trim()
            : '#C9A84C',
        'website_enabled': _websiteEnabled,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firm branding updated successfully!'),
            backgroundColor: LexColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(currentUserRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!userRole.isFirmAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Firm Branding & Website')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: isDark ? LexColors.textSecondaryDark : LexColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LexColors.textPrimaryDark : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Only Law Firm Administrators can manage public branding and firm portal settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? LexColors.textSecondaryDark : LexColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final brandingAsync = ref.watch(brandingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firm Branding & Website'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
      body: brandingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading branding: $err'),
          ),
        ),
        data: (branding) {
          if (!_initialized) {
            _taglineCtrl.text = branding.tagline;
            _aboutCtrl.text = branding.aboutText;
            _phoneCtrl.text = branding.websitePhone;
            _emailCtrl.text = branding.websiteEmail;
            _whatsappCtrl.text = branding.whatsappNumber;
            _accentColorCtrl.text = branding.accentColor;
            _websiteEnabled = branding.websiteEnabled;
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Preview Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? LexColors.surfaceDark
                          : LexColors.slatePrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? LexColors.accentGold
                            : LexColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BRAND PREVIEW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _taglineCtrl.text.isNotEmpty
                              ? _taglineCtrl.text
                              : 'Excellence in Legal Practice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? LexColors.accentGold : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _aboutCtrl.text.isNotEmpty
                              ? _aboutCtrl.text
                              : 'Trusted legal advisory and advocacy counsel.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Website status toggle
                  LexCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Public Practice Website',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Publish firm overview on public portal',
                      ),
                      value: _websiteEnabled,
                      onChanged: (v) => setState(() => _websiteEnabled = v),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Brand Identity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? LexColors.textPrimaryDark
                          : LexColors.slatePrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  LexTextField(
                    controller: _taglineCtrl,
                    label: 'Firm Tagline / Motto',
                    hintText: 'e.g. Defending Justice, Protecting Rights',
                    prefixIcon: Icons.format_quote_outlined,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),

                  LexTextField(
                    controller: _aboutCtrl,
                    label: 'About Firm Summary',
                    hintText:
                        'Brief biography or profile of the legal practice',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),

                  LexTextField(
                    controller: _accentColorCtrl,
                    label: 'Accent Color (Hex)',
                    hintText: '#C9A84C',
                    prefixIcon: Icons.color_lens_outlined,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Website Contact Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? LexColors.textPrimaryDark
                          : LexColors.slatePrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  LexTextField(
                    controller: _phoneCtrl,
                    label: 'Contact Phone',
                    hintText: '+91 9876543210',
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 14),

                  LexTextField(
                    controller: _emailCtrl,
                    label: 'Contact Email',
                    hintText: 'contact@lawfirm.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),

                  LexTextField(
                    controller: _whatsappCtrl,
                    label: 'WhatsApp Business Number',
                    hintText: '+91 9876543210',
                    prefixIcon: Icons.chat_outlined,
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LexColors.slatePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Branding Settings'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
