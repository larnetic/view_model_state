import 'dart:collection' show ListBase;

import 'view_model.dart' show ViewModel;

/// An interface representing a state managed by a [ViewModel].
/// The state can be either mutable or immutable.
/// It provides a way to access the current value of the state.
///
/// When instantiated via a [ViewModel], the state is immutable from the ViewModelState itself,
/// but can be modified by other means, e.g. from a repository.
abstract interface class ViewModelState<T> {
  T get value;
}

/// Creates a mutable state object that holds a value of type [T].
/// The state can be modified by setting its [value] property.
///
/// The state will notify the associated [ViewModel] whenever its value changes,
/// allowing the ViewModel to notify its listeners.
class MutableViewModelState<T> implements ViewModelState<T> {
  T _value;
  final ViewModel _model;

  MutableViewModelState(this._value, this._model);

  set value(T newValue) {
    _value = newValue;
    _model.notifyListeners();
  }

  @override
  T get value => _value;
}

/// A mutable list state that holds a list of items of type [T].
/// The list can be modified like a regular list, and any changes will notify
/// the associated [ViewModel].
///
/// The list will notify the ViewModel whenever it is modified, allowing the ViewModel
/// to notify its listeners.
class MutableViewModelStateList<T> extends ListBase<T> {
  // T must be nullable here, because when adding items to the list,
  // the index of that item will shortly contain a null value in dart.
  final List<T?> _list = [];
  final ViewModel _model;

  MutableViewModelStateList(this._model);

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    bool shouldNotify = newLength < _list.length;
    _list.length = newLength;
    if (shouldNotify) {
      // Only notify if items were removed
      // This is necessary, because in dart, adding items to a list causes
      // the index of that item to contain a null value first, which would
      // cause a notifyListeners call.
      _model.notifyListeners();
    }
  }

  @override
  // T could be null here, because the user might want to add null values to the list.
  T operator [](int index) => _list[index] as T;

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    _model.notifyListeners();
  }
}
