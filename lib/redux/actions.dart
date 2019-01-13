class IncrementCounterAction {}
class CancelIncrementCounterAction {}

class CounterDataPushedAction {
  @override
  bool operator ==(dynamic other) {
    return other.runtimeType == runtimeType;
  }
}

class RequestCounterDataEventsAction {}

class CancelCounterDataEventsAction {}

class CounterOnDataEventAction {
  final int counter;

  CounterOnDataEventAction(this.counter);

  @override
  String toString() => 'CounterOnDataEventAction{counter: $counter}';
}

class CounterOnErrorEventAction {
  final dynamic error;

  CounterOnErrorEventAction(this.error);

  @override
  bool operator ==(dynamic other) {
    if (other is CounterOnErrorEventAction) {
      return other.error == this.error;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode ^ error.hashCode;
}
