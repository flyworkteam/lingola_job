/// Onboarding akışından gelen seçimleri tutar.
/// Dil seçimi (onboarding4) Next ile sonraki ekrana ve uygulama genelinde kullanılabilir.
abstract final class OnboardingState {
  OnboardingState._();

  /// Kullanıcının "Which language would you like to learn?" ekranında seçtiği dil id'si.
  /// Örn: 'english', 'german', 'spanish'. onboarding4'te Next'e basıldığında set edilir.
  static String? selectedLanguageId;
}
