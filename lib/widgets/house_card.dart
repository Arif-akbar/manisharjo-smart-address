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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.home, color: Color(0xFF0F4C81)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(
                      house.nama,
                      searchQuery,
                      context,
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    _buildHighlightedText(
                      'No. ${house.nomorRumah} | Kode: ${house.kodeRumah}',
                      searchQuery,
                      context,
                      TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.map, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'RT ${house.rt} / RW ${house.rw}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: house.aktif ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: house.aktif ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  house.aktif ? 'Aktif' : 'Tidak Aktif',
                  style: TextStyle(
                    color: house.aktif ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
