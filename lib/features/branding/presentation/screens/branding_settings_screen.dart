import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/firm_theme.dart';
import '../../../../core/theme/lex_colors.dart';
import '../../../../shared/widgets/lex_card.dart';
import '../../../auth/domain/models/role_capabilities.dart';
import '../../data/models/firm_profile.dart';
import '../providers/branding_notifier.dart';

class BrandingSettingsScreen extends ConsumerStatefulWidget {
  const BrandingSettingsScreen({super.key});

  @override
  ConsumerState<BrandingSettingsScreen> createState() =>
      _BrandingSettingsScreenState();
}

class _BrandingSettingsScreenState
    extends ConsumerState<BrandingSettingsScreen> {
  // Loaded baseline state
  FirmProfile? _initialProfile;

  // Unsaved draft values
  late Color _draftPrimaryColor;
  late Color _draftAccentColor;
  late String _draftFontFamily;
  late bool _draftSidebarDark;
  PlatformFile? _pickedLogoFile;
  String? _existingLogoUrl;

  late TextEditingController _primaryHexCtrl;
  late TextEditingController _accentHexCtrl;

  bool _isSaving = false;
  bool _initialized = false;

  final List<String> _availableFonts = const [
    'DM Sans',
    'Inter',
    'Poppins',
    'Playfair Display',
  ];

  @override
  void initState() {
    super.initState();
    _draftPrimaryColor = const Color(0xFF0D1B2A);
    _draftAccentColor = const Color(0xFFC9A84C);
    _draftFontFamily = 'DM Sans';
    _draftSidebarDark = true;
    _primaryHexCtrl = TextEditingController(text: '#0D1B2A');
    _accentHexCtrl = TextEditingController(text: '#C9A84C');
  }

  @override
  void dispose() {
    _primaryHexCtrl.dispose();
    _accentHexCtrl.dispose();
    super.dispose();
  }

  void _syncWithProfile(FirmProfile profile) {
    _initialProfile = profile;
    _draftPrimaryColor = hexToColor(
      profile.themeColor,
      defaultColor: const Color(0xFF0D1B2A),
    );
    _draftAccentColor = hexToColor(
      profile.accentColor,
      defaultColor: const Color(0xFFC9A84C),
    );
    _draftFontFamily = resolveFlutterFontFamily(profile.fontFamily);
    _draftSidebarDark = profile.sidebarDark;
    _existingLogoUrl = profile.logo;
    _pickedLogoFile = null;

    _primaryHexCtrl.text = colorToHex(_draftPrimaryColor);
    _accentHexCtrl.text = colorToHex(_draftAccentColor);
    _initialized = true;
  }

  bool get _hasUnsavedChanges {
    if (_initialProfile == null) return false;
    if (_pickedLogoFile != null) return true;

    final initialPrimary = hexToColor(_initialProfile!.themeColor);
    final initialAccent = hexToColor(_initialProfile!.accentColor);
    final initialFont = resolveFlutterFontFamily(_initialProfile!.fontFamily);
    final initialSidebar = _initialProfile!.sidebarDark;

    return _draftPrimaryColor.toARGB32() != initialPrimary.toARGB32() ||
        _draftAccentColor.toARGB32() != initialAccent.toARGB32() ||
        _draftFontFamily != initialFont ||
        _draftSidebarDark != initialSidebar;
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedLogoFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    }
  }

  void _applyPreset(FirmBrandingPreset preset) {
    setState(() {
      _draftPrimaryColor = preset.primaryColor;
      _draftAccentColor = preset.accentColor;
      _draftFontFamily = preset.fontFamily;
      _draftSidebarDark = preset.sidebarDark;
      _primaryHexCtrl.text = colorToHex(preset.primaryColor);
      _accentHexCtrl.text = colorToHex(preset.accentColor);
    });
  }

  void _resetDraft() {
    if (_initialProfile != null) {
      setState(() {
        _syncWithProfile(_initialProfile!);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(firmProfileNotifierProvider.notifier);
      final updated = await notifier.saveBranding(
        themeColor: colorToHex(_draftPrimaryColor),
        accentColor: colorToHex(_draftAccentColor),
        fontFamily: '$_draftFontFamily, sans-serif',
        sidebarDark: _draftSidebarDark,
        logoFilePath: _pickedLogoFile?.path,
        logoFileName: _pickedLogoFile?.name,
        logoBytes: _pickedLogoFile?.bytes,
      );

      if (mounted) {
        _syncWithProfile(updated);
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
            content: Text('Failed to save branding: $e'),
            backgroundColor: LexColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Unsaved Changes?'),
        content: const Text(
          'You have uncommitted branding modifications. Leaving now will discard all unsaved changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LexColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard & Leave'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(currentUserRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Strict role check: Lawyers/Staff are read-only
    if (!userRole.isFirmAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Firm Branding')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 52,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Firm Administrator Access Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LexColors.textPrimaryDark
                        : LexColors.slatePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Only Law Firm Administrators have permission to modify firm branding, colors, logos, and typography.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? LexColors.textSecondaryDark
                        : LexColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profileAsync = ref.watch(firmProfileNotifierProvider);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firm Branding Studio'),
          actions: [
            if (_hasUnsavedChanges && !_isSaving)
              TextButton(onPressed: _resetDraft, child: const Text('Reset')),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: _draftPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
        body: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: LexColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text('Failed to load branding: $err'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(firmProfileNotifierProvider.notifier)
                        .loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (profile) {
            if (!_initialized || _initialProfile?.id != profile.id) {
              _syncWithProfile(profile);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Controls Column
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildControls(context, profile, isDark),
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      // Live Preview Column
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildLivePreviewCard(context, profile),
                        ),
                      ),
                    ],
                  );
                }

                // Mobile / Tablet single column
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Live Preview Card on top or bottom
                      _buildLivePreviewCard(context, profile),
                      const SizedBox(height: 24),
                      _buildControls(context, profile, isDark),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    FirmProfile profile,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Firm Identity & Logo
        _buildSectionHeader('Firm Identity & Logo', Icons.badge_outlined),
        const SizedBox(height: 12),
        LexCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : 'Your Law Firm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Registered Firm ID: #${profile.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? LexColors.textSecondaryDark
                      : LexColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              const Text(
                'Firm Brand Logo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildLogoPreview(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _draftPrimaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 40),
                          ),
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: Text(
                            _pickedLogoFile != null || _existingLogoUrl != null
                                ? 'Replace Logo'
                                : 'Upload Logo',
                          ),
                        ),
                        if (_pickedLogoFile != null) ...[
                          const SizedBox(height: 6),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: LexColors.error,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              setState(() => _pickedLogoFile = null);
                            },
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Cancel selection'),
                          ),
                        ],
                        const SizedBox(height: 4),
                        const Text(
                          'Formats: PNG, JPG, WEBP (Max 5MB)',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section: Quick Presets
        _buildSectionHeader('Quick Theme Presets', Icons.auto_awesome),
        const SizedBox(height: 8),
        const Text(
          'Select a curated legal color scheme to immediately preview:',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: FirmBrandingPreset.presets.map((preset) {
            final isSelected =
                _draftPrimaryColor.toARGB32() ==
                    preset.primaryColor.toARGB32() &&
                _draftAccentColor.toARGB32() == preset.accentColor.toARGB32();

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _applyPreset(preset),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? preset.accentColor
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? preset.primaryColor.withValues(alpha: 0.08)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: preset.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: preset.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Section: Color Customization
        _buildSectionHeader('Custom Colors', Icons.palette_outlined),
        const SizedBox(height: 12),
        LexCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Primary Color
              _buildColorRow(
                label: 'Primary / Theme Color',
                subtitle: 'Buttons, app bars, firm headers & active highlights',
                currentColor: _draftPrimaryColor,
                controller: _primaryHexCtrl,
                onChanged: (color) {
                  setState(() => _draftPrimaryColor = color);
                },
                swatches: const [
                  Color(0xFF0D1B2A),
                  Color(0xFF1E293B),
                  Color(0xFF1B4332),
                  Color(0xFF4A0E17),
                  Color(0xFF183059),
                  Color(0xFF2B2D42),
                ],
              ),
              const Divider(height: 32),
              // Accent Color
              _buildColorRow(
                label: 'Accent Color',
                subtitle: 'Badges, icons, selected states & decorative accents',
                currentColor: _draftAccentColor,
                controller: _accentHexCtrl,
                onChanged: (color) {
                  setState(() => _draftAccentColor = color);
                },
                swatches: const [
                  Color(0xFFC9A84C),
                  Color(0xFF38BDF8),
                  Color(0xFF52B788),
                  Color(0xFFE2C275),
                  Color(0xFFF59E0B),
                  Color(0xFFEC4899),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section: Typography & Navigation
        _buildSectionHeader('Typography & Sidebar', Icons.text_fields),
        const SizedBox(height: 12),
        LexCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firm Typography',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selected font family applies globally across all firm views.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _draftFontFamily,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: _availableFonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(
                      font,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _draftFontFamily = val);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Dark Sidebar Mode',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Maintains a sleek dark navigation rail even in light theme.',
                  style: TextStyle(fontSize: 12),
                ),
                value: _draftSidebarDark,
                activeThumbColor: _draftAccentColor,
                onChanged: (val) {
                  setState(() => _draftSidebarDark = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPreview() {
    if (_pickedLogoFile != null) {
      if (kIsWeb && _pickedLogoFile!.bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            _pickedLogoFile!.bytes!,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        );
      } else if (_pickedLogoFile!.path != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_pickedLogoFile!.path!),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _existingLogoUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackLogoContainer(),
        ),
      );
    }

    return _buildFallbackLogoContainer();
  }

  Widget _buildFallbackLogoContainer() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _draftPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(Icons.balance, size: 32, color: _draftAccentColor),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _draftAccentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildColorRow({
    required String label,
    required String subtitle,
    required Color currentColor,
    required TextEditingController controller,
    required ValueChanged<Color> onChanged,
    required List<Color> swatches,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'HEX Code',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) {
                  final parsed = hexToColor(val, defaultColor: currentColor);
                  onChanged(parsed);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: swatches.map((color) {
                    final isSel = color.toARGB32() == currentColor.toARGB32();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          controller.text = colorToHex(color);
                          onChanged(color);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Interactive live preview demonstrating the unsaved draft theme in real time
  Widget _buildLivePreviewCard(BuildContext context, FirmProfile profile) {
    final sidebarBg = _draftSidebarDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF1F5F9);
    final sidebarText = _draftSidebarDark ? Colors.white : _draftPrimaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LIVE PREVIEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _hasUnsavedChanges
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _hasUnsavedChanges ? 'UNSAVED DRAFT' : 'CURRENT SAVED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _hasUnsavedChanges
                      ? Colors.orange[800]
                      : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Mini App Bar
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _draftPrimaryColor,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _draftAccentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.balance,
                        size: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name
                            : 'Smith & Co. Law',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: _draftFontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.notifications_none,
                      size: 18,
                      color: _draftAccentColor,
                    ),
                  ],
                ),
              ),

              // Mock Window Body: Mini Sidebar + Mini Content
              Expanded(
                child: Row(
                  children: [
                    // Mini Sidebar
                    Container(
                      width: 95,
                      color: sidebarBg,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildMiniNavItem(
                            icon: Icons.dashboard,
                            label: 'Dashboard',
                            isActive: true,
                            activeColor: _draftAccentColor,
                            textColor: sidebarText,
                          ),
                          _buildMiniNavItem(
                            icon: Icons.people,
                            label: 'Clients',
                            isActive: false,
                            activeColor: _draftAccentColor,
                            textColor: sidebarText,
                          ),
                          _buildMiniNavItem(
                            icon: Icons.gavel,
                            label: 'Cases',
                            isActive: false,
                            activeColor: _draftAccentColor,
                            textColor: sidebarText,
                          ),
                          _buildMiniNavItem(
                            icon: Icons.group,
                            label: 'Team',
                            isActive: false,
                            activeColor: _draftAccentColor,
                            textColor: sidebarText,
                          ),
                        ],
                      ),
                    ),

                    // Mini Content Area
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advocate Workspace',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                fontFamily: _draftFontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mini Metric Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStatCard(
                                    title: 'Active Cases',
                                    value: '24',
                                    accent: _draftAccentColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildMiniStatCard(
                                    title: 'Hearings',
                                    value: '6',
                                    accent: _draftPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Mini Action Button
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: _draftPrimaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  'Create New Case',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: _draftFontFamily,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mini Accent Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _draftAccentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _draftAccentColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '• Hearing Scheduled Tomorrow',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _draftPrimaryColor,
                                  fontFamily: _draftFontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: isActive ? activeColor : textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : textColor.withValues(alpha: 0.8),
              fontFamily: _draftFontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
              fontFamily: _draftFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
