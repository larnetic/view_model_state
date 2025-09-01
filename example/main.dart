import 'package:flutter/material.dart';
import 'package:view_model_state/view_model_state.dart';

class MyViewModel extends ViewModel {
  late final counter = createMutableState(0);
}

void main() {
  runApp(MaterialApp(
      title: "Counter Demo", home: MyApp(create: () => MyViewModel())));
}

class MyApp extends ViewModelWidget<MyViewModel> {
  const MyApp({super.key, required super.create});

  @override
  Widget build(BuildContext context, MyViewModel viewModel) {
    return Scaffold(
      body: Center(
        child: Text("Counter: ${viewModel.counter.value}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.counter.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
