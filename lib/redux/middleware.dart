import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_redux_sync/redux/actions.dart';
import 'package:firebase_redux_sync/redux/app_state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

final allEpics = combineEpics<AppState>([counterEpic, incrementEpic()]);

Epic<AppState> incrementEpic({Firestore firestore}) {
  firestore = firestore ?? Firestore.instance;
  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    return new Observable(actions)
        .ofType(new TypeToken<IncrementCounterAction>())
        .flatMap((_) {
      return new Observable.fromFuture(firestore.document("users/tudor")
          .updateData({'counter': store.state.counter + 1}))
          .map<dynamic>((_) => CounterDataPushedAction())
          .onErrorReturnWith((e) => CounterOnErrorEventAction(e))
          .takeUntil(actions.where((action) => action is CancelIncrementCounterAction));
    });
  };
}

Stream<dynamic> counterEpic(Stream<dynamic> actions, EpicStore<AppState> store) {
  return new Observable(actions) // 1
      .ofType(new TypeToken<RequestCounterDataEventsAction>()) // 2
      .switchMap((RequestCounterDataEventsAction requestAction) { // 3
    return getUserClicks() // 4
        .map((counter) => new CounterOnDataEventAction(counter)) // 7
        .takeUntil(actions.where((action) => action is CancelCounterDataEventsAction)); // 8
  });
}

Observable<int> getUserClicks() {
  return new Observable(Firestore.instance.document("users/tudor").snapshots()) // 5
      .map((DocumentSnapshot doc) => doc['counter'] as int); // 6
}
