<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# 🥇 Introduction
> Why does this even exist? Flutter already provides `ChangeNotifier` to imlement MVVM patterns. This provides a clean and concise wrapper, making state much easier.

This package is inspired by [Kotlin Compose State](https://developer.android.com/develop/ui/compose/state).

## 🪟 View Model
> The view model is an abstraction of the view exposing public properties and commands.

The view model contains all state relevant for the view. Simply create one:
```dart
class MyViewModel extends ViewModel {
    // We'll discuss what this does later
    late final counter = createMutableState(0);
}
```

And then, simply use it in the UI. Since ViewModel implements ChangeNotifier, you can use it with the built-in Flutter Widgets:
```dart
class MyViewModelWidget extends StatelessWidget {
    final viewModel = MyViewModel();

    @override
    Widget build(BuildContext context) {
        return ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
                return Text("Counter ${viewModel.counter.value}"),
            }
        );
    }
}
```
Make sure to dispose the `ViewModel` when the widget itself is disposed.

**OR**, use the provided [View Model Widget](#view-model-widget).

## 🏗️ View Model Widget
The `ViewModelWidget` is a custom widget that automatically handles all things related view model. This includes:
- Typesafety by using generics
- Creation
- Automatic disposal

It looks and feels just like any Flutter widget, but handles all the state-stuff under the hood.
```dart
class MyViewModelWidget extends ViewModelWidget<MyViewModel> {
    const MyViewModelWidget({super.key, super.create});

    @override
    Widget build(BuildContext context, MyViewModel viewModel) {
        return Text("Couter: ${viewModel.counter.value}");
    }
}
```

# 📜 Creating State
This package provides different methods of using the `ViewModelState`. Each state needs a reference to the `ViewModel` it is defined in, in order to notify the UI and be disposed correctly. This is why you need to use the `late` keyword, as lazy initialization provides a reference to `this`.

## 🏃 Mutable State
This is the most straight-forward approach of defining state. Simply define a reactive value that your UI will listen to.

```dart
class MyViewModel extends ViewModel {
    /// Create equivalent instances of [MutableViewModelState<int>].
    late final counter1 = createMutableState(0);
    late final counter2 = MutableViewModelState(0, this);

    /// Create an instance of [MutableViewModelStateList<String>].
    /// This would be an empty list.
    late final itemList = createMutableStateList();
    /// Create an instance of [MutableViewModelStateList<int>].
    /// This would be initialized with [1,2,3]
    late final numberList = createMutableStateList([1,2,3]);

    /// Creates an instance of [MutableViewModelStateMap<String, String>]
    /// This would be an empty map.
    late final itemMap = createMutableStateMap<String, String>();
    /// Creates an instance of [MutableViewModelStateMap<String, int>]
    /// This would be initialized with {"one": 1, "two": 2}.
    late final numberMap = createMutableStateList<String, int>({"one": 1, "two": 2});
}

// Modify and access using .value
final viewModel = MyViewModel();
viewModel.counter1.value++;
print(viewModel.counter1.value); // Prints: 1
viewModel.counter2.value = 42;
print(viewModel.counter2.value); // Prints: 42

// State lists already implement the List Api.
viewModel.itemList.add("item1");
print(viewModel.itemList); // Prints: ["item1"]
viewModel.numberList.remove(1);
print(viewModel.numberList); // Prints: [2,3]

// State maps already implement the Map Api.
viewModel.itemMap.add({"three": 3});
print(viewModel.itemMap); // Prints: {"three": 3}
viewModel.numberMap.remove("one");
print(viewModel.numberMap); // Prints: {"two": 2}
```

## 🧍 Immutable State
Technically, there is no such thing. Still, you can implement a pattern that does not allow the `ViewModel` to mutate its state, but delegate modification of state to a repository or similar.

```dart
class MyViewModel extends ViewModel {
    late final _counterState = createMutableState(0); // Private
    int get counter => _counterState.value; // Only expose getter

    void countSomething(int amount) {
        // Modify private state. This will be reflected in the UI.
        _counterState.value += amount;
    }
}
```

## 🔄 Converting to State
Of course, there is also a way to react to state outside of the `ViewModel`, for example when listening to an authentication stream from a repository and wanting to react to that stream. For that, there exist several state-creating functions:
```dart
final stream = Stream<int>.periodic(Duration(seconds: 1), (x) => x);
final future = Future<int>.delayed(Duration(seconds: 1), () => 42);
final notifier = ValueNotifier<int>(42);

class MyViewModel extends ViewModel {
    /// Internally subscribes to the stream and updates the state 
    /// whenever the stream fires a new event. Initializes with 0.
    late final streamState = createStateFromStream(stream, 0);

    /// Internally converts the future to a stream and subscribes to it.
    /// Initializes with 1
    late final futureState = createStateFromFuture(future, 1);

    /// Internally adds a listener to the value notifier.
    /// This is initialized with the initial value of the notifier.
    late final notifierState = createStateFromValueNotifier(notifier);
}
```

## 🤲 Getters and Setters
You can define getters and setters for private mutable state so you do not have to append `.value` to your states:
```dart
class MyViewModel extends ViewModel {
    late final _counter = createMutableState(0); // Private
    int get counter => _counter.value;
    set counter(int value) => _counter.value = value;
}

// Access is then simplified to
final viewModel = MyViewModel();
print(myViewModel.counter); // Prints: 0
myViewModel.counter++;
print(myViewModel.counter); // Prints: 1
myViewModel.counter = 42;
print(myViewModel.counter); // Prints: 42
```

# ☀️/🌙 Example: App Theme
A simple app that showcases 
```dart
class MyRepository {
    final globalTheme = ValueNotifier<bool>(false);
}

class MyViewModel extends ViewModel {
    MyViewModel(this._myRepository);

    final MyRepository _myRepository;

    late final isDarkTheme = createStateFromValueNotifier(_myRepository.globalTheme);

    void toggleTheme() {
        _myRepository.globalTheme.value = !_myRepository.globalTheme.value;
    }
}

void main() {
    // You can create your repositories however you like, using dependency injection, service locators or global variables.
    final myRepository = MyRepository();
    runApp(
        MyApp(create: () => MyViewModel(myRepository))
    );
}

class MyApp extends ViewModelWidget<MyViewModel> {
    const MyApp({super.key, required super.create});

    @override
    Widget build(BuildContext context, MyViewModel viewModel) {
        return MaterialApp(
            title: "Theme Demo",
            theme: viewModel.isDarkTheme.value ? ThemeData.dark() : ThemeData.light(),
            home: Scaffold(
                body: Center(
                    child: Text("Dark Theme Demo"),
                )
            ),
        );
    }
}
```

# 🧮 Example: Counter
```dart
class MyViewModel extends ViewModel {
  late final counter = createMutableState(0);
}

void main() {
    runApp(
        MaterialApp(
            title: "Counter Demo",
            home: MyApp(create: () => MyViewModel())
        )
    );
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
```

# 🎉 Contributing
Feel free to open issues and PRs on [GitHub](https://github.com/larnetic/view_model_state).

# 👀 License
BSD 3-Clause License, see [LICENSE](/LICENSE) for details.
