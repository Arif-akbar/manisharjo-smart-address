import 'package:flutter/material.dart';
import '../data/house_model.dart';

class HouseCard extends StatelessWidget {
  final HouseModel house;
  final VoidCallback? onTap;
  final String? searchQuery;

  const HouseCard({
    super.key,
    required this.house,
    this.onTap,
    this.searchQuery,
  });

  Widget _buildHighlightedText(String text, String? query, BuildContext context, TextStyle? style) {
    if (query == null || query.isEmpty) return Text(text, style: style);

    final terms = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return Text(text, style: style);

    String pattern = terms.map((t) => RegExp.escape(t)).join('|');
    final regex = RegExp(pattern, caseSensitive: false);
    final matches = regex.allMatches(text).toList();

    if (matches.isEmpty) return Text(text, style: style);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(backgroundColor: Colors.yellow, color: Colors.black, fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(
                      house.nama,
                      searchQuery,
                      context,
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildHighlightedText(
                      'No. ${house.nomorRumah}',
                      searchQuery,
                      context,
                      TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kode: ${house.kodeRumah} • RT ${house.rt} / RW ${house.rw}',
                      style: TextStyle(color: theme.iconTheme.color, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: house.aktif ? const Color(0xFF22C55E).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  house.aktif ? 'Aktif' : 'Tidak Aktif',
                  style: TextStyle(
                    color: house.aktif ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
