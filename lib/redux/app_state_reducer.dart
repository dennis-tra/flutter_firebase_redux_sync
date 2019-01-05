import 'package:firebase_redux_sync/redux/actions.dart';
import 'package:firebase_redux_sync/redux/app_state.dart';
import 'package:redux/redux.dart';


AppState appStateReducer(AppState state, dynamic action) {
  return new AppState(
    counter: counterReducer(state.counter, action),
  );
}

final counterReducer =  combineReducers<int>([
  TypedReducer<int, CounterOnDataEventAction>(_setCounter),
]);

int _setCounter(int oldCounter, CounterOnDataEventAction action) {
  return action.counter;
}

