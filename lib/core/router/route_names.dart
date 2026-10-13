/// Centralized, type-safe route path constants for the entire app.
/// Use these everywhere instead of raw string literals.
class RouteNames {
  RouteNames._();

  // ── Top-level navigations ──────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String permissions = '/permissions';

  // ── Shell (bottom nav) routes ──────────────────────────────────────────────
  static const String home = '/home';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  // ── Feature routes ─────────────────────────────────────────────────────────
  static const String folders = '/folders';
  static const String whatsapp = '/whatsapp';
  static const String whatsappCategory = '/whatsapp/category';

  // ── Cleaning routes ────────────────────────────────────────────────────────
  static const String cleanPhoto = '/clean/photo';
  static const String cleanDocument = '/clean/document';
  static const String cleanAudio = '/clean/audio';
  static const String cleanGrid = '/clean/grid';

  // ── End-of-session ─────────────────────────────────────────────────────────
  static const String goodbye = '/goodbye';
}
