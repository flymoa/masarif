import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icones dyal l app — nfs les SVG dyal mockups V2 (stroke 1.8, viewBox 24).
/// Smiyat b7al Material bach yb9a l code sahl yt9ra.
class I {
  I._();
  // Categories
  static const resto = 'resto', cart = 'cart', coffee = 'coffee', car = 'car', home = 'home', bolt = 'bolt';
  static const pharma = 'pharma', play = 'play', sport = 'sport', gift = 'gift', phone = 'phone', book = 'book';
  static const work = 'work', wallet = 'wallet', box = 'box';
  // UI (smiyat 9dam dyal Material → icone V2)
  static const home_outlined = 'navHome', home_rounded = 'navHomeFill';
  static const list_alt_outlined = 'list', list_alt_rounded = 'listBold';
  static const bar_chart_outlined = 'bars', bar_chart_rounded = 'barsBold';
  static const person_outline_rounded = 'user', person_rounded = 'userFill';
  static const add_rounded = 'plus', remove_rounded = 'minus';
  static const north_east_rounded = 'arrowNE', south_west_rounded = 'arrowSW', arrow_forward_rounded = 'arrowR';
  static const savings_outlined = 'jar', notifications_none_rounded = 'bell';
  static const visibility_outlined = 'eye', visibility_off_outlined = 'eyeOff';
  static const search_rounded = 'search', tune_rounded = 'filter', close_rounded = 'close';
  static const chevron_left_rounded = 'back', chevron_right_rounded = 'chevronR';
  static const delete_outline_rounded = 'trash', backspace_outlined = 'backspace';
  static const calendar_today_outlined = 'calendar', photo_camera_outlined = 'camera';
  static const grid_view_rounded = 'grid', dark_mode_outlined = 'moon', logout_rounded = 'logout';
  static const lock_outline = 'lock', lock_reset_rounded = 'lockReset', check_rounded = 'check';
  static const cloud_off_outlined = 'cloudOff', cloud_done_outlined = 'cloudDone';
  static const receipt_long_outlined = 'receipt', info_outline_rounded = 'info';
  static const warning_amber_rounded = 'warning', mail_outline_rounded = 'mail', track_changes_rounded = 'target';
  static const auto_awesome_rounded = 'khatam';
}

const _stroke = <String, String>{
  'resto': '<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2M7 2v20M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3zm0 0v7"/>',
  'cart': '<circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2 2h2l2.7 12.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L22 7H5.1"/>',
  'coffee': '<path d="M10 2v2M14 2v2M6 2v2M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1 0 8h-1"/>',
  'car': '<path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/>',
  'home': '<path d="M4 11 12 4l8 7M6 10v10h12V10M10 20v-5h4v5"/>',
  'bolt': '<path d="M13 2 4 14h7l-1 8 9-12h-7z"/>',
  'sport': '<path d="M6 5v14M18 5v14M3 9v6M21 9v6M6 12h12"/>',
  'gift': '<path d="M20 12v9H4v-9M2 7h20v5H2zM12 21V7M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7zM12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>',
  'phone': '<rect x="7" y="3" width="10" height="18" rx="2"/><path d="M11 18h2"/>',
  'book': '<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2zM4 19V5"/>',
  'work': '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M9 7V5h6v2M3 13h18"/>',
  'wallet': '<path d="M19 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h14a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2.5M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4"/>',
  'box': '<path d="M3 7.5 12 3l9 4.5v9L12 21l-9-4.5zM3 7.5l9 4.5 9-4.5M12 12v9"/>',
  'navHome': '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>',
  'list': '<path d="M9 6h12M9 12h12M9 18h12M4 6h.01M4 12h.01M4 18h.01"/>',
  'listBold': '<path d="M9 6h12M9 12h12M9 18h12M4 6h.01M4 12h.01M4 18h.01" stroke-width="2.4"/>',
  'bars': '<path d="M5 20V11M12 20V4M19 20v-6"/>',
  'barsBold': '<path d="M5 20V11M12 20V4M19 20v-6" stroke-width="2.6"/>',
  'user': '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7"/>',
  'plus': '<path d="M12 5v14M5 12h14"/>',
  'minus': '<path d="M5 12h14"/>',
  'arrowNE': '<path d="M7 17 17 7M9 7h8v8"/>',
  'arrowSW': '<path d="M17 7 7 17M7 9v8h8"/>',
  'arrowR': '<path d="M5 12h14M13 6l6 6-6 6"/>',
  'jar': '<path d="M8 3h8M9 3v2.5A6 6 0 0 0 5 11v7a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3v-7a6 6 0 0 0-4-5.5V3M10 12h4"/>',
  'bell': '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9M10.3 21a1.9 1.9 0 0 0 3.4 0"/>',
  'eye': '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  'eyeOff': '<path d="M10.7 5.1A10 10 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-2.2 3.2M6.6 6.6A16.5 16.5 0 0 0 2 12s3.5 7 10 7a9.7 9.7 0 0 0 5.4-1.6M3 3l18 18M9.9 9.9a3 3 0 0 0 4.2 4.2"/>',
  'search': '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
  'filter': '<path d="M4 6h16M7 12h10M10 18h4"/>',
  'close': '<path d="M6 6l12 12M18 6 6 18"/>',
  'back': '<path d="M15 5l-7 7 7 7"/>',
  'chevronR': '<path d="M9 5l7 7-7 7"/>',
  'trash': '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  'backspace': '<path d="M9 5h11v14H9l-6-7z"/><path d="m12 9 5 6M17 9l-5 6"/>',
  'calendar': '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
  'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z"/><circle cx="12" cy="13" r="3"/>',
  'grid': '<rect x="3" y="3" width="7" height="7" rx="2"/><rect x="14" y="3" width="7" height="7" rx="2"/><rect x="3" y="14" width="7" height="7" rx="2"/><rect x="14" y="14" width="7" height="7" rx="2"/>',
  'moon': '<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>',
  'logout': '<path d="M15 4h4v16h-4M10 8l-4 4 4 4M6 12h11"/>',
  'lock': '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
  'lockReset': '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 7.5-2"/><circle cx="12" cy="16" r="1.3"/>',
  'check': '<path d="m5 12 5 5 9-10"/>',
  'cloudOff': '<path d="M7 18a5 5 0 1 1 1-9.9A6 6 0 0 1 19.5 10 4 4 0 0 1 18 18z"/><path d="M4 4l16 16"/>',
  'cloudDone': '<path d="M7 18a5 5 0 1 1 1-9.9A6 6 0 0 1 19.5 10 4 4 0 0 1 18 18z"/><path d="m9.5 13.5 2 2 3.5-3.5"/>',
  'receipt': '<path d="M5 3h14v18l-3-2-2 2-2-2-2 2-2-2-3 2z"/><path d="M9 8h6M9 12h6"/>',
  'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  'warning': '<path d="M12 9v4M12 17h.01M10.3 3.9 2.4 18a2 2 0 0 0 1.7 3h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>',
  'mail': '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
  'target': '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/>',
};

const _fill = <String, String>{
  'pharma': '<path d="M9.5 3h5v6.5H21v5h-6.5V21h-5v-6.5H3v-5h6.5z"/>',
  'play': '<path d="M8 5.5v13l10-6.5z"/>',
  'navHomeFill': '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>',
  'userFill': '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7z"/>',
  'khatam': '<g transform="translate(12 12)"><rect x="-6" y="-6" width="12" height="12" rx="1.5"/><rect x="-6" y="-6" width="12" height="12" rx="1.5" transform="rotate(45)"/></g>',
};

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Widget dyal icone (b7al Icon, walakin b SVG dyal design).
class Ic extends StatelessWidget {
  const Ic(this.name, {super.key, this.color, this.size = 24, this.semanticLabel, this.strokeWidth = 1.8});
  final String name;
  final Color? color;
  final double size;
  final String? semanticLabel;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final col = _hex(color ?? IconTheme.of(context).color ?? Colors.black);
    final opacity = (color ?? IconTheme.of(context).color ?? Colors.black).a;
    final String svg;
    if (_fill.containsKey(name)) {
      svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$col" fill-opacity="$opacity">${_fill[name]}</svg>';
    } else {
      svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="$col" stroke-opacity="$opacity" '
          'stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">${_stroke[name] ?? _stroke['box']}</svg>';
    }
    // B7al Icon: kayb9a f lwost b nfs l 7ajm wakha l parent ykoun kbir.
    final pic = SizedBox(
      width: size,
      height: size,
      child: Center(child: SizedBox(width: size, height: size, child: SvgPicture.string(svg, width: size, height: size))),
    );
    return semanticLabel == null ? ExcludeSemantics(child: pic) : Semantics(label: semanticLabel, child: pic);
  }
}
