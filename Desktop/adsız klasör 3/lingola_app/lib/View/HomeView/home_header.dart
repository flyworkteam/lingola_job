part of 'home_view.dart';

extension HomeHeaderExtensions on _HomeScreenState {
  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
                itemCount: _HomeScreenState._languages.length,
                itemBuilder: (ctx, i) {
                  final lang = _HomeScreenState._languages[i];
                  return Material(
                    color: Colors.transparent,
                  child: InkWell(
                      onTap: () async {
                        final localeCode = _HomeScreenState._languageIdToLocale(lang.id);
                        if (localeCode != null) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(_HomeScreenState._keyProfileAppLanguage, lang.id);
                          if (!ctx.mounted) return;
                          await ctx.setLocale(Locale(localeCode));
                          if (!mounted) return;
                          setState(() => _selectedLanguageId = lang.id);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 30,
                              child: lang.flagAsset.toLowerCase().endsWith('.png')
                                  ? Image.asset(lang.flagAsset, width: 40, height: 30, fit: BoxFit.contain)
                                  : SvgPicture.asset(
                                      lang.flagAsset,
                                      width: 40,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                'languages.${lang.id}'.tr(),
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: _avatarFile != null
                        ? Image.file(
                            _avatarFile!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/dummy/image 2.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                AppSpacing.md.width,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isPremium
                        ? const Color(0xFFF8F9FA)
                        : const Color(0xFFD9D9D9).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: widget.isPremium
                        ? [
                            BoxShadow(
                              color: const Color(0xFF021B79).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.isPremium
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/Vector.svg',
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'home.premium_badge'.tr(),
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'home.free_badge'.tr(),
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFF5C5C5C),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
                const Spacer(),
                AppIconButton(
                  onTap: () {
                    context.push(
                      AppPaths.notifications,
                      extra: NotificationsRouteArgs(isPremium: widget.isPremium),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/frame_notification.svg',
                    width: 23,
                    height: 23,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.xs, 0, AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.hello_user'.tr(args: [widget.userName.split(' ').first]),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'home.continue_to_language'.tr(
                          args: ['languages.${_selectedLanguage.id}'.tr()],
                        ),
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showLanguageSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCFCFCF),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 13,
                            height: 13,
                            child: _selectedLanguage.flagAsset.toLowerCase().endsWith('.png')
                                ? Image.asset(_selectedLanguage.flagAsset, fit: BoxFit.contain)
                                : SvgPicture.asset(
                                    _selectedLanguage.flagAsset,
                                    width: 13,
                                    height: 13,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'languages.${_selectedLanguage.id}'.tr(),
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
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

