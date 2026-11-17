import '../models/language.dart';
import '../models/lesson_category.dart';
import '../models/lesson_item.dart';

/// All learning content, stored locally in the app (no internet needed).
///
/// Each row is: [english, target language, phonetic, note].
/// IDs are built from language + category + position, so do not reorder
/// existing rows (progress is saved by ID). Add new rows at the END.
class Content {
  Content._();

  static List<LessonItem> forLanguage(Language language) =>
      _all[language] ?? const [];

  static List<LessonItem> forCategory(
    Language language,
    LessonCategory category,
  ) =>
      forLanguage(language).where((i) => i.category == category).toList();

  static List<LessonItem> _rows(
    Language language,
    LessonCategory category,
    List<List<String>> rows,
  ) {
    return [
      for (var i = 0; i < rows.length; i++)
        LessonItem(
          id: '${language.code}-${category.name}-${i + 1}',
          language: language,
          category: category,
          english: rows[i][0],
          target: rows[i][1],
          phonetic: rows[i][2],
          note: rows[i][3],
        ),
    ];
  }

  static final Map<Language, List<LessonItem>> _all = {
    // ------------------------------------------------------------ SPANISH
    Language.spanish: [
      ..._rows(Language.spanish, LessonCategory.vocabulary, [
        ['Water', 'El agua', 'el AH-gwah', "Feminine noun, but it takes 'el' for easier sound."],
        ['Bread', 'El pan', 'el PAHN', 'A staple at almost every meal.'],
        ['House', 'La casa', 'lah KAH-sah', "Also means 'home'."],
        ['Friend', 'El amigo', 'el ah-MEE-goh', "Use 'la amiga' for a female friend."],
        ['Book', 'El libro', 'el LEE-broh', "Not 'library'. That is 'la biblioteca'."],
        ['Cat', 'El gato', 'el GAH-toh', "Use 'la gata' for a female cat."],
        ['Dog', 'El perro', 'el PEH-rroh', "Roll the double 'rr'. Female: 'la perra'."],
        ['School', 'La escuela', 'lah es-KWEH-lah', 'Feminine noun.'],
        ['Milk', 'La leche', 'lah LEH-cheh', "'ch' sounds like in 'cheese'."],
        ['Street', 'La calle', 'lah KAH-yeh', "'ll' sounds like 'y' in 'yes'."],
      ]),
      ..._rows(Language.spanish, LessonCategory.phrases, [
        ['Hello', 'Hola', 'OH-lah', "The 'h' is silent."],
        ['Good morning', 'Buenos días', 'BWEH-nohs DEE-ahs', 'Used until about midday.'],
        ['Thank you very much', 'Muchas gracias', 'MOO-chahs GRAH-see-ahs', "In Spain 'c' in 'gracias' sounds like 'th'."],
        ['Please', 'Por favor', 'pohr fah-VOHR', 'Also used when asking for something politely.'],
        ['How are you?', '¿Cómo estás?', 'KOH-moh es-TAHS', "Formal: '¿Cómo está usted?'"],
        ["I'm fine", 'Estoy bien', 'es-TOY bee-EN', 'Add ", ¿y tú?" to ask back.'],
        ['What is your name?', '¿Cómo te llamas?', 'KOH-moh teh YAH-mahs', 'Literally: how do you call yourself?'],
        ["I don't understand", 'No entiendo', 'noh en-tee-EN-doh', 'Very useful when learning!'],
      ]),
      ..._rows(Language.spanish, LessonCategory.grammar, [
        ['I am a student.', 'Soy estudiante.', 'soy es-too-dee-AHN-teh', "'Soy' (ser) = 'I am' for identity, job and origin."],
        ['I am tired.', 'Estoy cansado.', 'es-TOY kahn-SAH-doh', "'Estoy' (estar) is for feelings and temporary states. Female: 'cansada'."],
        ['The book is red.', 'El libro es rojo.', 'el LEE-broh es ROH-hoh', 'Adjectives usually come AFTER the noun and match its gender.'],
        ['I have a dog.', 'Tengo un perro.', 'TEN-goh oon PEH-rroh', "'Tener' (to have): yo tengo, tú tienes, él tiene."],
        ['I want water.', 'Quiero agua.', 'kee-EH-roh AH-gwah', "'Querer' (to want): yo quiero, tú quieres."],
        ['We speak Spanish.', 'Hablamos español.', 'ah-BLAH-mohs es-pah-NYOL', "-ar verbs: the 'we' form ends in -amos."],
      ]),
    ],

    // ------------------------------------------------------------- FRENCH
    Language.french: [
      ..._rows(Language.french, LessonCategory.vocabulary, [
        ['Water', "L'eau", 'LOH', "Written 'eau' but pronounced 'oh'. Feminine."],
        ['Bread', 'Le pain', 'luh PAN', "The 'ain' is a nasal sound (do not say the 'n')."],
        ['House', 'La maison', 'lah meh-ZOHN', "Nasal 'on' at the end. Feminine."],
        ['Friend', "L'ami", 'lah-MEE', "Female friend: 'l'amie' (same sound)."],
        ['Book', 'Le livre', 'luh LEE-vruh', "Not 'library'. That is 'la bibliothèque'."],
        ['Cat', 'Le chat', 'luh SHAH', "The final 't' is silent."],
        ['Dog', 'Le chien', 'luh shee-AN', 'Nasal ending.'],
        ['School', "L'école", 'lay-KOHL', 'Feminine noun.'],
        ['Milk', 'Le lait', 'luh LEH', "The final 't' is silent."],
        ['Street', 'La rue', 'lah REW', "Say 'ee' with your lips rounded for the French 'u'."],
      ]),
      ..._rows(Language.french, LessonCategory.phrases, [
        ['Hello', 'Bonjour', 'bohn-ZHOOR', "Literally 'good day'. Use it until the evening."],
        ['Good evening', 'Bonsoir', 'bohn-SWAHR', 'Used from late afternoon onwards.'],
        ['Thank you very much', 'Merci beaucoup', 'mehr-SEE boh-KOO', 'Very common and polite.'],
        ['Please', "S'il vous plaît", 'seel voo PLEH', "Informal: 's'il te plaît'."],
        ['How are you?', 'Comment allez-vous ?', 'koh-mahn tah-lay-VOO', "Informal: 'Ça va ?'"],
        ["I'm fine", 'Je vais bien', 'zhuh veh bee-AN', "Add 'merci' to be polite."],
        ['What is your name?', "Comment tu t'appelles ?", 'koh-mahn too tah-PEL', "Formal: 'Comment vous appelez-vous ?'"],
        ["I don't understand", 'Je ne comprends pas', 'zhuh nuh kohm-PRAHN pah', 'Very useful when learning!'],
      ]),
      ..._rows(Language.french, LessonCategory.grammar, [
        ['I am a student.', 'Je suis étudiant.', 'zhuh swee ay-too-dee-AHN', "'Être' (to be): je suis, tu es, il est. Female: 'étudiante'."],
        ['I have a cat.', "J'ai un chat.", 'zhay uhn SHAH', "'Avoir' (to have): j'ai, tu as, il a."],
        ['The book is red.', 'Le livre est rouge.', 'luh LEE-vruh eh ROOZH', 'Most adjectives come AFTER the noun.'],
        ['I speak French.', 'Je parle français.', 'zhuh PARL frahn-SEH', "-er verbs: 'je' form ends in -e."],
        ['I want water.', "Je veux de l'eau.", 'zhuh VUH duh LOH', "'Vouloir' (to want). Politer: 'Je voudrais'."],
        ['I am not tired.', 'Je ne suis pas fatigué.', 'zhuh nuh swee pah fah-tee-GAY', "Negation wraps the verb: 'ne ... pas'."],
      ]),
    ],

    // ------------------------------------------------------------- GERMAN
    Language.german: [
      ..._rows(Language.german, LessonCategory.vocabulary, [
        ['Water', 'Das Wasser', 'dahs VAH-ser', "Neuter noun, so it uses 'das'."],
        ['Bread', 'Das Brot', 'dahs BROHT', 'Neuter noun.'],
        ['House', 'Das Haus', 'dahs HOWS', "'au' sounds like 'ow' in 'cow'."],
        ['Friend', 'Der Freund', 'dehr FROYNT', "Masculine. Female friend: 'die Freundin'."],
        ['Book', 'Das Buch', 'dahs BOOKH', "'ch' is a soft sound from the throat."],
        ['Cat', 'Die Katze', 'dee KAHT-seh', "Feminine noun. 'tz' sounds like 'ts'."],
        ['Dog', 'Der Hund', 'dehr HOONT', "Masculine. Final 'd' sounds like 't'."],
        ['School', 'Die Schule', 'dee SHOO-leh', "'sch' sounds like 'sh'."],
        ['Milk', 'Die Milch', 'dee MILKH', 'Feminine noun.'],
        ['Street', 'Die Straße', 'dee SHTRAH-seh', "'ß' sounds like a double 's'."],
      ]),
      ..._rows(Language.german, LessonCategory.phrases, [
        ['Hello', 'Hallo', 'HAH-loh', 'Works in every situation.'],
        ['Good morning', 'Guten Morgen', 'GOO-ten MOR-gen', 'Used until about midday.'],
        ['Thank you very much', 'Vielen Dank', 'FEE-len DAHNK', "'V' sounds like 'f' in German."],
        ['Please', 'Bitte', 'BIT-teh', "Also means 'you're welcome'."],
        ['How are you?', "Wie geht's?", 'vee GAYTS', "Formal: 'Wie geht es Ihnen?'"],
        ["I'm fine", 'Mir geht es gut', 'meer gayt ess GOOT', "Short version: 'Gut, danke.'"],
        ['What is your name?', 'Wie heißt du?', 'vee HYST doo', "Formal: 'Wie heißen Sie?'"],
        ["I don't understand", 'Ich verstehe nicht', 'ikh fer-SHTAY-eh nikht', 'Very useful when learning!'],
      ]),
      ..._rows(Language.german, LessonCategory.grammar, [
        ['I am a student.', 'Ich bin Student.', 'ikh bin shtoo-DENT', "'Sein' (to be): ich bin, du bist, er ist. Female: 'Studentin'."],
        ['I have a dog.', 'Ich habe einen Hund.', 'ikh HAH-beh EYE-nen HOONT', "Masculine objects change 'ein' to 'einen'."],
        ['The book is red.', 'Das Buch ist rot.', 'dahs BOOKH ist ROHT', "Every noun has a gender: der, die or das."],
        ['I speak German.', 'Ich spreche Deutsch.', 'ikh SHPREKH-eh DOYTCH', "'Sprechen' changes: ich spreche, du sprichst."],
        ['I am not tired.', 'Ich bin nicht müde.', 'ikh bin nikht MEW-deh', "'Nicht' comes after the verb to negate it."],
        ['We eat bread.', 'Wir essen Brot.', 'veer ESS-en BROHT', "'Wir' (we) uses the basic verb form ending in -en."],
      ]),
    ],
  };
}
