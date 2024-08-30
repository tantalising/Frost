# Signal
Flutter signal provides a mechanism for communication between two entities. It is primarily
meant to be used as a state management solution. Although Signal is a simple and powerful way for
managing states, it is not limited to state management only. See the [Getting Started][#getting-started]
for a quick introduction. Do check out the [Detailed Introduction][#detailed-introduction] for advanced
usage and deeper understanding.

## Getting started

### Signal Model
Use [SignalModel] to create the data for your app. We will create a counter app.

```dart
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
### Signal Widget
Use [SignalWidget] for updating your ui when the data changes.
Fetch your model using [ModelStore.get] method which returns
a model of the given type or null if none found.

```dart
    SignalWidget(
      signal: CountModel.countChanged,
      model: CountModel(), // <-- provide the model so that we can get it using model store
      builder: () => Text(
      ModelStore.get<CountModel>()!.count.toString(),
      ),
    ),
```
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
        builder: () => Text(
        CountModel.get.count.toString(),
        ),
      ),
```

### Property Widget
Since the data is too small we can use [Property] to create our model.

```dart
final _count = 0.property;
// final _count = Property(0); or like this as well.
```

Use [PropertyWidget] for using this property in your app.

```dart
    PropertyWidget(
      property: _count,
      builder: () => Text(
        _count.value.toString(),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
```
Change the property value like this:

```dart
_count.value = 3;
```
For mutating the interior of more complex objects, use the [Property.update] method.

```dart
// make other changes outside. Just write the final value like this or even 
// pass an empty value if needed. The ui won't update without calling update
// if you just make changes to the underlying property value.
_count.update((value) { value.count = 2 });
```

## Detailed Introduction
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
Let's create a class AgePrinter that prints "Age changed" whenever the age changes.
We will create a method that will print the required string. Methods or functions which
are invoked in response to a signal are called _slot_. There's nothing special about them.
They are just regular functions which serves a specific purpose(Here responding to a signal).
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

We are now going to use the signal for state management purpose. Let's revisit the counter app
with StatefulWidget approach.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

We can see the problem here. There's no reason to include the floating action button inside the
StatefulWidget. Actually the only thing we need is the Text widget. But to access the setState
function the floating action button has to be included inside the stateful widget. It's hard to
modify state of a StatefulWidget from outside. We are going to improve this using signals. First
we will create a model for our app. The model class will hold the necessary data that will be used in the app.





