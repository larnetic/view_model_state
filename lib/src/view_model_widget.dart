import 'package:flutter/widgets.dart' show BuildContext, State, StatefulWidget, Widget, ListenableBuilder;
import 'view_model.dart';

abstract class ViewModelWidget<V extends ViewModel> extends StatefulWidget {
  const ViewModelWidget({super.key, required this.create});

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
    return ListenableBuilder(listenable: viewModel, builder: (context, child) => widget.build(context, viewModel));
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
