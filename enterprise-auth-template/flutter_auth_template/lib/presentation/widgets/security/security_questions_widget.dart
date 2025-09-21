import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

/// Security question model
class SecurityQuestion {
  final String id;
  final String question;
  final String? answer;

  const SecurityQuestion({
    required this.id,
    required this.question,
    this.answer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        if (answer != null) 'answer': answer,
      };

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String?,
    );
  }
}

/// Predefined security questions
class SecurityQuestionBank {
  static List<SecurityQuestion> get questions => [
    const SecurityQuestion(id: 'q1', question: 'What was the name of your first pet?'),
    const SecurityQuestion(id: 'q2', question: 'What is your mother\'s maiden name?'),
    const SecurityQuestion(id: 'q3', question: 'What was the name of your first school?'),
    const SecurityQuestion(id: 'q4', question: 'In what city were you born?'),
    const SecurityQuestion(id: 'q5', question: 'What is your favorite book?'),
    const SecurityQuestion(id: 'q6', question: 'What was your childhood nickname?'),
    const SecurityQuestion(id: 'q7', question: 'What street did you grow up on?'),
    const SecurityQuestion(id: 'q8', question: 'What is your oldest sibling\'s middle name?'),
    const SecurityQuestion(id: 'q9', question: 'What was your dream job as a child?'),
    const SecurityQuestion(id: 'q10', question: 'What year did you graduate from high school?'),
    const SecurityQuestion(id: 'q11', question: 'What is your favorite movie?'),
    const SecurityQuestion(id: 'q12', question: 'What was the make of your first car?'),
  ];

  const SecurityQuestionBank._();
}

/// Widget for setting up security questions
class SecurityQuestionsSetup extends HookConsumerWidget {
  final VoidCallback? onComplete;
  final int requiredQuestions;

  const SecurityQuestionsSetup({
    super.key,
    this.onComplete,
    this.requiredQuestions = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final secureStorage = ref.watch(secureStorageServiceProvider);

    final selectedQuestions = useState<List<SecurityQuestion>>([]);
    final answers = useState<Map<String, TextEditingController>>({});
    final currentStep = useState(0);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    // Initialize answer controllers
    useEffect(() {
      for (int i = 0; i < requiredQuestions; i++) {
        answers.value['q$i'] = TextEditingController();
      }
      return () {
        for (final controller in answers.value.values) {
          controller.dispose();
        }
      };
    }, []);

    // Get available questions (excluding already selected ones)
    List<SecurityQuestion> getAvailableQuestions() {
      final selectedIds = selectedQuestions.value.map((q) => q.id).toSet();
      return SecurityQuestionBank.questions
          .where((q) => !selectedIds.contains(q.id))
          .toList();
    }

    // Select a question
    void selectQuestion(SecurityQuestion question) {
      if (selectedQuestions.value.length < requiredQuestions) {
        selectedQuestions.value = [...selectedQuestions.value, question];
        if (selectedQuestions.value.length < requiredQuestions) {
          currentStep.value++;
        }
      }
    }

    // Save security questions
    Future<void> saveSecurityQuestions() async {
      isLoading.value = true;
      errorMessage.value = null;

      try {
        // Validate all answers are provided
        for (int i = 0; i < selectedQuestions.value.length; i++) {
          final answer = answers.value['q$i']?.text.trim();
          if (answer == null || answer.isEmpty) {
            errorMessage.value = 'Please answer all security questions';
            isLoading.value = false;
            return;
          }
        }

        // Create questions with answers
        final questionsWithAnswers = <SecurityQuestion>[];
        for (int i = 0; i < selectedQuestions.value.length; i++) {
          final question = selectedQuestions.value[i];
          final answer = answers.value['q$i']?.text.trim();
          questionsWithAnswers.add(
            SecurityQuestion(
              id: question.id,
              question: question.question,
              answer: answer,
            ),
          );
        }

        // Hash answers before storing (in production, use proper hashing)
        final hashedQuestions = questionsWithAnswers.map((q) {
          return {
            'id': q.id,
            'question': q.question,
            // In production, use proper password hashing like bcrypt
            'answerHash': base64.encode(utf8.encode(q.answer!.toLowerCase())),
          };
        }).toList();

        // Store in secure storage
        await secureStorage.storeJsonData(
          'security_questions',
          {'questions': hashedQuestions},
        );

        onComplete?.call();
      } catch (e) {
        errorMessage.value = 'Failed to save security questions';
      } finally {
        isLoading.value = false;
      }
    }

    Widget buildQuestionSelection() {
      final availableQuestions = getAvailableQuestions();
      final questionNumber = selectedQuestions.value.length + 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Security Question $questionNumber of $requiredQuestions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a question that only you know the answer to',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((179).round()),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: availableQuestions.length,
              itemBuilder: (context, index) {
                final question = availableQuestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(question.question),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => selectQuestion(question),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget buildAnswerForm() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Answer Your Security Questions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide answers that you\'ll remember',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((179).round()),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < selectedQuestions.value.length; i++) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha((26).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha((51).round()),
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
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedQuestions.value[i].question,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: answers.value['q$i'],
                            decoration: const InputDecoration(
                              labelText: 'Your answer',
                              hintText: 'Enter your answer',
                              prefixIcon: Icon(Icons.edit),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),
                    if (i < selectedQuestions.value.length - 1)
                      const SizedBox(height: 16),
                  ],
                  if (errorMessage.value != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage.value!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading.value
                      ? null
                      : () {
                          selectedQuestions.value = [];
                          currentStep.value = 0;
                          for (final controller in answers.value.values) {
                            controller.clear();
                          }
                        },
                  child: const Text('Start Over'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : saveSecurityQuestions,
                  child: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Questions'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return selectedQuestions.value.length < requiredQuestions
        ? buildQuestionSelection()
        : buildAnswerForm();
  }
}

/// Widget for verifying security questions
class SecurityQuestionsVerification extends HookConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onForgot;

  const SecurityQuestionsVerification({
    super.key,
    this.onSuccess,
    this.onForgot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final secureStorage = ref.watch(secureStorageServiceProvider);

    final questions = useState<List<Map<String, dynamic>>>([]);
    final selectedQuestion = useState<Map<String, dynamic>?>(null);
    final answerController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final attemptsRemaining = useState(3);

    // Load security questions
    useEffect(() {
      Future<void> loadQuestions() async {
        try {
          final data = await secureStorage.getJsonData('security_questions');
          if (data != null && data['questions'] != null) {
            final questionsList = (data['questions'] as List)
                .cast<Map<String, dynamic>>();
            questions.value = questionsList;

            // Select a random question
            if (questionsList.isNotEmpty) {
              final randomIndex = DateTime.now().millisecondsSinceEpoch % questionsList.length;
              selectedQuestion.value = questionsList[randomIndex];
            }
          }
        } catch (e) {
          errorMessage.value = 'Failed to load security questions';
        }
      }

      loadQuestions();
      return null;
    }, []);

    Future<void> verifyAnswer() async {
      isLoading.value = true;
      errorMessage.value = null;

      try {
        final answer = answerController.text.trim().toLowerCase();
        if (answer.isEmpty) {
          errorMessage.value = 'Please enter your answer';
          isLoading.value = false;
          return;
        }

        // Hash the answer and compare (in production, use proper hashing)
        final answerHash = base64.encode(utf8.encode(answer));
        final storedHash = selectedQuestion.value?['answerHash'] as String?;

        if (answerHash == storedHash) {
          // Success
          onSuccess?.call();
        } else {
          // Failed attempt
          attemptsRemaining.value--;
          if (attemptsRemaining.value <= 0) {
            errorMessage.value = 'Too many failed attempts. Please try another method.';
            // In production, lock the account or take other security measures
          } else {
            errorMessage.value = 'Incorrect answer. ${attemptsRemaining.value} attempts remaining.';
          }
        }
      } catch (e) {
        errorMessage.value = 'Verification failed';
      } finally {
        isLoading.value = false;
      }
    }

    if (selectedQuestion.value == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading security question...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Security Question Verification',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please answer your security question to continue',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((179).round()),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha((26).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha((51).round()),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Question',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selectedQuestion.value?['question'] as String? ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: answerController,
            decoration: InputDecoration(
              labelText: 'Your answer',
              hintText: 'Enter your answer',
              prefixIcon: const Icon(Icons.edit),
              enabled: attemptsRemaining.value > 0,
            ),
            textCapitalization: TextCapitalization.sentences,
            enabled: attemptsRemaining.value > 0,
          ),
          if (errorMessage.value != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage.value!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (onForgot != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onForgot,
                    child: const Text('Forgot Answer'),
                  ),
                ),
              if (onForgot != null) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (isLoading.value || attemptsRemaining.value <= 0)
                      ? null
                      : verifyAnswer,
                  child: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
          if (attemptsRemaining.value > 0 && attemptsRemaining.value < 3) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((26).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withAlpha((51).round()),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${attemptsRemaining.value} attempts remaining',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}