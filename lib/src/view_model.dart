import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;
import 'package:view_model_state/src/state_scope.dart';

/// A base class for view models that manage state and notify listeners of changes.
///
/// A ViewModel is responsible for holding and managing the state of a part of the UI.
/// It extends [ChangeNotifier], allowing it to notify listeners when its state changes.
/// ViewModels can create and manage various types of state, including primitive values,
/// lists, and state derived from [ValueNotifier]s, [Stream]s, or [Future]s.
///
/// ViewModels also handle the disposal of resources when they are no longer needed.
/// When a ViewModel is disposed, it will call any registered disposal callbacks
/// to clean up resources such as stream subscriptions or listeners on ValueNotifiers.
/// ViewModels should be disposed of when they are no longer needed to prevent memory leaks.
///
/// Example usage:
/// ```dart
/// class MyViewModel extends ViewModel {
///   // late is important because otherwise, `this` cannot be passed to the state.
///   late final counter = MutableViewModelState<int>(0, this);
/// }
/// ```
///
/// The above example creates a ViewModel with a mutable integer state initialized to 0.
///
/// There also exist helper methods to create states. These methods automatically
/// register disposal callbacks to clean up resources when the ViewModel is disposed.
/// ```dart
/// class MyViewModel extends ViewModel {
///   late final primitiveState = createMutableState(0); // Primitive mutable state: int
///   late final listState = createMutableStateList<String>(); // List mutable state: List<String>
///   late final notifierState = createStateFromValueNotifier(ValueNotifier<int>(0)); // State from ValueNotifier
///   late final streamState = createStateFromStream(Stream<int>.periodic(Duration(seconds: 1), (x) => x), 0); // State from Stream
///   late final futureState = createStateFromFuture(Future<int>.delayed(Duration(seconds: 1), () => 42), 0); // State from Future
/// }
/// ```
abstract class ViewModel with StateScope {}
