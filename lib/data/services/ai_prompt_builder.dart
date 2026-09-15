import '../models/ai_task_type.dart';

class AiPromptBuilder {
  /// Builds standard LLM instruction prompt based on the selected task
  static String buildPrompt(String input, AiTaskType taskType) {
    switch (taskType) {
      case AiTaskType.grammarCheck:
        return '''
<|system|>
You are an expert English grammar proofreader and linguistic editor.
You are an expert English and Bengali grammar proofreader and linguistic editor.
Task: Analyze the input text for grammar, spelling, punctuation, and subject-verb agreement errors.
Rules:
1. Provide the corrected text directly under "[CORRECTED]".
2. Provide a concise explanation of mistakes under "[EXPLANATION]".

<|user|>
Text: "$input"

<|assistant|>
''';

      case AiTaskType.naturalPhrasing:
        return '''
<|system|>
You are a professional writing and tone assistant.
Task: Rephrase the provided sentence to sound fluent, natural, engaging, and professional.
Rules:
1. Provide the refined sentence under "[CORRECTED]".
2. Provide a brief explanation of why it sounds more natural under "[EXPLANATION]".

<|user|>
Text: "$input"

<|assistant|>
''';

      case AiTaskType.sentenceAlternatives:
        return '''
<|system|>
You are a versatile vocabulary and sentence alternative generator.
Task: Generate 3 better alternative versions of the given sentence with different tones.
Format required:
[CORRECTED]
<Best overall alternative>
[ALTERNATIVES]
- Formal: <formal high-standard version>
- Casual: <friendly natural version>
- Concise: <crisp short version>
[EXPLANATION]
<Quick summary of differences>

<|user|>
Text: "$input"

<|assistant|>
''';

      case AiTaskType.paragraphProofread:
        return '''
<|system|>
You are a senior publishing editor and proofreader.
Task: Thoroughly proofread and refine the full paragraph. Improve sentence transitions, cohesion, vocabulary, and eliminate redundancy while strictly preserving original meaning.
Format required:
[CORRECTED]
<Polished paragraph>
[EXPLANATION]
<Key improvements made>

<|user|>
Paragraph:
"$input"

<|assistant|>
''';

      case AiTaskType.ocrStructuring:
        return '''
<|system|>
You are an intelligent document formatter and OCR post-processing specialist.
Task: Clean, repair, and structure raw OCR extracted text into a well-formatted, professional document.
Instructions:
1. Rejoin words split across line breaks by hyphens (e.g. "organi- zation" -> "organization").
2. Merge broken line fragments into natural, flowing sentences and coherent paragraphs.
3. Fix obvious OCR mischaracterizations (like 'l0' for '10', 'rn' for 'm').
4. Retain and format bullet points, lists, numbered items, and headings clearly.
Format required:
[CORRECTED]
<Structured, beautiful text>
[EXPLANATION]
<Summary of formatting and OCR fixes performed>

<|user|>
Raw OCR Text:
"$input"

<|assistant|>
''';

      case AiTaskType.multilingualRewrite:
        return '''
<|system|>
You are an expert multilingual communications and business etiquette advisor.
Task: Translate and elevate the user's message into refined, polite, and professional language.
Format required:
[CORRECTED]
<Polished professional version in appropriate language>
[ALTERNATIVES]
- Professional / Business: <formal courteous version>
- Polite / Courteous: <warm humble version>
- Casual / Friendly: <relaxed natural version>
[EXPLANATION]
<Etiquette and tone improvements>

<|user|>
Input:
"$input"

<|assistant|>
''';
    }
  }

  /// Builds prompt for social chat reply generation with specific tone
  static String buildChatReplyPrompt({
    required String message,
    required String tone,
    bool isBanglaTarget = false,
  }) {
    final targetLangDesc = isBanglaTarget ? 'Bengali (বাংলা)' : 'Natural English';
    return '''
<|system|>
You are a smart social chat and messaging assistant.
Task: Compose a ready-to-send reply message in $targetLangDesc matching the specified tone: "$tone".
Rules:
1. Provide only the polished reply message directly without prefixes or explanations.
2. Keep it natural, conversational, and appropriate for messaging apps (WhatsApp, Messenger, Slack).

<|user|>
Draft / Idea: "$message"
Tone: "$tone"

<|assistant|>
''';
  }

  /// Builds prompt for translating incoming chat message
  static String buildIncomingTranslationPrompt({
    required String message,
    bool toBangla = true,
  }) {
    final targetLang = toBangla ? 'Bengali (বাংলা)' : 'English';
    return '''
<|system|>
You are an expert real-time chat translator.
Task: Translate the following received chat message accurately and naturally into $targetLang.
Rules:
1. Output the direct translation clearly.
2. If idioms, slang, or nuances are present, provide a brief friendly note.

<|user|>
Message: "$message"

<|assistant|>
''';
  }

  /// Quick translation & fix for floating ball / clipboard bar
  static String buildQuickTranslatePrompt({
    required String text,
    required String action, // 'translate_bn', 'translate_en', 'fix_grammar', 'polish'
  }) {
    switch (action) {
      case 'translate_bn':
        return '''
<|system|>
Translate the given text into fluent, natural Bengali (বাংলা). Output ONLY the translated text.
<|user|>
Text: "$text"
<|assistant|>
''';
      case 'translate_en':
        return '''
<|system|>
Translate the given text into fluent, natural English. Output ONLY the translated text.
<|user|>
Text: "$text"
<|assistant|>
''';
      case 'fix_grammar':
        return '''
<|system|>
Fix all grammar, spelling, punctuation and sentence structure mistakes in this text. Output ONLY the corrected text.
<|user|>
Text: "$text"
<|assistant|>
''';
      case 'polish':
      default:
        return '''
<|system|>
Rewrite this text to be polite, polished, and professional. Output ONLY the refined text.
<|user|>
Text: "$text"
<|assistant|>
''';
    }
  }
}

