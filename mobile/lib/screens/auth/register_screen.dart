import 'package:flutter/material.dart';
import '../../widgets/app_input_field.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  bool _isPhone = false;

  @override
  void initState() {
    super.initState();
    _identifierController.addListener(_detectType);
  }

  void _detectType() {
    final v = _identifierController.text;
    final phone = v.isNotEmpty && !v.contains('@');
    if (phone != _isPhone) setState(() => _isPhone = phone);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _identifierController.removeListener(_detectType);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        nom: _nomController.text.trim(),
        identifier: _identifierController.text.trim(),
        motDePasse: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé ! Connecte-toi.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Décoration fond
          Positioned(
            top: -60,
            right: -80,
            child: _GlowBlob(size: 280, color: Colors.orange.withValues(alpha: 0.06)),
          ),
          Positioned(
            top: 120,
            left: -60,
            child: _GlowBlob(size: 200, color: Colors.deepOrange.withValues(alpha: 0.04)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Barre de navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      // Mini logo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.music_note, color: Colors.orange, size: 14),
                            SizedBox(width: 4),
                            Text('FasoVibes',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Crée ton compte',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Rejoins la communauté des artistes burkinabè.',
                            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 36),

                          // Avatar placeholder
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1C1C1C),
                                    border: Border.all(color: Colors.white10, width: 1.5),
                                  ),
                                  child: const Icon(Icons.person, size: 44, color: Colors.white24),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFF8C00), Color(0xFFFF4500)],
                                      ),
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          _SectionLabel('Informations'),
                          const SizedBox(height: 12),
                          AppInputField(
                            controller: _nomController,
                            label: 'Nom d\'artiste / Pseudo',
                            icon: Icons.person_outline,
                            validator: (v) => Validators.required(v, 'Le nom'),
                          ),
                          const SizedBox(height: 14),
                          AppInputField(
                            controller: _identifierController,
                            label: 'Email ou numéro de téléphone',
                            icon: _isPhone ? Icons.phone_outlined : Icons.alternate_email,
                            keyboardType: _isPhone
                                ? TextInputType.phone
                                : TextInputType.emailAddress,
                            validator: Validators.emailOrPhone,
                          ),
                          const SizedBox(height: 14),
                          AppInputField(
                            controller: _passwordController,
                            label: 'Mot de passe',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            validator: Validators.password,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Minimum 6 caractères',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 32),

                          _GradientButton(
                            label: 'Créer mon compte',
                            loading: _loading,
                            onPressed: _register,
                          ),
                          const SizedBox(height: 20),

                          Row(children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('ou', style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                          ]),
                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              ),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Déjà un compte ? ',
                                  style: TextStyle(color: Colors.white38, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: 'Se connecter',
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5)),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _GradientButton(
      {required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
              colors: [Color(0xFFFF8C00), Color(0xFFFF4500)]),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6)),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
