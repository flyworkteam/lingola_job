#!/bin/bash
# Lingola App → GitHub (flyworkteam/lingola_job) - Detaylı commitlerle push
# Çalıştır: chmod +x push_to_github.sh && ./push_to_github.sh

set -e
cd "$(dirname "$0")"

do_commit() {
  local msg="$1"
  shift
  [ $# -gt 0 ] && git add "$@" 2>/dev/null || true
  if ! git diff --staged --quiet 2>/dev/null; then
    git commit -m "$msg"
    return 0
  fi
  return 1
}

echo "=== Lingola App - Detaylı Commit & Push ==="

# Eksik/bozuk .git varsa temizle
if [ -d .git ] && [ ! -f .git/HEAD ] 2>/dev/null; then
  rm -rf .git
fi

if [ ! -d .git ]; then
  echo "Git repo başlatılıyor..."
  git init
  git branch -M main
  echo "✓ Git repo başlatıldı"
fi


git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/flyworkteam/lingola_job.git

# 1. Proje config
do_commit "chore: Proje yapılandırması

- pubspec.yaml, pubspec.lock
- analysis_options.yaml
- .gitignore
- README.md, .metadata" .gitignore analysis_options.yaml pubspec.yaml pubspec.lock README.md .metadata 2>/dev/null || true

# 2. Tema
do_commit "feat: Tema (colors, typography, spacing, radius)" lib/src/theme/ 2>/dev/null || true

# 3. Widget'lar
do_commit "feat: Ortak widget'lar (AppCard, WordCard, BottomNavBar, vb.)" lib/src/widgets/ 2>/dev/null || true

# 4. State & main
do_commit "feat: State ve routing (SavedWordsStore, OnboardingState, main.dart)" lib/src/state/ lib/src/navigation/ lib/main.dart 2>/dev/null || true

# 5. Splash & Onboarding
do_commit "feat: Splash ve Onboarding ekranları" lib/screens/splash/ lib/screens/onboarding/ lib/screens/splash_screen.dart 2>/dev/null || true

# 6. Main, Home, Learn
do_commit "feat: Ana ekranlar (MainScreen, HomeScreen, LearnTab)

- Dil seçici bottom sheet
- Anasayfa/Learn geri dönüş navigasyonu
- Word Practice, Saved Word, Daily Test, Reading Test" lib/screens/main/ lib/screens/home/ lib/screens/learn/ 2>/dev/null || true

# 7. Library, Profile, Notifications, FAQ
do_commit "feat: Library, Profile, Notifications, FAQ

- ProfileSettings: dil, seviye, meslek, avatar
- Mavi gradient header" lib/screens/library/ lib/screens/profile/ lib/screens/notifications/ lib/screens/faq/ 2>/dev/null || true

# 8. Assets
do_commit "feat: Assets (ikonlar, bayraklar, görseller)" assets/ 2>/dev/null || true

# 9. Platform
do_commit "chore: Platform yapılandırmaları (Android, iOS, Web, Desktop)" android/ ios/ web/ linux/ macos/ windows/ 2>/dev/null || true

# 10. Kalan her şey
git add . 2>/dev/null || true
do_commit "chore: Test, IDE config ve diğer dosyalar" || true

echo ""
echo "=== Push: https://github.com/flyworkteam/lingola_job.git ==="
git push -u origin main --force

echo ""
echo "✓ Tamamlandı!"
