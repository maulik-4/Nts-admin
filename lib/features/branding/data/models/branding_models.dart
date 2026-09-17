class FirmWebsiteBranding {
  final String tagline;
  final String aboutText;
  final String themeColor;
  final String accentColor;
  final String websitePhone;
  final String websiteEmail;
  final String whatsappNumber;
  final bool websiteEnabled;
  final String websiteTemplate;

  const FirmWebsiteBranding({
    this.tagline = '',
    this.aboutText = '',
    this.themeColor = '#0D1B2A',
    this.accentColor = '#C9A84C',
    this.websitePhone = '',
    this.websiteEmail = '',
    this.whatsappNumber = '',
    this.websiteEnabled = false,
    this.websiteTemplate = 'classic',
  });

  factory FirmWebsiteBranding.fromJson(Map<String, dynamic> json) {
    return FirmWebsiteBranding(
      tagline: json['tagline'] as String? ?? '',
      aboutText: json['about_text'] as String? ?? '',
      themeColor: json['theme_color'] as String? ?? '#0D1B2A',
      accentColor: json['accent_color'] as String? ?? '#C9A84C',
      websitePhone: json['website_phone'] as String? ?? '',
      websiteEmail: json['website_email'] as String? ?? '',
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      websiteEnabled: json['website_enabled'] as bool? ?? false,
      websiteTemplate: json['website_template'] as String? ?? 'classic',
    );
  }

  Map<String, dynamic> toJson() => {
    'tagline': tagline,
    'about_text': aboutText,
    'theme_color': themeColor,
    'accent_color': accentColor,
    'website_phone': websitePhone,
    'website_email': websiteEmail,
    'whatsapp_number': whatsappNumber,
    'website_enabled': websiteEnabled,
    'website_template': websiteTemplate,
  };
}

class FirmDetails {
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

  const FirmDetails({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.gstin = '',
    this.barRegistration = '',
  });

  factory FirmDetails.fromJson(Map<String, dynamic> json) {
    return FirmDetails(
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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
    'gstin': gstin,
    'bar_registration': barRegistration,
  };
}
