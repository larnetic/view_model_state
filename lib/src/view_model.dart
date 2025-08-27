import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;
import 'states.dart';

abstract class ViewModel extends ChangeNotifier {
  final _disposeCallbacks = List<Function>.empty(growable: true);

  void addDisposeCallback(Function callback) {
    _disposeCallbacks.add(callback);
  }

  @override
  void dispose() {
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    super.dispose();
  }

  void update() {
    notifyListeners();
  }
}

extension StateHelpers on ViewModel {
  /// Creates a mutable state object that is tied to this ViewModel.
  MutableViewModelState<T> createMutableState<T>(T initial) {
    return MutableViewModelState<T>(initial, this);
  }

  MutableViewModelStateList<T> createMutableStateList<T>() {
    return MutableViewModelStateList<T>(this);
  }

  ViewModelState<T> createStateFromValueNotifier<T>(ValueNotifier<T> notifier) {
    final state = createMutableState(notifier.value);
    void listener() {
      state.value = notifier.value;
    }

    notifier.addListener(listener);
    addDisposeCallback(() => notifier.removeListener(listener));
    return state;
  }

  ViewModelState<T> createStateFromStream<T>(Stream<T> stream, T initial) {
    final state = createMutableState(initial);
    final sub = stream.listen((value) {
      state.value = value;
    });

    addDisposeCallback(() => sub.cancel());
    return state;
  }

  ViewModelState<T> createStateFromFuture<T>(Future<T> future, T initial) {
    return createStateFromStream(future.asStream(), initial);
  }
}
