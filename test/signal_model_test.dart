import 'package:flutter_signal/signal_model.dart';
import 'package:test/test.dart';


class MyModel implements SignalModel {
  bool initCalled = false;
  bool disposeCalled = false;
  bool replaced = false;

  @override
  void init() {
    initCalled = true;
  }
  @override
  void dispose() {
    disposeCalled = true;
  }
}

void main() {
  setUp(() => ModelStore.clear()); // empty the store before every test.

  test("add model to store", testAddModel);
  test("get model from store", testGetModel);
  test("remove model from store", testRemoveModel);
  test("call init on add", testInitOnAdd);
  test("call dispose on remove", testDisposeOnRemove);
  test("replace an existing model from the store", testReplaceModel);
}

void testAddModel() {
  final myModel = MyModel();
  ModelStore.add(() => myModel);
  expect(myModel, ModelStore.get<MyModel>());
}

void testGetModel() {
  ModelStore.add(()=>MyModel());
  expect(ModelStore.get<MyModel>(), isNot(null));
}

void testRemoveModel() {
  ModelStore.add(()=>MyModel());
  ModelStore.get<MyModel>(); // needed since addition is lazy.
  expect(ModelStore.remove<MyModel>(), isNot(null));
}

void testReplaceModel() {
  ModelStore.add(()=>MyModel());
  ModelStore.replace(()=>MyModel()..replaced=true);
  expect(ModelStore.get<MyModel>()!.replaced, true);
}

void testInitOnAdd() {
  final myModel = MyModel();
  ModelStore.add(()=>myModel);
  ModelStore.get<MyModel>(); // needed since addition is lazy.
  expect(myModel.initCalled, true);
}

void testDisposeOnRemove() {
  final myModel = MyModel();
  ModelStore.add(()=>myModel);
  ModelStore.get<MyModel>(); // needed since addition is lazy.3
  ModelStore.remove<MyModel>();
  expect(myModel.disposeCalled, true);
}

