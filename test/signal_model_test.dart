import 'package:flutter_signal/src/signal_model.dart';
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
  test("clear the model store", testClear);
}

void testAddModel() {
  final myModel = MyModel();
  ModelStore.add(() => myModel);
  expect(TestStub.modelRepository.containsKey(MyModel), false);
  expect(TestStub.modelBuilderRepository.containsKey(MyModel), true);
  expect(myModel, ModelStore.get<MyModel>());
  expect(TestStub.modelRepository.containsKey(MyModel), true);
}

void testAddEagerlyModel() {
  ModelStore.addEager(MyModel());
  expect(TestStub.modelRepository.containsKey(MyModel), true);
}

void testGetModel() {
  ModelStore.add(()=>MyModel());
  expect(ModelStore.get<MyModel>(), isNot(null));
  ModelStore.addEager(TestModel());
  expect(ModelStore.get<TestModel>(), isNot(null));
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

void testClear() {
  final modelRepository = TestStub.modelRepository;
  final modelBuilderRepository = TestStub.modelBuilderRepository;

  ModelStore.add(() => TestModel());
  ModelStore.get<TestModel>();
  expect(modelRepository.isNotEmpty, true);
  expect(modelBuilderRepository.isNotEmpty, true);
  ModelStore.clear();
  expect(modelRepository.isEmpty, true);
  expect(modelRepository.isEmpty, true);
}

class TestModel extends SignalModel {}