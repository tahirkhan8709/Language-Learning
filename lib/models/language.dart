/// The languages a user can learn.
enum Language {
  spanish('Spanish', 'Español', 'es', 'es-ES'),
  french('French', 'Français', 'fr', 'fr-FR'),
  german('German', 'Deutsch', 'de', 'de-DE');

  const Language(this.label, this.nativeName, this.code, this.ttsLocale);

  final String label;
  final String nativeName;
  final String code;

  /// Locale used by the text-to-speech engine.
  final String ttsLocale;
}
