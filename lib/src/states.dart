import 'dart:collection' show ListBase;

import 'view_model.dart' show ViewModel;

abstract interface class ViewModelState<T> {
  T get value;
}

class MutableViewModelState<T> implements ViewModelState<T> {
  T _value;
  final ViewModel _model;

  MutableViewModelState(this._value, this._model);

  set value(T newValue) {
    _value = newValue;
    _model.update();
  }

  @override
  T get value => _value;
}

class MutableViewModelStateList<T> extends ListBase<T> {
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
      _model.update();
    }
  }

  @override
  T operator [](int index) => _list[index]!;

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    _model.update();
  }
}
