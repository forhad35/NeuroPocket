import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/model_status.dart';
import '../../data/services/ai_config_service.dart';
import '../../data/services/gemini_ai_service.dart';
import '../blocs/model_manager/model_manager_bloc.dart';
import '../blocs/model_manager/model_manager_event.dart';
import '../blocs/model_manager/model_manager_state.dart';
import '../widgets/language_switch_button.dart';

class ModelManagerView extends StatefulWidget {
  const ModelManagerView({super.key});

  @override
  State<ModelManagerView> createState() => _ModelManagerViewState();
}

class _ModelManagerViewState extends State<ModelManagerView> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _testPromptController = TextEditingController(
    text: 'What are the main benefits of on-device AI?',
  );
  String _selectedGeminiModel = 'gemini-1.5-flash';
  bool _obscureKey = true;
  bool _isTestingKey = false;
  String? _testResult;
  bool _isTestSuccess = false;

  final List<String> _geminiModels = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
    context.read<ModelManagerBloc>().add(const CheckModelsStatusEvent());
  }

  Future<void> _loadConfig() async {
    final key = await AiConfigService.getApiKey();
    final model = await AiConfigService.getModelName();
    if (mounted) {
      setState(() {
        _apiKeyController.text = key ?? '';
        _selectedGeminiModel = model;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _testPromptController.dispose();
    super.dispose();
  }

  Future<void> _saveGeminiConfig(AppStrings strings) async {
    final key = _apiKeyController.text.trim();
    await AiConfigService.saveApiKey(key);
    await AiConfigService.saveModelName(_selectedGeminiModel);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(key.isNotEmpty
              ? (strings.isBangla
                  ? 'জেমিনি কনফিগারেশন সফলভাবে সেভ করা হয়েছে!'
                  : 'Gemini configuration saved successfully!')
              : (strings.isBangla
                  ? 'API Key মুছে ফেলা হয়েছে (অফলাইন GGUF মোড অ্যাক্টিভ)'
                  : 'API Key removed (Offline GGUF mode active)')),
          backgroundColor: AppConstants.accentColor,
        ),
      );
    }
  }

  Future<void> _testGeminiKey(AppStrings strings) async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = strings.isBangla
            ? '⚠️ টেস্ট করার জন্য অনুগ্রহ করে একটি API Key লিখুন।'
            : '⚠️ Please enter an API Key to test.';
        _isTestSuccess = false;
      });
      return;
    }

    setState(() {
      _isTestingKey = true;
      _testResult = null;
    });

    try {
      final gemini = GeminiAiService(
        customApiKey: key,
        customModelName: _selectedGeminiModel,
      );

      final reply = await gemini.generateText(
        'Respond in 1 short sentence: Confirm you are connected and ready.',
      );

      setState(() {
        _isTestingKey = false;
        _isTestSuccess = true;
        _testResult = '✅ ${strings.isBangla ? 'সফল! মডেল রেসপন্স' : 'Success! Model Response'}:\n"${reply?.trim()}"';
      });
    } catch (e) {
      setState(() {
        _isTestingKey = false;
        _isTestSuccess = false;
        _testResult = '❌ ${strings.isBangla ? 'সংযোগ ব্যর্থ হয়েছে' : 'Connection failed'}: $e';
      });
    }
  }

  void _testOnDeviceLlm() {
    final prompt = _testPromptController.text.trim();
    if (prompt.isEmpty) return;
    context.read<ModelManagerBloc>().add(TestModelInferenceEvent(prompt: prompt));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.navSettings),
        actions: [
          const LanguageSwitchButton(compact: true),
        ],
      ),
      body: BlocConsumer<ModelManagerBloc, ModelManagerState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppConstants.accentColor,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppConstants.errorColor,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language Selection Card
              _buildLanguageCard(theme, strings),

              const SizedBox(height: 16),

              // Real On-Device GGUF Test Card
              _buildOnDeviceTestCard(theme, state, strings),

              const SizedBox(height: 20),

              // Local GGUF Models Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.modelsTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Refresh Model Status',
                    onPressed: () {
                      context.read<ModelManagerBloc>().add(const CheckModelsStatusEvent());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Models List
              ...state.availableModels.map((model) => _buildModelCard(theme, state, model, strings)),

              const SizedBox(height: 20),

              // Real Gemini AI Model Card
              _buildGeminiCard(theme, strings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageCard(ThemeData theme, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withAlpha(80),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.languageTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      strings.isBangla
                          ? 'বাংলা ও ইংরেজি ভাষার মধ্যে নির্বাচন করুন'
                          : 'Choose between Bengali and English language',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const LanguageSwitchButton(compact: false),
        ],
      ),
    );
  }

  Widget _buildOnDeviceTestCard(ThemeData theme, ModelManagerState state, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.accentColor.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.accentColor.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  color: AppConstants.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.testInferenceTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${strings.activeModelLabel} ${state.activeModel?.name ?? state.activeModelId}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _testPromptController,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              labelText: strings.testPromptLabel,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: state.isTestingInference ? null : _testOnDeviceLlm,
              icon: state.isTestingInference
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                state.isTestingInference
                    ? strings.processingAi
                    : strings.runTest,
              ),
            ),
          ),

          if (state.testResult != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.testInferenceSuccess
                    ? Colors.green.withAlpha(20)
                    : Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.testInferenceSuccess ? Colors.green : Colors.red,
                  width: 0.8,
                ),
              ),
              child: SelectableText(
                state.testResult!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: state.testInferenceSuccess
                      ? (theme.brightness == Brightness.dark ? Colors.green[300] : Colors.green[900])
                      : (theme.brightness == Brightness.dark ? Colors.red[300] : Colors.red[900]),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelCard(ThemeData theme, ModelManagerState state, LocalModelInfo model, AppStrings strings) {
    final isDownloaded = model.downloadedBytes > 1024 * 1024 ||
        model.state == LocalModelState.ready ||
        model.state == LocalModelState.active;
    final isActive = isDownloaded && (model.id == state.activeModelId || model.state == LocalModelState.active);
    final isDownloading = model.state == LocalModelState.downloading;
    final isReady = isDownloaded && !isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppConstants.primaryColor
              : theme.dividerColor.withAlpha(50),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    if (model.badge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (model.id.contains('qwen')
                                  ? AppConstants.primaryColor
                                  : AppConstants.accentColor)
                              .withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          model.badge!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: model.id.contains('qwen')
                                ? AppConstants.primaryColor
                                : AppConstants.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppConstants.accentColor.withAlpha(20)
                      : Colors.grey.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? strings.active : model.size,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppConstants.accentColor
                        : theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Best for section
          if (model.bestFor != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withAlpha(40),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: '${strings.bestForTitle} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          TextSpan(text: model.bestFor!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          Text(
            model.description,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          if (isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: model.progress > 0 ? model.progress : null,
                minHeight: 6,
                backgroundColor: theme.dividerColor.withAlpha(50),
                valueColor: const AlwaysStoppedAnimation(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${strings.downloading} ${(model.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<ModelManagerBloc>().add(CancelDownloadEvent(model.id));
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.red,
                  ),
                  child: Text(strings.cancel, style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDownloaded)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: strings.delete,
                  onPressed: () {
                    context.read<ModelManagerBloc>().add(DeleteModelEvent(model.id));
                  },
                ),
              if (isReady)
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<ModelManagerBloc>().add(
                          SetActiveModelEvent(model.id),
                        );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(strings.setActive),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (!isDownloaded && !isDownloading)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ModelManagerBloc>().add(
                          DownloadModelEvent(model.id),
                        );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text('${strings.download} (${model.size})'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              if (isActive)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      strings.active,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiCard(ThemeData theme, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cloud_sync_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.geminiTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      strings.geminiDesc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            strings.geminiKeyLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              hintText: 'AIzaSy...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Text(
                'Model:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGeminiModel,
                  isDense: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: _geminiModels.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGeminiModel = val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTestingKey ? null : () => _testGeminiKey(strings),
                  icon: _isTestingKey
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt, size: 16),
                  label: Text(strings.isBangla ? 'সংযোগ টেস্ট করুন' : 'Test Connection'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _saveGeminiConfig(strings),
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: Text(strings.saveKey),
                ),
              ),
            ],
          ),

          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isTestSuccess
                    ? Colors.green.withAlpha(25)
                    : Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isTestSuccess ? Colors.green : Colors.red,
                  width: 0.8,
                ),
              ),
              child: Text(
                _testResult!,
                style: TextStyle(
                  fontSize: 12,
                  color: _isTestSuccess ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
