import 'dart:ui';

import 'package:flutter/foundation.dart' show ChangeNotifier, Listenable;
import 'package:flutter/widgets.dart' show BuildContext, ListenableBuilder, State, StatefulWidget, Widget;
import 'package:view_model_state/src/state_scope.dart';
import 'view_model.dart';

/// A widget that is bound to a [ViewModel].
///
/// A ViewModelWidget is a widget that automatically rebuilds when the
/// [ViewModel] notifies its listeners. It also handles the disposal of the
/// ViewModel when the widget is removed from the widget tree.
///
/// Every ViewModelWidget must be parameterized with a specific type of ViewModel [V].
/// When instantiating a ViewModelWidget, a function that creates the ViewModel must be provided
/// via the `create` parameter.
/// There are no restrictions on how the ViewModel is created. It can be
/// instantiated directly, retrieved from a service locator, or created
/// using a dependency injection framework.
///
/// ViewModelWidgets are useful as a shorthand for creating widgets that are
/// bound to a ViewModel, without having to manually manage the lifecycle of the
/// ViewModel or using ListnableBuilder directly.
/// ```dart
/// class MyViewModel extends ViewModel {
///   final counter = createMutableState(0);
/// }
///
/// class MyViewModelWidget extends ViewModelWidget<MyViewModel> {
///   const MyViewModelWidget({super.key, super.create});
///
///   @override
///   Widget build(BuildContext context, MyViewModel viewModel) {
///     return Text('Counter: ${viewModel.counter.value}');
///   }
/// }
/// ```
///
/// The above example is equivalent to using ListenableBuilder directly:
/// ```dart
/// class MyViewModel extends ViewModel {
///   final counter = createMutableState(0);
/// }
///
/// class MyViewModelWidget extends StatelessWidget {
///   const MyViewModelWidget({super.key, required this.viewModel});
///   final MyViewModel viewModel;
///
///   @override
///   Widget build(BuildContext context) {
///     return ListenableBuilder(
///       listenable: viewModel,
///       builder: (context, _) {
///         return Text('Counter: ${viewModel.counter.value}');
///       },
///     );
///   }
/// }
/// ```
abstract class ViewModelWidget<V extends ViewModel> extends StatefulWidget with StateScope {
  ViewModelWidget({super.key, required this.create});

  final V Function() create;

  Widget build(BuildContext context, V viewModel);

  @override
  State<ViewModelWidget> createState() => _ViewModelWidgetState<V>();
}

class _ViewModelWidgetState<V extends ViewModel> extends State<ViewModelWidget<V>> {
  late final V viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _CompositeListenable([viewModel, widget]),
      builder: (context, child) => widget.build(context, viewModel),
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

class _CompositeListenable extends Listenable {
  final List<ChangeNotifier> notifiers;

  _CompositeListenable(this.notifiers);

  @override
  void addListener(VoidCallback listener) {
    for (final notifier in notifiers) {
      notifier.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (final notifier in notifiers) {
      notifier.removeListener(listener);
    }
  }
}

abstract class StateScopeWidget extends StatefulWidget with StateScope {
  StateScopeWidget({super.key});

  Widget build(BuildContext context);

  @override
  State<StateScopeWidget> createState() => _StateScopeWidgetState();
}

class _StateScopeWidgetState extends State<StateScopeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget,
      builder: (context, child) => widget.build(context),
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
