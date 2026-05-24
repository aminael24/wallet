import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_provider.dart';
import '../../utils/validators.dart';
import '../auth/login_screen.dart';

/// ============================================================
/// VIEW : ProfileScreen
/// Profil utilisateur : édition, changement mot de passe, thème, logout
/// ============================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editingName = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final user = AppProvider.of(context).authController.currentUser;
      _nameCtrl.text = user?.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom doit contenir au moins 2 caractères')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final success = await AppProvider.of(context)
        .authController
        .updateProfile(fullName: _nameCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _editingName = false;
    });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour'),
          backgroundColor: AppColors.income,
        ),
      );
    }
  }

  Future<void> _changePasswordDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Ancien mot de passe',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe',
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer',
                  ),
                  validator: (v) =>
                      Validators.validateConfirmPassword(v, newCtrl.text),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;
    final auth = AppProvider.of(context).authController;
    final ok = await auth.changePassword(oldCtrl.text, newCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Mot de passe changé avec succès'
            : auth.errorMessage ?? 'Erreur'),
        backgroundColor: ok ? AppColors.income : AppColors.danger,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppProvider.of(context).authController.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppProvider.of(context);
    final user = app.authController.currentUser;
    final themeCtrl = app.themeController;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        children: [
          // En-tête : avatar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section infos personnelles
          _sectionTitle('Informations personnelles'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: _editingName
                      ? TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        )
                      : Text(user?.fullName ?? ''),
                  subtitle: const Text('Nom complet'),
                  trailing: _editingName
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.danger),
                              onPressed: () => setState(() {
                                _editingName = false;
                                _nameCtrl.text = user?.fullName ?? '';
                              }),
                            ),
                            IconButton(
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.check,
                                      color: AppColors.income),
                              onPressed: _isSaving ? null : _saveName,
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              setState(() => _editingName = true),
                        ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(user?.email ?? ''),
                  subtitle: const Text('Adresse email'),
                ),
              ],
            ),
          ),

          // Section sécurité
          _sectionTitle('Sécurité'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Changer le mot de passe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePasswordDialog,
            ),
          ),

          // Section préférences
          _sectionTitle('Préférences'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListenableBuilder(
              listenable: themeCtrl,
              builder: (ctx, _) {
                return SwitchListTile(
                  secondary: Icon(themeCtrl.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode),
                  title: const Text('Mode sombre'),
                  subtitle: Text(themeCtrl.isDarkMode ? 'Activé' : 'Désactivé'),
                  value: themeCtrl.isDarkMode,
                  onChanged: (v) => themeCtrl.toggleTheme(),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Bouton déconnexion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              icon: const Icon(FontAwesomeIcons.rightFromBracket,
                  color: Colors.white, size: 18),
              label: const Text('Se déconnecter'),
            ),
          ),

          const SizedBox(height: 16),

          // Info app
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Wallet App v1.0.0\nENSA Tanger - 2025/2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
