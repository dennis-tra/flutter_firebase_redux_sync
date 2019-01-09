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
    final store = Store<AppState>(null, initialState: AppState(counter: 0));

    test('increment counter on IncrementCounterAction', () async {
      // given
      final actions = Stream.fromIterable([IncrementCounterAction()]);
      final epic = incrementEpic(firestore: firestore)(actions, EpicStore(store));

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);
      when(docRef.updateData({'counter': 1})).thenAnswer((_) => Future.value());

      // then
      expect(epic, emits(CounterDataPushedAction()));
    });


    test('return CounterOnErrorEventAction on error', () async {
      // given
      final actions = Stream.fromIterable([IncrementCounterAction()]);
      final epic = incrementEpic(firestore: firestore)(actions, EpicStore(store));
      final error = "ERROR";

      // when
      when(firestore.document("users/tudor")).thenReturn(docRef);
      when(docRef.updateData({'counter': 1})).thenAnswer((_) => Future.error(error));

      // then
      expect(epic, emits(CounterOnErrorEventAction(error)));
    });
  });
}
