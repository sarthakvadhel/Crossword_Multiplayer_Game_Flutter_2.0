import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../state/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.secondary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Player',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.read(authProvider.notifier).signIn(),
                  child: Text(user == null ? 'Google Sign-In' : 'Signed In'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsTile(icon: Icons.settings, title: 'Settings'),
          _SettingsTile(icon: Icons.help_outline, title: 'Help'),
          _SettingsTile(icon: Icons.info_outline, title: 'About'),
          _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy'),
          _SettingsTile(icon: Icons.block, title: 'Remove Ads'),
          _SettingsTile(icon: Icons.restore, title: 'Restore Purchases'),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
