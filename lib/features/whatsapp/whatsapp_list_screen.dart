import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/whatsapp_provider.dart';
import '../content_type/content_type_sheet.dart';
import 'widgets/contact_list_tile.dart';

class WhatsAppListScreen extends ConsumerStatefulWidget {
  const WhatsAppListScreen({super.key});

  @override
  ConsumerState<WhatsAppListScreen> createState() => _WhatsAppListScreenState();
}

class _WhatsAppListScreenState extends ConsumerState<WhatsAppListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final whatsappData = ref.watch(whatsappContactsProvider);

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'WhatsApp Media',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search, color: AppColors.darkTextMuted),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: whatsappData.when(
              data: (contacts) {
                final filtered = contacts.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No WhatsApp media found.', style: TextStyle(color: AppColors.darkTextMuted)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    return ContactListTile(
                      contact: contact,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ContentTypeSheet(
                            sourceName: contact.name,
                            sourcePath: 'WhatsApp', // Logic to handle multiple sources if needed
                            filesByType: contact.filesByType,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) => Shimmer.fromColors(
                  baseColor: AppColors.darkSurface,
                  highlightColor: AppColors.darkSurface.withOpacity(0.5),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
