import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/firm_theme.dart';
import 'package:flutter_application_1/features/branding/data/models/firm_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirmTheme & Color Utilities Tests', () {
    test('hexToColor parses 6-digit hex correctly', () {
      final color = hexToColor('#0D1B2A');
      expect(color.toARGB32(), equals(const Color(0xFF0D1B2A).toARGB32()));

      final withoutHash = hexToColor('C9A84C');
      expect(
        withoutHash.toARGB32(),
        equals(const Color(0xFFC9A84C).toARGB32()),
      );
    });

    test('hexToColor parses shorthand 3-digit hex correctly', () {
      final color = hexToColor('#FFF');
      expect(color.toARGB32(), equals(const Color(0xFFFFFFFF).toARGB32()));

      final black = hexToColor('000');
      expect(black.toARGB32(), equals(const Color(0xFF000000).toARGB32()));
    });

    test('hexToColor parses 8-digit hex with custom alpha', () {
      final color = hexToColor('#80FF0000');
      expect(color.toARGB32(), equals(const Color(0x80FF0000).toARGB32()));
    });

    test('hexToColor falls back safely on invalid/null hex', () {
      const fallback = Color(0xFF123456);
      expect(
        hexToColor(null, defaultColor: fallback).toARGB32(),
        equals(fallback.toARGB32()),
      );
      expect(
        hexToColor('', defaultColor: fallback).toARGB32(),
        equals(fallback.toARGB32()),
      );
      expect(
        hexToColor('invalid_color', defaultColor: fallback).toARGB32(),
        equals(fallback.toARGB32()),
      );
      expect(
        hexToColor('12', defaultColor: fallback).toARGB32(),
        equals(fallback.toARGB32()),
      );
    });

    test('colorToHex converts Color to 6-digit hex string', () {
      expect(colorToHex(const Color(0xFF0D1B2A)), equals('#0D1B2A'));
      expect(colorToHex(const Color(0xFFC9A84C)), equals('#C9A84C'));
      expect(
        colorToHex(const Color(0xFF000000), includeHash: false),
        equals('000000'),
      );
    });

    test('resolveFlutterFontFamily normalizes backend CSS font strings', () {
      expect(
        resolveFlutterFontFamily('DM Sans, sans-serif'),
        equals('DM Sans'),
      );
      expect(resolveFlutterFontFamily('Inter, sans-serif'), equals('Inter'));
      expect(
        resolveFlutterFontFamily('Poppins, sans-serif'),
        equals('Poppins'),
      );
      expect(
        resolveFlutterFontFamily('Playfair Display, serif'),
        equals('Playfair Display'),
      );
      expect(resolveFlutterFontFamily('Roboto, sans-serif'), equals('Roboto'));
      expect(resolveFlutterFontFamily(null), equals('DM Sans'));
      expect(resolveFlutterFontFamily('unknown-font'), equals('DM Sans'));
    });
  });

  group('FirmProfile & FirmTheme Model Tests', () {
    test('FirmProfile.fromJson maps all backend fields accurately', () {
      final json = {
        'id': 15,
        'name': 'Smith & Co. Law',
        'email': 'admin@smithlaw.com',
        'phone': '9876543210',
        'address': '123 Legal Court',
        'city': 'Shimla',
        'state': 'Himachal Pradesh',
        'pincode': '171001',
        'gstin': '02ABCDE1234F1Z5',
        'bar_registration': 'HP/123/2020',
        'logo': 'https://api.hphighcourt.site/media/logo.png',
        'theme_color': '#1E293B',
        'accent_color': '#38BDF8',
        'font_family': 'Inter, sans-serif',
        'sidebar_dark': true,
        'website_template': 'modern',
        'website_enabled': true,
        'tagline': 'Justice Above All',
      };

      final profile = FirmProfile.fromJson(json);
      expect(profile.id, equals(15));
      expect(profile.name, equals('Smith & Co. Law'));
      expect(profile.email, equals('admin@smithlaw.com'));
      expect(
        profile.logo,
        equals('https://api.hphighcourt.site/media/logo.png'),
      );
      expect(profile.themeColor, equals('#1E293B'));
      expect(profile.accentColor, equals('#38BDF8'));
      expect(profile.fontFamily, equals('Inter, sans-serif'));
      expect(profile.sidebarDark, isTrue);
      expect(profile.websiteEnabled, isTrue);

      final theme = FirmTheme.fromProfile(profile);
      expect(
        theme.primaryColor.toARGB32(),
        equals(const Color(0xFF1E293B).toARGB32()),
      );
      expect(
        theme.accentColor.toARGB32(),
        equals(const Color(0xFF38BDF8).toARGB32()),
      );
      expect(theme.fontFamily, equals('Inter'));
      expect(theme.sidebarDark, isTrue);
      expect(
        theme.logoUrl,
        equals('https://api.hphighcourt.site/media/logo.png'),
      );
      expect(theme.firmId, equals(15));
    });

    test('FirmTheme serialization and copyWith', () {
      final original = FirmTheme.defaultTheme();
      final updated = original.copyWith(
        primaryColor: const Color(0xFF1B4332),
        accentColor: const Color(0xFF52B788),
        fontFamily: 'Poppins',
        sidebarDark: false,
      );

      expect(
        updated.primaryColor.toARGB32(),
        equals(const Color(0xFF1B4332).toARGB32()),
      );
      expect(
        updated.accentColor.toARGB32(),
        equals(const Color(0xFF52B788).toARGB32()),
      );
      expect(updated.fontFamily, equals('Poppins'));
      expect(updated.sidebarDark, isFalse);

      final json = updated.toJson();
      final restored = FirmTheme.fromJson(json);
      expect(
        restored.primaryColor.toARGB32(),
        equals(updated.primaryColor.toARGB32()),
      );
      expect(
        restored.accentColor.toARGB32(),
        equals(updated.accentColor.toARGB32()),
      );
      expect(restored.fontFamily, equals(updated.fontFamily));
      expect(restored.sidebarDark, equals(updated.sidebarDark));
    });
  });
}
