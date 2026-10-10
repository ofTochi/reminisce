import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/whatsapp_provider.dart';
import 'widgets/storage_ring_card.dart';
import 'widgets/source_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final whatsappData = ref.watch(whatsappContactsProvider);

    return AppBackground(
      gradientStyle: 1,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/reminisce_logo.png'),
            ),
            title: Text(
              'Reminisce',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.wb_sunny_outlined, color: AppColors.darkPrimaryGold),
              ),
            ],
            floating: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const StorageRingCard(),
                const SizedBox(height: 32),
                Text(
                  'Start Cleaning',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                SourceCard(
                  icon: Icons.folder_open,
                  title: 'Device Folders',
                  subtitle: 'Browse and clean by folder',
                  borderColor: AppColors.darkPrimaryGold,
                  onTap: () => context.push('/folders'),
                ),
                const SizedBox(height: 12),
                SourceCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'WhatsApp Media',
                  subtitle: 'Clean by contact or group',
                  borderColor: const Color(0xFF25D366),
                  badge: whatsappData.when(
                    data: (list) {
                      final totalBytes = list.fold<int>(0, (sum, item) => sum + item.totalBytes);
                      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
                    },
                    loading: () => '...',
                    error: (_, __) => null,
                  ),
                  onTap: () => context.push('/whatsapp'),
                ),
                if (session.status != SessionStatus.none) ...[
                  const SizedBox(height: 32),
                  _ResumeSessionBanner(session: session),
                ],
                const SizedBox(height: 100), // Space for floating nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeSessionBanner extends StatelessWidget {
  final SessionState session;

  const _ResumeSessionBanner({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.restore, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume Session',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade200),
                ),
                Text(
                  '${session.activeSourceName} · ${session.currentIndex}/${session.allFiles.length} files',
                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (session.activeContentType == ContentType.photo) {
                context.push('/clean/photo');
              } else if (session.activeContentType == ContentType.document) {
                context.push('/clean/document');
              } else if (session.activeContentType == ContentType.audio) {
                context.push('/clean/audio');
              }
            },
            child: const Text('Continue →', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }
}
