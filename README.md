# Flutter Signal
Flutter signal provides a mechanism for communication between two entities. It is primarily
meant to be used as a state management solution. Although Signal is a simple and powerful way for
managing states, it is not limited to state management only.

## Installation
```dart
flutter pub add flutter_signal
```

## Contents:
- [Getting Started](#getting-started)
    - [Signal Model](#signal-model)
    - [Signal](#signal)
    - [Signal Widget](#signal-widget)
    - [Model Accessor](#model-accessor)
    - [Property Widget](#property-widget)
- [Tips](#Tips)
  - [Eager Model](#eager-model)
  - [Multiple Model of Same Type](#multiple-model-of-same-type)
  - [Bulk Addition of Model](#bulk-addition-of-model)
  - [Model Init and Dispose](#model-init-and-dispose)
  - [General Slot Usage](#general-slot-usage)
  - [Widget Init and Dispose](#widget-init-and-dispose)
- [Detailed Explanation of Signals](#detailed-explanation-of-signals)
  - [Signal](#signal)
  - [Slot](#slot)
  - [Connecting Signals](#connecting-signals)
  - [Passing Arguments to Signals](#passing-arguments-with-signals)
  - [Disconnecting Signals](#disconnecting-signals)

## Getting started

### Signal Model

Use [SignalModel] to create the data for your app. We will create a counter app.

```dart
import 'package:flutter_signal/signal_model.dart';
class CountModel extends SignalModel {
     void incrementCount() {
       _counter++;
     }
     int get count => _counter;
     int _counter = 0;
}
```
### Signal

Use [Signal] for notifying the ui about data changes so that it can update itself.
Emit the signal when data in model changes.

```dart
class CountModel extends SignalModel {
     static final countChanged = Signal(); // <-- create a signal

     void incrementCount() {
       _counter++;
       countChanged(); // <-- notify about change.
     }
     int get count => _counter;
     int _counter = 0;
}
```

> [!Note]:
> Do not place signals inside stateless widgets.
> Instead use a private global variable.
> Signals do not work if placed inside stateless widgets.

### Signal Widget

Use [SignalWidget] for updating your ui when the data changes.
Fetch your model using [ModelStore.get] method which returns
a model of the given type or null if none found.

```dart
    import 'package:flutter_signal/signal_widget.dart';
    SignalWidget(
      signal: CountModel.countChanged,
      model: CountModel(), // <-- provide the model so that we can get it using model store
      builder: (_) => Text(
      ModelStore.get<CountModel>()!.count.toString(),
      ),
    ),
```
Another widget needing the same model doesn't need to provide the model again once it is added to store.

```dart
  SignalWidget(
    signal: CountModel.changed,
    builder: (_) => Text (ModelStore.get<CountModel>()!.count.toString()),
)
```

Remove the model from the store when no longer needed using ModelStore.remove method.

```dart
ModelStore.remove<CountModel>()
```
> [!Note]:
> To connect the widget to more than one signal
> use the [SignalWidget.signals] argument which takes a set of signals
> instead of signal.

### Model Accessor

Consider using a model accessor in the model class for shorter access of models.
```dart
class CountModel extends SignalModel {
     static final countChanged = Signal();

    //model Accessor
     static CountModel get get {
       final model = ModelStore.get<CountModel>();
       if(model == null) {
         throw("CountModel not found");
       }
       return model;
     }

     void incrementCount() {
       _counter++;
       countChanged();
     }
     int get count => _counter;
     int _counter = 0;
}
```

Now use it as follows:

```dart
      SignalWidget(
        signal: CountModel.countChanged,
        model: CountModel(),
        builder: (_) => Text(
        CountModel.get.count.toString(), // shorter access
        ),
      ),
```


### Property Widget

Since the data is too small we can use [Property] to create our model.

```dart
import 'package:flutter_signal/property.dart';
final _count = 0.property;
// final _count = Property(0); or like this as well.
```

Use [PropertyWidget] for using this property in your app.

```dart
    PropertyWidget(
      property: _count,
      builder: (_) => Text(
        _count.value.toString(),
      ),
    ),
```
Change the property value like this:

```dart
_count.value = 3;
```
In this case the previous value 0 is replaced with 3. If we want to instead modify the
object stored in the property, then we have to use the [Property.update] method.

```dart
// we'll modify this object...
 class BigValue {
  int valueFieldOne = 0;
  String valueFieldTwo = '';
  int valueForFieldOne() {
    return 3;
  }
}
// create property
final bigValue = BigValue().property;
// pretend to do some necessary stuff 
final intValue = bigValue.value.valueForFieldOne();
// this will update the ui
bigValue.update((value) {
  value.valueFieldOne = intValue;
});
// directly modifying won't update the ui 
bigValue.value.valueFieldOne = bigValue.value.valueForFieldOne();
//.. though calling an empty update now will update it (not recommended to update like this)
bigValue.update((_)=>(_));

// don't perform additional operation inside update. Just pass the final value.
bigValue.update((value) {
  final intValue = value.valueForFieldOne; // bad. Should be done outside.
  value.valueFieldOne = intValue;
})
```
> [!Note]:
> To update the ui when more than one property changes,
> use the properties argument which takes a set of properties instead of one property.

That's all we need for state management! Now read the tips(they are interesting!) and if you want to know more 
about signals, check the [Detailed Explanation of Signals](#detailed-explanation-of-signals) section.

## Tips

### Eager Model
By default all the models added to the store are not created until first usage. To create a model as
soon as it is added to the store, use [ModelStore.addEager].

```dart
  ModelStore.addEager(MyEagerModel());
```

### Multiple Model of Same Type
The model store won't add a model if another model of same type already exists. To add(or get etc) model of
same type, you can use the same methods of ModelStore. Just pass an additional unique string id to the
methods. Don't forget to pass the id when getting that model or performing any other operation on that model.

```dart
  ModelStore.add(MyEagerModel());
  ModelStore.add(MyEagerModel(), 'myId');
```

### Bulk Addition of Model
You can bulk add all the necessary models lazily(or not lazily) before your is app is run. 
In this way, you will never need to provide a model to the SignalWidget and/or think about whether a 
model already exists while using a SignalWidget.

```dart
void main() {
  ModelStore.add(() => Model());
  ModelStore.add(() => AnotherModel());
  ModelStore.addEager(EagerModel());
  ModelStore.addEager(AnotherEagerModel());
  runApp(const MyApp());
}
```
If you are sure that the model is indeed in the store, the model accessor can be much shorter.

```dart
static MyModel get get => ModelStore.get()!;
```

### Model Init and Dispose
Implement the init and dispose method in your model to do some work when the model is added to
or removed from the model store. 

```dart
class CountModel extends SignalModel {
 // other stuffs ...
  @override
  void init() {
    // this method will be called when the model is first accessed from the store.
    super.init();
  }
  @override
  void dispose() {
    // this method will be called when the model is removed from the store.
    super.dispose();
  }
}
```
### General Slot Usage
To do something other than ui change when a signal is emitted, connect the signal to a slot that
does the desired job. You may connect to the methods in the same class as well!

```dart
Slot doSomething() {
  print('doing something');
}
connect(CountModel.countChanged, doSomething)
```
Disconnect the signal from the slot when no longer needed.

```dart
disconnect(CountModel.countChanged, doSomething)
```

### Widget Init and Dispose
To do something(for example disposing a controller) when the SignalWidget is created and disposed, provide two callbacks named
onInit and onDispose. Same is available for PropertyWidget as well.

```dart
SignalWidget(
  onInit: () => print('do something here'),
  onDispose: () => print('do something here'),
  //... other stuffs
  ),
```

## Detailed Explanation of Signals

### Signal
Let's assume a class Person with an age attribute wants to notify when its age changes. This is how
the class look:
```dart
class Person {
  Person(this._age);
  int _age;
  int get age => _age;
  set age(int newAge) => _age = newAge;
}

```
We are going to create a _signal_ that will notify other interested entities about the change.

```dart
class Person {
  static final ageChanged = Signal(); // <-- here. static for ease of use.
  Person(this._age);
  int _age;
  int get age => _age;
  set age(int newAge) => _age = newAge;
}

```

### Signal Emission
Now we need to _emit_ the signal whenever the age changes.

```dart
class Person {
  static final ageChanged = Signal();
  Person(this._age);
  int _age;
  int get age => _age;
  set age(int newAge) {
    _age = newAge;
    ageChanged(); // <-- signal emitted;
  }
}
```

### Slot
Let's create a class AgePrinter that prints "Age changed" whenever the age changes.
We will create a method that will print the required string. Methods or functions which
are invoked in response to a signal are called _slot_. There's nothing special about them.
They are just regular functions which serve a specific purpose(Here responding to a signal).
Here's how the class looks:

```dart
class AgePrinter {
  Slot printUpdateMessage() {
    print("Age Updated");
  }
}
```
> Note:
> _Slot_ is just a typedef for void. 
> It is used to highlight that the method is intended to be used as a slot.

### Connecting Signals

We need to _connect_ the signal to our slot to make this work.

```dart
  void main() {
    final person = Person(30);
    final printer = AgePrinter();

    Person.ageChanged.connect(printer.printUpdateMessage);
    //connect(Person.ageChanged, printer.printUpdateMessage); <- or like this as well
    person.age = 12;
  }
```
This will print "Age Updated" when run. 
This is good but doesn't print the age of the person. In order to do so, we need to pass the
age with the signal.

### Passing Arguments with Signals

```dart
class Person {
  static final ageChanged = Signal();
  Person(this._age);
  int _age;
  int get age => _age;
  set age(int newAge) {
    _age = newAge;
    ageChanged(newAge); // <-- passing the age here;
  }
}
```
To print the age passed by signal, we need to update the slot syntax as well. We are going to take
the age as a parameter in the slot.

```dart
class AgePrinter {
  Slot printUpdateMessage(int age) {
    print("Age Updated. New age is $age");
  }
}
```

Running the code now would print "Age updated. New age is 12". 

### Disconnecting Signals

It is necessary to _disconnect_ the slot when no longer needed in order to avoid undesired
calls to slots or calls to non-existent slots.

We can disconnect using a similar syntax. Just replace the connect with disconnect.
Let's assume we don't want to print the message if the last printed age is 100. 

```dart
class AgePrinter {
  Slot printUpdateMessage(int age) {
    print("Age Updated. New age is $age");
    if(age == 100) {
      Person.ageChanged.disconnect(printUpdateMessage); //<-- disconnect here
      //disconnect(Person.ageChanged, printUpdateMessage); <-- or like this
    }
  }
}

  void main() {
    final person = Person(30);
    final printer = AgePrinter();

    Person.ageChanged.connect(printer.printUpdateMessage);
    person.age = 19;
    person.age = 99;
    person.age = 100;
    person.age = 12; // <-- no response for this code
  }
```
As you can see, running the code won't print the new age after the age has become 100 once.




