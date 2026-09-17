class FirmProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String gstin;
  final String barRegistration;
  final String? logo;
  final String? heroImage;
  final DateTime? createdAt;
  final String themeColor;
  final String accentColor;
  final String fontFamily;
  final bool sidebarDark;
  final String websiteTemplate;
  final bool websiteEnabled;
  final String tagline;
  final String aboutText;
  final List<String> practiceAreas;
  final String websitePhone;
  final String websiteEmail;
  final String whatsappNumber;

  const FirmProfile({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.gstin = '',
    this.barRegistration = '',
    this.logo,
    this.heroImage,
    this.createdAt,
    this.themeColor = '#0D1B2A',
    this.accentColor = '#C9A84C',
    this.fontFamily = 'DM Sans, sans-serif',
    this.sidebarDark = true,
    this.websiteTemplate = 'classic',
    this.websiteEnabled = false,
    this.tagline = 'Excellence in Legal Practice',
    this.aboutText = '',
    this.practiceAreas = const [],
    this.websitePhone = '',
    this.websiteEmail = '',
    this.whatsappNumber = '',
  });

  FirmProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? gstin,
    String? barRegistration,
    String? logo,
    String? heroImage,
    DateTime? createdAt,
    String? themeColor,
    String? accentColor,
    String? fontFamily,
    bool? sidebarDark,
    String? websiteTemplate,
    bool? websiteEnabled,
    String? tagline,
    String? aboutText,
    List<String>? practiceAreas,
    String? websitePhone,
    String? websiteEmail,
    String? whatsappNumber,
  }) {
    return FirmProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      gstin: gstin ?? this.gstin,
      barRegistration: barRegistration ?? this.barRegistration,
      logo: logo ?? this.logo,
      heroImage: heroImage ?? this.heroImage,
      createdAt: createdAt ?? this.createdAt,
      themeColor: themeColor ?? this.themeColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      sidebarDark: sidebarDark ?? this.sidebarDark,
      websiteTemplate: websiteTemplate ?? this.websiteTemplate,
      websiteEnabled: websiteEnabled ?? this.websiteEnabled,
      tagline: tagline ?? this.tagline,
      aboutText: aboutText ?? this.aboutText,
      practiceAreas: practiceAreas ?? this.practiceAreas,
      websitePhone: websitePhone ?? this.websitePhone,
      websiteEmail: websiteEmail ?? this.websiteEmail,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  factory FirmProfile.fromJson(Map<String, dynamic> json) {
    return FirmProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      barRegistration: json['bar_registration'] as String? ?? '',
      logo: json['logo'] as String?,
      heroImage: json['hero_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      themeColor: json['theme_color'] as String? ?? '#0D1B2A',
      accentColor: json['accent_color'] as String? ?? '#C9A84C',
      fontFamily: json['font_family'] as String? ?? 'DM Sans, sans-serif',
      sidebarDark: json['sidebar_dark'] as bool? ?? true,
      websiteTemplate: json['website_template'] as String? ?? 'classic',
      websiteEnabled: json['website_enabled'] as bool? ?? false,
      tagline: json['tagline'] as String? ?? 'Excellence in Legal Practice',
      aboutText: json['about_text'] as String? ?? '',
      practiceAreas: json['practice_areas'] is List
          ? (json['practice_areas'] as List).map((e) => e.toString()).toList()
          : const [],
      websitePhone: json['website_phone'] as String? ?? '',
      websiteEmail: json['website_email'] as String? ?? '',
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
    'gstin': gstin,
    'bar_registration': barRegistration,
    'logo': logo,
    'hero_image': heroImage,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    'theme_color': themeColor,
    'accent_color': accentColor,
    'font_family': fontFamily,
    'sidebar_dark': sidebarDark,
    'website_template': websiteTemplate,
    'website_enabled': websiteEnabled,
    'tagline': tagline,
    'about_text': aboutText,
    'practice_areas': practiceAreas,
    'website_phone': websitePhone,
    'website_email': websiteEmail,
    'whatsapp_number': whatsappNumber,
  };
}
