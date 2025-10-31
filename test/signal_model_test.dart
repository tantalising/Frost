import 'package:frost/model_store.dart';
import 'package:frost/src/model_store.dart';
import 'package:test/test.dart';

class MyModel extends SignalModel {
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
class TestModel extends SignalModel {}

void main() {
  setUp(() => ModelStore.clear()); // empty the store before every test.

  group('model test group', () {
    test("add model to store", testAddModel);
    test("add eagerly model to store", testAddEagerlyModel);
    test("get model from store", testGetModel);
    test("remove model from store", testRemoveModel);
    test("replace an existing model from the store", testReplaceModel);
    test("call init on add", testInitOnAdd);
    test("call dispose on remove", testDisposeOnRemove);
    test("clear the model store", testClear);
  });

  group('id model test group', () {
    test("add id model to store", testAddIdModel);
    test("add eagerly model to store", testAddEagerlyIdModel);
    test("get eagerly model from store", testGetIdModel);
    test("remove model from store", testRemoveIdModel);
    test("replace an existing id model from the store", testReplaceIdModel);
    test("call init on add on an id model", testInitOnAddIdModel);
    test("call dispose upon removal on an id model", testDisposeOnRemoveIdModel);
    test("clear the model store of an id model", testClearIdModel);
  });

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
  ModelStore.get<MyModel>(); // needed since addition is lazy.
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



void testAddIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  ModelStore.add(() => myModel, 'modelId');
  expect(TestStub.idModelRepository.containsKey(id), false);
  expect(TestStub.idModelBuilderRepository.containsKey(id), true);
  expect(myModel, ModelStore.get(id));
  expect(TestStub.idModelRepository.containsKey(id), true);
}

void testAddEagerlyIdModel() {
  const id = 'modelId';
  ModelStore.addEager(MyModel(), id);
  expect(TestStub.idModelRepository.containsKey(id), true);
}

void testGetIdModel() {
  const id = 'modelId';
  const anotherId = 'anotherModelId';
  ModelStore.add(()=>MyModel(), id);
  expect(ModelStore.get(id), isNot(null));
  ModelStore.addEager(TestModel(), anotherId);
  expect(ModelStore.get(anotherId), isNot(null));
}

void testRemoveIdModel() {
  const id = 'modelId';
  ModelStore.add(()=>MyModel(), id);
  ModelStore.get(id); // needed since addition is lazy.
  expect(ModelStore.remove(id), isNot(null));
}

void testReplaceIdModel() {
  const id = 'modelId';
  ModelStore.add(()=>MyModel(), id);
  ModelStore.replace(()=>MyModel()..replaced=true, id);
  expect(ModelStore.get<MyModel>(id)!.replaced, true);
}

void testInitOnAddIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  ModelStore.add(()=>myModel, id);
  ModelStore.get<MyModel>(id); // needed since addition is lazy.
  expect(myModel.initCalled, true);
}

void testDisposeOnRemoveIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  ModelStore.add(()=>myModel, id);
  ModelStore.get<MyModel>(id); // needed since addition is lazy.
  ModelStore.remove(id);
  expect(myModel.disposeCalled, true);
}

void testClearIdModel() {
  final modelRepository = TestStub.idModelRepository;
  final modelBuilderRepository = TestStub.idModelBuilderRepository;

  const id = 'modelId';

  ModelStore.add(() => TestModel(), id);
  ModelStore.get<TestModel>(id);
  expect(modelRepository.isNotEmpty, true);
  expect(modelBuilderRepository.isNotEmpty, true);
  ModelStore.clear();
  expect(modelRepository.isEmpty, true);
  expect(modelRepository.isEmpty, true);
}
