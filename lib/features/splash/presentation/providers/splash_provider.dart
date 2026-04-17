import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/di/providers.dart';

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});