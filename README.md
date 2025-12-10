# Frost
Frost is a lightweight, highly performant, and signal-based state management solution for Flutter. 
It decouples your business logic from your UI using **Signals**, **Properties**, and a **Store** for
dependency injection.
With Frost focus on your logic, not on how to propagate state changes.


## Why Frost?
- **True decoupling** - Events flow without any component knowing about others
- **Zero boilerplate** - One line creates reactive state, one widget consumes it
- **Automatic tracking** - No manual subscriptions or registrations
- **Blazing fast** - Only rebuilds exactly what changed
- **Pure business logic** - Write testable Dart code with zero Flutter dependencies
- **Intuitive API** - If you can write Dart, you already know Frost

## Installation

```bash
flutter pub add frost
```
## Index

<details>
<summary><strong>Quick Start</strong></summary>

- [Quick Start: The Counter App](#quick-start-the-counter-app)

</details>

<details>
<summary><strong>Core Concepts</strong></summary>

- [Properties](#properties)
- [Watcher](#watcher)
- [Signals](#signals)

</details>

<details>
<summary><strong>Architecture: The Store</strong></summary>

- [Define a Model](#define-a-model)
- [Register the Model](#register-the-model)
- [Access the Model](#access-the-model)
- [Pro Tip: Model Accessors](#pro-tip-model-accessors)

</details>

<details>
<summary><strong>Tips & Tricks</strong></summary>

- [Conditional Rebuilding](#conditional-rebuilding)
- [Manual Property and Signal Connection](#manual-property-and-signal-connection)
- [Custom Reactive Getters](#custom-reactive-getters)
- [Widget Init and Dispose](#widget-init-and-dispose)
- [Handling Lists and Collections](#handling-lists-and-collections)
- [Multiple Models of Same Type](#multiple-models-of-same-type)

</details>

<details>
<summary><strong>Deep Dive: Signals & Slots</strong></summary>

- [What are they?](#what-are-they)
- [How it works](#how-it-works)
- [Passing Data](#passing-data)
- [Connection & Disconnection](#connection--disconnection)
- [Why use this?](#why-use-this)

</details>

## Quick Start: The Counter App

The easiest way to use Frost is with Properties and the Watcher widget.

```dart
import 'package:frost/frost.dart';

final count = 0.property;

// Anywhere in your app:
Watcher(
watch: (context) => Text('Count: ${count.value}'),
)
```
Update it from anywhere.

```
count.value++; // UI updates automatically

```


## Core Concepts

### Properties

A Property is a wrapper around a value that notifies listeners when it changes. You can create one 
from any variable using the .property extension.

```dart
final name = "Frost".property;
final isActive = false.property;

// Access the value
print('name is ${name.value}');

// Or like this
print('name is ${name()}');

// Update value
name.value = "Flutter";

// For mutable objects, use update to trigger notification
user.update((u) {
  u.age = 25;
});
```

### Watcher

The Watcher widget is the bridge between your data and your UI. 
It intelligently tracks which properties are accessed inside its 
watch builder and rebuilds only when those specific properties change.

```dart
Watcher(
  watch: (context) {
    // This widget will ONLY rebuild when 'username' changes.
    // It will NOT rebuild if 'age' changes, because we didn't access it here.
    return Text(user.value.username);
  },
)
```

### Signals

Signals are the underlying event mechanism of Frost. Use them when you want to broadcast an event 
that isn't necessarily a state change (like navigating to a new page or showing a Toast).

```dart
// Define a signal
final onLoginSuccess = Signal();

// Emit a signal
onLoginSuccess();

//You can listen to signals by providing them to widgets using Watcher's signal/signals parameters
//Or by binding them to some data in your model (Advanced: see 'custom reactive getters' in the tips and tricks section.)

// Rebuild widget when signal emits
Watcher(
  signal: onLoginSuccess, 
  watch: (context) => const Text("Logged in!"),
)
```
You can also connect signals to slots manually in constructor, init or any other suitable place 
depending on your need. For example, if you need to remove spam mails on request you can connect the
appropriate signal in your MailService.

```dart
class MailService extends Model { //models will be explained shortly.
  final spamRemovalRequested = Signal();
  
  @override
  init() {
    connect(spamRemovalRequested, removeSpams);
    // or like this. Don't do both. They are redundant.
    spamRemovalRequested.connect(removeSpams);
  }
  
  @override
  dispose() {
    disconnect(spamRemovalRequested, removeSpams);
    // or like this
    spamRemovalRequested.disconnect(removeSpams);
  }
  
  Slot removeSpams() {
    // remove spams.
  }
}
```

> [!Note]:
> Do not place signals and properties inside stateless widgets.
> Instead use a private global variable or the store.
> They do not work if placed inside stateless widgets.
> Do not use async functions as slots. They will not be awaited.
> Instead connect a sync slot and emit the signal after async function completes.

## Architecture: The Store

For larger apps, you shouldn't keep variables globally. Frost provides a Store to manage your Models
and Dependencies (Service Locator pattern).

### Define a Model

Extend Model to gain lifecycle hooks (init and dispose) and easier integration with the Store.

```dart
class AuthModel extends Model {
  final user = User().property;
  final userLoggedIn = Signal();

  void login() {
    // logic...
    user.value.name = loggedInUser;
    userLoggedIn();
  }
}

class MailService extends Model {
  Slot sendLoginMail() {
    // send mail here.
  }
}
```

### Register the Model

Add your models to the Store when your app starts. Models can be added in two ways.
* Lazy: created when first accessed
* eager: created as soon as they are added.

```dart
void main() {
  // Lazy (Recommended)
  Store.add(() => AuthModel());
  
  // Eager
  Store.addEager(MailSerivce());

  runApp(const MyApp());
}
```

### Access the Model
Retrieve the model anywhere in your app.

```dart
Watcher(
  watch: (context) => Text('user name is ${Store.get<AuthModel>().user().name}'),
  // mail will be sent automatically upon login after the signal is connected with the slot.
  onInit: () => connect(Store.get<AuthModel>().userLoggedIn, Store.get<MailService>().sendLoginMail)
  onDispose: () => disconnect(Store.get<AuthModel>().userLoggedIn, Store.get<MailService>().sendLoginMail)
),
```

OnInit and onDispose are best used for acquiring and releasing resources relevant to the widget.
```dart
final _controller = TextEditingController();
Watcher(
    onInit: () => _controller.addListener(myListener),
    onDispose: () => _controller.dispose();
    watch: (context) => TextField(
       controller: _controller,
       decoration: const InputDecoration(
            labelText: 'Type something',
            ),
       ),
),
```

### Pro Tip: Model Accessors

Add a static getter to your model for cleaner code when you are sure that the returned model can't 
be null.
```dart
class AuthModel extends Model {
  static AuthModel get get => Store.get<AuthModel>()!;
  // ...
}

// Usage:
AuthModel.get.login();
```

## Tips & Tricks
### Conditional Rebuilding

Sometimes you want a widget to rebuild only if a certain condition is met, even if the properties 
it watches have changed. Use the when parameter to control this.

```dart
Watcher(
// Only rebuild the UI if the new value is even
    when: () => count.value % 2 == 0,
    watch: (context) {
      return Text("Even Count: ${count.value}");
    },
)
```
### Manual Property and Signal Connection
You can connect to properties that aren't accessed inside watcher by manually supplying
them to the *signal* argument of the Watcher. Use *signals* argument to provide more than
one properties. Similarly you can connect to more than one signals using *signals* argument.
```dart
Watcher(
  signal: someSignal,
  signals: {signal1, signal2},
  property: someProperty,
  properties: {property1, property2},
  watch: () => SomeWidget(...),
),
```

### Custom Reactive Getters

If you are building a custom Model and want to create your own 
reactive variables (without using the Property wrapper), you can use the bind() method. 
This connects a private value and a signal to the Watcher's auto-subscription system.
This is for working more naturally inside model with data but the data should still be 
exposed like a property. 

```dart
class CounterModel extends Model {
    final _changeSignal = Signal();
    int _internalCount = 0;
    
    // Use bind() to associate _changeSignal with _internalCount automatically when
    // count is accessed inside watcher.
    int get count => bind(_internalCount, _changeSignal);
    
    void increment() {
        _internalCount++;
        _changeSignal(); // Watcher will detect this change without needing to provide the signal.
    }
}

// Use it like this
Watcher(
    //signal: _changedSignal, <-- no need to pass this, can't even be passed in this case because of being private.
    watch: (context) => Text(${CountModel.get.count}),
),
```

### Widget Init and Dispose

To do something (for example disposing a controller) when the Watcher is created and disposed, provide the callbacks.

```dart
Watcher(
  onInit: () => print('do something here'),
  onDispose: () => print('do something here'),
  watch: (context) => Container(),
),
```

### Handling Lists and Collections

When using List, Set, or Map inside a Property, simply modifying the list won't trigger an update 
because the list reference itself didn't change. Use .update():

```dart
final items = <String>[].property;

// This triggers the UI update
items.update((list) {
  list.add("New Item");
});
```

### Multiple Models of Same Type
The model store won't add a model if another model of same type already exists. To add(or get etc) model of
same type, you can use the same methods of Store. Just pass an additional unique string id to the
methods. Don't forget to pass the id when getting that model or performing any other operation on that model.

```dart
  Store.add(MyEagerModel());
  Store.add(MyEagerModel(), 'myId');
```

## Deep dive: Signals & Slots
Under the hood, Frost uses the Signal and Slot pattern. Understanding this
helps you realize why Frost is so decoupled.

### What are they?

Think of a Signal as a radio station and a Slot as a radio receiver.

    Signal (The Emitter): Something that says "Hey, this event happened!" (e.g., buttonClicked, dataLoaded, valueChanged).

    Slot (The Listener): A standard function that reacts to that event.

### How it works

Unlike other patterns where the Emitter knows about the Listener (e.g., addListener), 
in Frost, the Signal simply broadcasts. It doesn't care who is listening.

``` dart
// 1. Create a Signal (The Radio Station)
final onUserLoggedOut = Signal();

// 2. Define a Slot (The Listener Function)
Slot performCleanup() {
print("Cleaning up user data...");
}

// 3. Connect them
onUserLoggedOut.connect(performCleanup);

// 4. Emit the signal
onUserLoggedOut(); // Prints: "Cleaning up user data..."
```

### Passing Data

Signals can carry data payload.
```
// Signal that carries a String
final onMessageReceived = Signal();

// Slot that accepts a String
void showNotification(String message) {
print("New message: $message");
}

onMessageReceived.connect(showNotification);

// Emit with data
onMessageReceived("Hello World");
```

### Connection & Disconnection

You must disconnect slots when they are no longer needed to prevent memory leaks.

```
onMessageReceived.disconnect(showNotification);
```

### Why use this?

This pattern allows your Business Logic (Models) to simply emit 
signals ("I changed!", "Error occurred!") without knowing anything about the UI (Widgets). 
The UI simply connects to the signals it cares about.