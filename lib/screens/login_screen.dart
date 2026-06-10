import 'package:flutter/material.dart';
import '../theme.dart';
import 'biblioteca_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;

  // ── Validación con credenciales de fantasía ──────────────────────────────
  void _onLogin() {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnack("Completá los dos campos.");
      return;
    }

    if (email == "gamer@cripta.com" && pass == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BibliotecaScreen()),
      );
    } else {
      _showSnack("Credenciales incorrectas. Probá: gamer@cripta.com / 1234");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accentOff,
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / título
                const Icon(Icons.sports_esports,
                    size: 80, color: AppColors.accent),
                const SizedBox(height: 12),
                const Text("LA CRIPTA\nGAMER",
                    style: AppStyles.title,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Campo email
                _buildInput(
                  controller: _emailCtrl,
                  hint: "CORREO ELECTRÓNICO",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Campo contraseña
                _buildInput(
                  controller: _passCtrl,
                  hint: "CONTRASEÑA",
                  icon: Icons.lock_outline,
                  obscure: _obscurePass,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.fgDim,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                const SizedBox(height: 24),

                // Botón iniciar sesión
                _buildButton("INICIAR SESIÓN", _onLogin),
                const SizedBox(height: 20),

                // Separador
                _buildSeparator(),
                const SizedBox(height: 20),

                // Botones sociales
                _buildButton("Continuar con Google", () {}),
                const SizedBox(height: 10),
                _buildButton("Continuar con Apple", () {}),
                const SizedBox(height: 10),
                _buildButton("Continuar con Facebook", () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers de widgets ────────────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.fgDim, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.fgDim, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.fg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(text, style: AppStyles.label),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.fgDim)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("O", style: TextStyle(color: AppColors.fgDim)),
        ),
        const Expanded(child: Divider(color: AppColors.fgDim)),
      ],
    );
  }
}