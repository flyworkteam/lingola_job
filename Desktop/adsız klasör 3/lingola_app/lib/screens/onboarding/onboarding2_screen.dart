import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_primary_button.dart';
import 'package:lingola_app/src/widgets/dismiss_keyboard.dart';

/// Onboarding 2. sayfa: Meslek seçimi - "What is your profession?"
class Onboarding2Screen extends StatefulWidget {
  const Onboarding2Screen({super.key});

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> {
  String? _selectedProfession;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _professions = [
    _Profession(id: 'legal', title: 'Legal', description: 'Learn terminology for international trade', iconAsset: 'assets/icons/legal.svg'),
    _Profession(id: 'tech', title: 'Tech', description: 'Learn terminology for international trade', iconAsset: 'assets/icons/tech.svg'),
    _Profession(id: 'medicine', title: 'Medicine', description: 'Communicate effectively in clinical settings', iconAsset: 'assets/icons/medicine.svg'),
    _Profession(id: 'finance', title: 'Finance', description: 'Understand global financial markets', iconAsset: 'assets/icons/chart-histogram.svg'),
    _Profession(id: 'marketing', title: 'Marketing', description: 'Develop campaigns for global audiences', iconAsset: 'assets/icons/megaphone.svg'),
    _Profession(id: 'engineering', title: 'Engineering', description: 'Collaborate on complex technical projects', iconAsset: 'assets/icons/engineering.svg'),
    _Profession(id: 'education', title: 'Education', description: 'Teachers, students, academic life', iconAsset: 'assets/icons/education.svg'),
    _Profession(id: 'tourism', title: 'Tourism & Hospitality', description: 'Hotels, travel, guest communication', iconAsset: 'assets/icons/tourism.svg'),
    _Profession(id: 'sales', title: 'Sales', description: 'Negotiation, persuasion, customer handling', iconAsset: 'assets/icons/sales.svg'),
    _Profession(id: 'support', title: 'Customer Support', description: 'Solve issues, handle complaints', iconAsset: 'assets/icons/customer-support.svg'),
    _Profession(id: 'hr', title: 'Human Resources', description: 'Recruitment, Interviews, feedback', iconAsset: 'assets/icons/hr.svg'),
    _Profession(id: 'entrepreneurship', title: 'Entrepreneurship', description: 'Startup, pitch, product thinking', iconAsset: 'assets/icons/entrepreneurship.svg'),
    _Profession(id: 'logistics', title: 'Logistic & Trade', description: 'Import/export, supply chain', iconAsset: 'assets/icons/truck.svg'),
    _Profession(id: 'it', title: 'Information Technology Fields', description: 'Software, Ai, data science, cybersecurity and digital design', iconAsset: 'assets/icons/data.svg'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Profession> get _filteredProfessions {
    if (_searchQuery.isEmpty) return _professions;
    return _professions.where((p) =>
      p.title.toLowerCase().contains(_searchQuery) ||
      p.description.toLowerCase().contains(_searchQuery),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl + MediaQuery.paddingOf(context).top,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressIndicator(activeIndex: 0),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'What is your profession?',
                      style: AppTypography.onboardingTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.onboardingText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _SearchBar(controller: _searchController),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _filteredProfessions.length,
                      itemBuilder: (context, index) {
                        final p = _filteredProfessions[index];
                        final isSelected = _selectedProfession == p.id;
                        return _ProfessionCard(
                          profession: p,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedProfession = p.id),
                        );
                      },
                    ),
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    Opacity(
                      opacity: _selectedProfession != null ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: _selectedProfession == null,
                        child: AppPrimaryButton(
                          label: 'Next',
                          onPressed: () =>
                              Navigator.of(context).pushReplacementNamed('/onboarding3'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Profession {
  const _Profession({
    required this.id,
    required this.title,
    required this.description,
    this.iconAsset,
    this.icon,
  }) : assert(iconAsset != null || icon != null);
  final String id;
  final String title;
  final String description;
  final String? iconAsset;
  final IconData? icon;
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index == activeIndex;
        return Flexible(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(right: index < 4 ? AppSpacing.xs : 0),
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBrand : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: AppColors.outline),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search for a profession...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.outline,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: AppColors.onboardingText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionCard extends StatelessWidget {
  const _ProfessionCard({
    required this.profession,
    required this.isSelected,
    required this.onTap,
  });

  final _Profession profession;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.sm, 6, AppSpacing.sm, AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profession.iconAsset != null)
              SvgPicture.asset(
                profession.iconAsset!,
                width: 32,
                height: 32,
                colorFilter: isSelected
                    ? ColorFilter.mode(
                        AppColors.primaryBrand,
                        BlendMode.srcIn,
                      )
                    : null,
              )
            else
              Icon(
                profession.icon!,
                size: 32,
                color: isSelected
                    ? AppColors.primaryBrand
                    : AppColors.onboardingText,
              ),
            SizedBox(height: 4),
            Text(
              profession.title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onboardingText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              profession.description,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 16 / 13,
                color: const Color(0xFF000000),
              ),
              textAlign: TextAlign.left,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
