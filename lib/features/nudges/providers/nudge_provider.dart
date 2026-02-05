import 'package:begin_first/app/providers.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final randomNudgeProvider = FutureProvider<Intent?>((ref) async {
  final repository = ref.read(intentRepositoryProvider);
  return repository.getRandomActiveIntent();
});
