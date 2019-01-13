import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

import 'package:firebase_redux_sync/redux/actions.dart';
import 'package:firebase_redux_sync/redux/app_state.dart';
import 'package:firebase_redux_sync/redux/middleware.dart';


class FirestoreMock extends Mock implements Firestore {}
class DocumentReferenceMock extends Mock implements DocumentReference {}

main() {
  group('incrementEpic', () {
    final firestore = FirestoreMock();
    final docRef = DocumentReferenceMock();

    StreamController actions;

    setUp(() {
      actions = StreamController.broadcast(sync: true);
    });

    tearDown(() {
      actions.close();
    });

    test('increment counter on IncrementCounterAction', () async {
      // given
      final store = Store<AppState>(null, initialState: AppState(counter: 0) );
      final epic = incrementEpic(firestore: firestore)(actions.stream, EpicStore(store));

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);

      scheduleMicrotask(() {
        when(docRef.updateData({'counter': 1})).thenAnswer((_) => Future.value());
        actions.add(IncrementCounterAction());
      });

      // then
      await expectLater(epic, emits(CounterDataPushedAction()));
    });

    test('return CounterOnErrorEventAction on error', () async {
      // given
      final store = Store<AppState>(null, initialState: AppState(counter: 0) );
      final epic = incrementEpic(firestore: firestore)(actions.stream, EpicStore(store));
      final error = "ERROR";

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);

      scheduleMicrotask(() {
        when(docRef.updateData({'counter': 1})).thenAnswer((a) => Future.error(error));
        actions.add(IncrementCounterAction());
      });

      // then
      await expectLater(epic, emits(CounterOnErrorEventAction(error)));
    });

    test('emit correct actions upon successful and failed update', () async {
      // given
      final store = Store<AppState>(null, initialState: AppState(counter: 0) );
      final epic = incrementEpic(firestore: firestore)(actions.stream, EpicStore(store));
      final data = {"counter": 1};
      final error1 = "ERROR_1";
      final error2 = "ERROR_2";

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);

      scheduleMicrotask(() async {

        when(docRef.updateData(data)).thenAnswer((_) => Future.value());
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        when(docRef.updateData(data)).thenAnswer((a) => Future.error(error1));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        when(docRef.updateData(data)).thenAnswer((_) => Future.value());
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        when(docRef.updateData(data)).thenAnswer((a) => Future.error(error2));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));
      });

      // then
      await expectLater(epic, emitsInOrder([
        CounterDataPushedAction(),
        CounterOnErrorEventAction(error1),
        CounterDataPushedAction(),
        CounterOnErrorEventAction(error2),
      ]));
    });

    test('can cancel increment epic action', () async {
      // given
      final store = Store<AppState>(null, initialState: AppState(counter: 0) );
      final epic = incrementEpic(firestore: firestore)(actions.stream, EpicStore(store));
      final data = {"counter": 1};
      final error1 = "ERROR_1";
      final error2 = "ERROR_2";

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);

      scheduleMicrotask(() async {
        when(docRef.updateData(data)).thenAnswer((_) => Future.delayed(Duration(milliseconds: 200)));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        actions.add(CancelIncrementCounterAction());

        when(docRef.updateData(data)).thenAnswer((a) => Future.error(error1));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        when(docRef.updateData(data)).thenAnswer((_) => Future.delayed(Duration(milliseconds: 200)));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        actions.add(CancelIncrementCounterAction());

        when(docRef.updateData(data)).thenAnswer((a) => Future.error(error2));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));

        when(docRef.updateData(data)).thenAnswer((_) => Future.delayed(Duration(milliseconds: 200)));
        actions.add(IncrementCounterAction());
        await untilCalled(docRef.updateData(data));
      });

      // then
      await expectLater(epic, emitsInOrder([
        CounterOnErrorEventAction(error1),
        CounterOnErrorEventAction(error2),
        CounterDataPushedAction(),
      ]));
    });
  });
}

