import 'package:begin_first/app/providers.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final intentsProvider = FutureProvider<List<Intent>>((ref) async {
  final repository = ref.read(intentRepositoryProvider);
  return repository.getAllIntents();
});
