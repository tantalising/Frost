import 'package:frost/model_store.dart';
import 'package:frost/src/store.dart';
import 'package:test/test.dart';

class MyModel extends Model {
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
class TestModel extends Model {}

void main() {
  setUp(() => Store.clear()); // empty the store before every test.

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
  Store.add(() => myModel);
  expect(TestStub.modelRepository.containsKey(MyModel), false);
  expect(TestStub.modelBuilderRepository.containsKey(MyModel), true);
  expect(myModel, Store.get<MyModel>());
  expect(TestStub.modelRepository.containsKey(MyModel), true);
}

void testAddEagerlyModel() {
  Store.addEager(MyModel());
  expect(TestStub.modelRepository.containsKey(MyModel), true);
}

void testGetModel() {
  Store.add(()=>MyModel());
  expect(Store.get<MyModel>(), isNot(null));
  Store.addEager(TestModel());
  expect(Store.get<TestModel>(), isNot(null));
}

void testRemoveModel() {
  Store.add(()=>MyModel());
  Store.get<MyModel>(); // needed since addition is lazy.
  expect(Store.remove<MyModel>(), isNot(null));
}

void testReplaceModel() {
  Store.add(()=>MyModel());
  Store.replace(()=>MyModel()..replaced=true);
  expect(Store.get<MyModel>()!.replaced, true);
}

void testInitOnAdd() {
  final myModel = MyModel();
  Store.add(()=>myModel);
  Store.get<MyModel>(); // needed since addition is lazy.
  expect(myModel.initCalled, true);
}

void testDisposeOnRemove() {
  final myModel = MyModel();
  Store.add(()=>myModel);
  Store.get<MyModel>(); // needed since addition is lazy.
  Store.remove<MyModel>();
  expect(myModel.disposeCalled, true);
}

void testClear() {
  final modelRepository = TestStub.modelRepository;
  final modelBuilderRepository = TestStub.modelBuilderRepository;

  Store.add(() => TestModel());
  Store.get<TestModel>();
  expect(modelRepository.isNotEmpty, true);
  expect(modelBuilderRepository.isNotEmpty, true);
  Store.clear();
  expect(modelRepository.isEmpty, true);
  expect(modelRepository.isEmpty, true);
}



void testAddIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  Store.add(() => myModel, 'modelId');
  expect(TestStub.idModelRepository.containsKey(id), false);
  expect(TestStub.idModelBuilderRepository.containsKey(id), true);
  expect(myModel, Store.get(id));
  expect(TestStub.idModelRepository.containsKey(id), true);
}

void testAddEagerlyIdModel() {
  const id = 'modelId';
  Store.addEager(MyModel(), id);
  expect(TestStub.idModelRepository.containsKey(id), true);
}

void testGetIdModel() {
  const id = 'modelId';
  const anotherId = 'anotherModelId';
  Store.add(()=>MyModel(), id);
  expect(Store.get(id), isNot(null));
  Store.addEager(TestModel(), anotherId);
  expect(Store.get(anotherId), isNot(null));
}

void testRemoveIdModel() {
  const id = 'modelId';
  Store.add(()=>MyModel(), id);
  Store.get(id); // needed since addition is lazy.
  expect(Store.remove(id), isNot(null));
}

void testReplaceIdModel() {
  const id = 'modelId';
  Store.add(()=>MyModel(), id);
  Store.replace(()=>MyModel()..replaced=true, id);
  expect(Store.get<MyModel>(id)!.replaced, true);
}

void testInitOnAddIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  Store.add(()=>myModel, id);
  Store.get<MyModel>(id); // needed since addition is lazy.
  expect(myModel.initCalled, true);
}

void testDisposeOnRemoveIdModel() {
  final myModel = MyModel();
  const id = 'modelId';
  Store.add(()=>myModel, id);
  Store.get<MyModel>(id); // needed since addition is lazy.
  Store.remove(id);
  expect(myModel.disposeCalled, true);
}

void testClearIdModel() {
  final modelRepository = TestStub.idModelRepository;
  final modelBuilderRepository = TestStub.idModelBuilderRepository;

  const id = 'modelId';

  Store.add(() => TestModel(), id);
  Store.get<TestModel>(id);
  expect(modelRepository.isNotEmpty, true);
  expect(modelBuilderRepository.isNotEmpty, true);
  Store.clear();
  expect(modelRepository.isEmpty, true);
  expect(modelRepository.isEmpty, true);
}
