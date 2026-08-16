import 'package:flutter/material.dart';
import '../services/marketplace_store.dart';
import '../theme/app_text_styles.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: marketplaceStore,
      builder: (context, _) {
        final currentLang = marketplaceStore.currentProfile?.language ?? 'English';
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                marketplaceStore.tr('language'),
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              _languageTile(context, 'English', 'Default', isSelected: currentLang == 'English'),
              _languageTile(context, 'Twi', 'Akan', isSelected: currentLang == 'Twi'),
              _languageTile(context, 'French', 'Français', isSelected: currentLang == 'French'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Note: Full app translation is coming soon. This setting will update your preference.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(
    BuildContext context,
    String name,
    String sub, {
    bool isSelected = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: () async {
        await marketplaceStore.updateProfile(language: name);
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language set to $name')),
        );
      },
    );
  }
}
