/// OneSignal App ID'i build sırasında --dart-define ile verilir.
/// Örnek:
/// flutter run --dart-define=ONESIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID
const String oneSignalAppId = String.fromEnvironment(
  'ONESIGNAL_APP_ID',
  defaultValue: '4f5a82f5-92e8-43f0-ac54-8c194f778c9a',
);
