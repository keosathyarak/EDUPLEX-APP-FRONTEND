import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= BRAND HEADER =================
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(
                              isDark ? 0.4 : 0.05),
                        )
                      ],
                    ),
                    child: Image.asset(
                      "assets/icon/logologin.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About Eduplex",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ignite Your Learning Journey",
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 24),

              // ================= HERO =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF2B6CB0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Founder of EduPlex App",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Koeut Bora",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Senior mentor and lecturer specializing in modern design and digital learning solutions.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        "assets/images/teacher.jpg",
                        height: 150,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= PLATFORM ROW =================
              Row(
                children: const [
                  Expanded(child: PlatformCard(icon: Icons.android, label: "Android")),
                  SizedBox(width: 10),
                  Expanded(child: PlatformCard(icon: Icons.apple, label: "iOS")),
                  SizedBox(width: 10),
                  Expanded(child: PlatformCard(icon: Icons.language, label: "Web")),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                "Development Team",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // ================= TEAM GRID =================
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.48, // 🔥 FIXED (important)
                children: const [
                  TeamCard(
                    name: "Phorn Rong",
                    role: "Frontend Developer",
                    image: "assets/images/rong.jpg",
                    phone: "012 345 678",
                    email: "phornrong@gmail.com",
                  ),
                  TeamCard(
                    name: "Leng Saroth",
                    role: "Planning & Documentation",
                    image: "assets/images/roth.PNG",
                    phone: "012 345 678",
                    email: "lengsaroth@gmail.com",
                  ),
                  TeamCard(
                    name: "Din Rasin",
                    role: "Frontend Developer",
                    image: "assets/images/sin.jpg",
                    phone: "012 345 678",
                    email: "dinrasin@gmail.com",
                  ),
                  TeamCard(
                    name: "Keo Sathyarak",
                    role: "Flutter Developer",
                    image: "assets/images/rak.jpg",
                    phone: "081 451 884",
                    email: "keosthyarak@gmail.com",
                  ),
                  TeamCard(
                    name: "Khme Sopheanan",
                    role: "UX/UI Design",
                    image: "assets/images/nan.png",
                    phone: "012 345 678",
                    email: "keosopheanan@gmail.com",
                  ),
                  TeamCard(
                    name: "Kos Koeuk",
                    role: "System Analysis",
                    image: "assets/images/keuk.jpg",
                    phone: "012 345 678",
                    email: "koskoeuk@gmail.com",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PLATFORM CARD =================

class PlatformCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const PlatformCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.3 : 0.05),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ================= TEAM CARD =================

class TeamCard extends StatelessWidget {
  final String name;
  final String role;
  final String image;
  final String phone;
  final String email;

  const TeamCard({
    super.key,
    required this.name,
    required this.role,
    required this.image,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.3 : 0.05),
          )
        ],
      ),
      child: Column(
        children: [

          // 🔥 RESPONSIVE IMAGE (NO FIXED WIDTH)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            role,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone,
                  size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  phone,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),

        ],
      ),
    );

  }

}