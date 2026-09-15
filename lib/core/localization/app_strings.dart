import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/language/language_bloc.dart';
import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  static AppStrings of(BuildContext context) {
    try {
      final state = context.watch<LanguageBloc>().state;
      return AppStrings(state.language);
    } catch (_) {
      return const AppStrings(AppLanguage.bangla);
    }
  }

  bool get isBangla => language == AppLanguage.bangla;

  // App General
  String get appTitle => isBangla ? 'NeuroPocket - অফলাইন এআই' : 'NeuroPocket - Offline AI';
  String get onDeviceBadge => isBangla ? '১০০% অন-ডিভাইস' : '100% On-Device';
  String get offlineMode => isBangla ? 'অফলাইন মোড' : 'Offline Mode';
  String get offlineReadyBadge => isBangla ? '১০০% অফলাইন এআই প্রস্তুত' : '100% Offline AI Ready';
  String get heroStatus => offlineReadyBadge;
  String get modelsButton => isBangla ? 'মডেল' : 'Models';
  String get languageTitle => isBangla ? 'অ্যাপের ভাষা' : 'App Language';
  String get languageSubtitle => isBangla
      ? 'বাংলা ও ইংরেজি ভাষার মধ্যে নির্বাচন করুন'
      : 'Choose between Bengali and English language';
  String get switchLanguage => isBangla ? 'English এ পরিবর্তন করুন' : 'Switch to বাংলা';

  // Home Screen Sections
  String get toolsSectionTitle => isBangla ? 'এআই রাইটিং টুলস:' : 'AI Writing Tools:';
  String get chatCardTitle => isBangla ? 'অফলাইন এআই চ্যাট' : 'Offline AI Chat';
  String get chatCardDesc => isBangla
      ? 'মডেলের সাথে যেকোনো বিষয়ে বাংলা ও ইংরেজিতে প্রশ্ন-উত্তর ও কথোপকথন করুন'
      : 'Chat and have fluent conversations with on-device AI in English and Bengali';
  String get ocrCardTitle => isBangla ? 'ওসিআর ডকুমেন্ট স্ক্যানার' : 'OCR Document Scanner';
  String get ocrCardDesc => isBangla
      ? 'ছবি থেকে টেক্সট এক্সট্রাক্ট করে অফলাইনে এআই দিয়ে ফরম্যাট করুন'
      : 'Extract text from images and format with offline AI';
  String get quickExamplesTitle => isBangla ? 'দ্রুত টেস্ট করার জন্য উদাহরণ:' : 'Quick Test Examples:';
  String get grammarExampleTitle => isBangla ? 'গ্রামার ফিক্স উদাহরণ' : 'Grammar Fix Example';
  String get altExampleTitle => isBangla ? 'বিকল্প বাক্যের উদাহরণ' : 'Alternative Suggestions Example';
  String get naturalExampleTitle => isBangla ? 'ন্যাচারাল ফ্রেজিং উদাহরণ' : 'Natural Phrasing Example';
  String get multilingualExampleTitle => isBangla ? 'ভদ্র ও প্রফেশনাল রি-রাইট' : 'Polite & Professional Rewrite';
  String get ocrCleanExampleTitle => isBangla ? 'ওসিআর ক্লিন ও ফরম্যাটিং' : 'OCR Cleanup & Formatting';

  // Navigation
  String get navEditor => isBangla ? 'এআই রাইটার' : 'AI Writer';
  String get navChat => isBangla ? 'অফলাইন চ্যাট' : 'Offline Chat';
  String get navOcr => isBangla ? 'ওসিআর স্ক্যানার' : 'OCR Scanner';
  String get navSettings => isBangla ? 'মডেল ও সেটিংস' : 'Models & Settings';

  // AI Editor
  String get editorTitle => isBangla ? 'স্মার্ট এআই রাইটিং অ্যাসিস্ট্যান্ট' : 'Smart AI Writing Assistant';
  String get editorSubtitle => isBangla
      ? 'অফলাইনে ব্যাকরণ ঠিক করুন, বাক্য সুন্দর করুন ও অনুবাদ করুন'
      : 'Proofread grammar, refine tone & translate completely offline';
  String get inputPlaceholder => isBangla
      ? 'এখানে আপনার বাক্য বা প্যারাগ্রাফ লিখুন বা পেস্ট করুন...'
      : 'Type or paste your sentence or paragraph here...';
  String get buttonAnalyze => isBangla ? 'প্রসেস ও জেনারেট করুন' : 'Analyze & Generate';
  String get processingAi => isBangla ? 'অন-ডিভাইস এআই প্রসেসিং হচ্ছে...' : 'Processing with on-device AI...';
  String get analyzingText => isBangla ? 'অন-ডিভাইস এআই মডেল টেক্সট অ্যানালাইসিস করছে...' : 'Analyzing text with on-device AI model...';
  String get resultTitle => isBangla ? 'এআই ফলাফল ও সংশোধন' : 'AI Results & Improvements';
  String get originalText => isBangla ? 'মূল টেক্সট' : 'Original Text';
  String get correctedText => isBangla ? 'সংশোধিত টেক্সট' : 'Corrected Text';
  String get explanation => isBangla ? 'ব্যাখ্যা ও কারণ' : 'Explanation';
  String get alternatives => isBangla ? 'বিকল্প বাক্যসমূহ' : 'Alternative Versions';
  String get copy => isBangla ? 'কপি করুন' : 'Copy';
  String get copied => isBangla ? 'ক্লিপবোর্ডে কপি করা হয়েছে!' : 'Copied to clipboard!';
  String get clear => isBangla ? 'মুছুন' : 'Clear';
  String get selectTask => isBangla ? 'কাজের ধরণ নির্বাচন করুন:' : 'Select Task Type:';
  String get paste => isBangla ? 'পেস্ট' : 'Paste';
  String get textPasted => isBangla ? 'টেক্সট পেস্ট করা হয়েছে!' : 'Text pasted!';
  String get textFromImageAdded => isBangla ? 'ছবি থেকে টেক্সট সফলভাবে এডিটরে আনা হয়েছে!' : 'Text from image added to editor!';
  String get applyToEditor => isBangla ? 'এডিটরে প্রয়োগ করুন' : 'Apply to Editor';
  String get appliedToEditor => isBangla ? 'ইনপুটে নতুন টেক্সট যুক্ত করা হয়েছে!' : 'Text applied to input editor!';
  String get showDiff => isBangla ? 'পার্থক্য (Diff) দেখুন' : 'Show Word Diff';
  String wordCountLabel(int words, int chars) => isBangla ? '$words শব্দ • $chars অক্ষর' : '$words words • $chars chars';

  // Task Type Names
  String get taskGrammarCheck => isBangla ? 'গ্রামার চেক' : 'Grammar Fix';
  String get taskNaturalPhrasing => isBangla ? 'ন্যাচারাল ফ্রেজিং' : 'Natural Tone';
  String get taskAlternatives => isBangla ? 'বিকল্প বাক্য' : '3 Alternatives';
  String get taskParagraphProofread => isBangla ? 'প্যারাগ্রাফ প্রুফরিড' : 'Proofreading';
  String get taskOcrStructuring => isBangla ? 'ওসিআর টেক্সট ক্লিন' : 'Doc Structure';
  String get taskMultilingualRewrite => isBangla ? 'পেশাদার রি-রাইট' : 'Polite / Business';

  // Task Descriptions
  String get taskGrammarDesc => isBangla
      ? 'ইংরেজি ও বাংলা বাক্যের ব্যাকরণ, বানান ও যতিচিহ্ন ঠিক করে।'
      : 'Fixes grammar, spelling, tense, and punctuation errors.';
  String get taskNaturalDesc => isBangla
      ? 'অস্বাভাবিক বা ভাঙা বাক্যকে প্রফেশনাল ও সাবলীল বানায়।'
      : 'Transforms awkward sentences into smooth, natural phrasing.';
  String get taskAlternativesDesc => isBangla
      ? 'ফরমাল, ক্যাজুয়াল ও সংক্ষিপ্ত ৩টি ভিন্ন ধরণের বিকল্প তৈরি করে।'
      : 'Generates Formal, Casual, and Concise alternative phrasing.';
  String get taskParagraphDesc => isBangla
      ? 'সম্পূর্ণ প্যারাগ্রাফের অর্থ ঠিক রেখে কোহিশন ও ফ্লো বাড়ায়।'
      : 'Enhances flow, cohesion, and transitions of entire paragraphs.';
  String get taskOcrDesc => isBangla
      ? 'ভাঙা লাইন জোড়া লাগিয়ে ও নয়েজ দূর করে ক্লিন ডকুমেন্ট বানায়।'
      : 'Repairs split words, broken lines, and formats scanned text.';
  String get taskMultilingualDesc => isBangla
      ? 'রুচিশীল ও পেশাদার কর্পোরেট বা বিনয়ী ভাষায় রূপান্তর করে।'
      : 'Rewrites text into courteous, polished, and professional tone.';

  // Chat View
  String get chatTitle => isBangla ? 'অফলাইন এআই চ্যাট' : 'Offline AI Chat';
  String get chatPlaceholder => isBangla ? 'এআই-কে প্রশ্ন করুন বা কিছু লিখুন...' : 'Ask AI or type a sentence...';
  String get chatGreeting => isBangla
      ? 'আমি আপনার স্মার্ট অন-ডিভাইস এআই সহকারী (NeuroPocket AI)।\n\nআপনি আমাকে যেকোনো প্রশ্ন করতে পারেন, কোনো টেক্সট কারেক্ট বা রিরাইট করতে বলতে পারেন, অথবা বাংলা ও ইংরেজিতে যেকোনো বিষয়ে সম্পূর্ণ অফলাইনে কথোপকথন করতে পারেন!'
      : 'I am your smart NeuroPocket on-device AI assistant.\n\nYou can ask me questions, request grammar corrections, translate text, or have a fluent conversation in English and Bengali completely offline!';
  String get quickPrompt1 => isBangla
      ? 'ম্যানেজারকে ছুটির জন্য একটি ভদ্র ইমেইল লিখে দাও'
      : 'Write a polite leave email to my manager';
  String get quickPrompt2 => isBangla
      ? 'কীভাবে আমার ইংরেজি লেখাকে আরও সাবলীল করব?'
      : 'How can I make my English writing natural?';
  String get quickPrompt3 => isBangla
      ? 'আমি ভালো আছি এটা ইংরেজিতে অনুবাদ করো'
      : 'Translate "ami valo achi" to English';
  String get clearChat => isBangla ? 'চ্যাট ক্লিয়ার করুন' : 'Clear Chat';
  String get clearConfirmTitle => isBangla ? 'কথোপকথন মুছে ফেলবেন?' : 'Clear Conversation?';
  String get clearConfirmBody => isBangla
      ? 'আপনার বর্তমান চ্যাট হিস্ট্রি মুছে নতুন সেশন শুরু হবে।'
      : 'Your current chat history will be cleared and a new session will begin.';
  String get yesClear => isBangla ? 'হ্যাঁ, মুছে ফেলুন' : 'Clear';
  String get cancelAction => isBangla ? 'বাতিল' : 'Cancel';
  String get thinkingOffline => isBangla ? 'অন-ডিভাইসে ভাবছে...' : 'Thinking offline...';
  String get sendMessageTooltip => isBangla ? 'মেসেজ পাঠান' : 'Send Message';

  // OCR View
  String get ocrTitle => isBangla ? 'ওসিআর ডকুমেন্ট স্ক্যানার' : 'OCR Document Scanner';
  String get ocrSubtitle => isBangla
      ? 'ছবি থেকে টেক্সট এক্সট্রাক্ট করে অফলাইনে এআই দিয়ে ফরম্যাট করুন'
      : 'Extract text from images and format with offline AI';
  String get offlineOcrHeader => isBangla ? '১০০% অফলাইন টেক্সট রিকগনিশন' : '100% Offline OCR Recognition';
  String get scanCamera => isBangla ? 'ক্যামেরা স্ক্যান' : 'Camera Scan';
  String get pickGallery => isBangla ? 'গ্যালারি থেকে ছবি' : 'Gallery Image';
  String get recognizedText => isBangla ? 'শনাক্তকৃত টেক্সট' : 'Recognized Text';
  String get noTextFound => isBangla
      ? 'কোনো ছবি নির্বাচন করা হয়নি। ক্যামেরা বা গ্যালারি থেকে ছবি নিন।'
      : 'No image selected. Capture from camera or pick from gallery.';
  String get scanningImage => isBangla ? 'ছবি থেকে অফলাইনে লেখা স্ক্যান করা হচ্ছে...' : 'Scanning text offline from image...';
  String get noOcrText => isBangla
      ? 'ছবিতে কোনো স্পষ্ট লেখা পাওয়া যায়নি। লেখা সম্বলিত ছবি দিন।'
      : 'No clear text detected in image. Please provide a clear image.';
  String get sendToEditor => isBangla ? 'এআই এডিটরে পাঠান' : 'Send to AI Editor';
  String get cleanWithAi => isBangla ? '⚡ AI দিয়ে টেক্সট সাজান ও ক্লিন করুন' : '⚡ Clean & Structure with AI';
  String get fixWithAiTitle => isBangla ? 'AI দিয়ে ঠিক করুন (এক ক্লিকে এডিটর খুলুন):' : 'Fix with AI (Open in Editor):';

  // Model Manager & Settings
  String get modelsTitle => isBangla ? 'অন-ডিভাইস লোকাল GGUF মডেলসমূহ' : 'On-Device Local GGUF Models';
  String get refreshModelStatus => isBangla ? 'মডেল স্ট্যাটাস রিফ্রেশ' : 'Refresh Model Status';
  String get modelLabel => isBangla ? 'মডেল:' : 'Model:';
  String get geminiTitle => isBangla ? 'গুগল জেমিনি ক্লাউড এআই (ঐচ্ছিক)' : 'Google Gemini Cloud AI (Optional)';
  String get geminiDesc => isBangla
      ? 'ক্লাউড সুপার-ইন্টেলিজেন্স ব্যবহারের জন্য আপনার ফ্রি জেমিনি এপিআই কি দিন।'
      : 'Add your free Gemini API key to use cloud super-intelligence alongside offline models.';
  String get geminiKeyLabel => isBangla ? 'জেমিনি এপিআই কী (API Key)' : 'Gemini API Key';
  String get saveKey => isBangla ? 'কী সংরক্ষণ করুন' : 'Save Key';
  String get testConnection => isBangla ? 'সংযোগ টেস্ট করুন' : 'Test Connection';
  String get testInferenceTitle => isBangla ? 'অন-ডিভাইস লাইভ টেস্ট' : 'Live On-Device GGUF Test';
  String get activeModelLabel => isBangla ? 'বর্তমান সক্রিয় মডেল:' : 'Active Model:';
  String get testPromptLabel => isBangla ? 'টেস্ট প্রম্পট' : 'Test Prompt';
  String get runTest => isBangla ? 'অফলাইন টেস্ট চালান' : 'Run Offline Test';
  String get bestForTitle => isBangla ? 'কোন কাজের জন্য সেরা:' : 'Best For:';
  String get download => isBangla ? 'ডাউনলোড' : 'Download';
  String get downloading => isBangla ? 'ডাউনলোড হচ্ছে...' : 'Downloading...';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get setActive => isBangla ? 'সক্রিয় করুন' : 'Set as Active';
  String get active => isBangla ? 'সক্রিয় (ACTIVE)' : 'ACTIVE';
  String get delete => isBangla ? 'মুছে ফেলুন' : 'Delete';
  String get deleteConfirm => isBangla
      ? 'আপনি কি নিশ্চিত যে এই মডেলটি ডিভাইস থেকে মুছে ফেলতে চান?'
      : 'Are you sure you want to delete this model from disk?';
}

