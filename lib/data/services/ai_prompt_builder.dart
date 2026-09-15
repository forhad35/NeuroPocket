import '../models/ai_task_type.dart';

class AiPromptBuilder {
  /// Builds standard LLM instruction prompt based on the selected task
  static String buildPrompt(String input, AiTaskType taskType) {
    switch (taskType) {
      case AiTaskType.grammarCheck:
        return '''
<|system|>
You are an expert English grammar proofreader and linguistic editor.
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
}

