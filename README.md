# Reactor
This package allows you to implement the BLoC pattern easily in your projects.

## Features
- Initialize a Bloc with an initial state.
- Stream states and manage state transitions.
- Register event handlers for specific events.
- Add events for processing.
- Close the Bloc and release resources.
- Rebuild widgets when state changes.
- Observe specific states.

## Installation
Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  reactor:
    git:
      url: https://github.com/chrisr04/reactor
      ref: v0.0.4
 ```

## Usage
### Creating a Bloc

To create a Bloc, extend the `Bloc` class and provide event and state types. Implement event handlers and register them in the constructor.

```dart
// Define your events
sealed class CounterEvent {}

final class IncrementEvent extends CounterEvent {}

final class DecrementEvent extends CounterEvent {}

//Define your states
sealed class CounterState {
  const CounterState(this.counter);
  final int counter;
}

final class InitialState extends CounterState {
  const InitialState(super.counter);
}

final class IncrementState extends CounterState {
  const IncrementState(super.counter);
}

final class DecrementState extends CounterState {
  const DecrementState(super.counter);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const InitialState(0)) {
    // Register your events
    register<IncrementEvent>(_onIncrementEvent);
    register<DecrementEvent>(_onDecrementEvent);
  }

  void _onIncrementEvent(
    IncrementEvent event,
    Emitter<CounterState> emit,
  ) {
    emit(IncrementState(state.counter + 1));
  }

  void _onDecrementEvent(
    DecrementEvent event,
    Emitter<CounterState> emit,
  ) {
    emit(DecrementState(state.counter - 1));
  }
}
```

### Adding Events
To add an event for processing, use the `add` method. Ensure the event is registered with an event handler.

```dart
final counterBloc = CounterBloc();
counterBloc.add(IncrementEvent());
```

### Listening to State Changes
Listen to the state stream and react to state changes.

```dart
final subscription = counterBloc.stream.listen((state) {
  // Handle state change
});

// Call it when you want to stop listening
subscription.cancel();
```

### Closing the Bloc
Close the Bloc to release resources.

```dart
await counterBloc.close();
```

### Bloc Widgets
This package provides some widgets that make interacting with Bloc easier.

### ReactorWidget
An abstract class that simplifies the creation of a Widget which reacts to changes in a Bloc state. The `ReactorWidget` class is designed to help manage state and UI updates efficiently in applications using the Bloc pattern.

By extending ReactorWidget, developers can focus on handling state changes while relying on built-in hooks for initialization, observing state transitions, and controlling when the widget should rebuild. This abstraction reduces boilerplate code and streamlines the development process.

**Basic usage**

```dart
class MyCounterWidget extends ReactorWidget<CounterBloc, CounterState> {
  MyCounterWidget({super.key});

  @override
  CounterBloc? blocDependency(BuildContext context) {
    return CounterBloc(initialValue);
  } 

  @override
  void init(CounterBloc bloc) {
    bloc.add(IncrementEvent());
  }

  @override
  Widget build(BuildContext context, MyState state) {
    return Column(
      childern: [
        Text('Counter: ${state.value}'),
        MaterialButton(
          child: const Icon(Icons.add),
          onPressed: () {
            final bloc = getBloc(context);
            bloc.add(IncrementEvent());
          },
        ),
        MaterialButton(
          child: const Icon(Icons.add),
          onPressed: () {
            final bloc = getBloc(context);
            bloc.add(DecrementEvent());
          },
        ),
      ]
    );
  }
}
```

**Note:** It's not necessary override the `blocDependency` every time, we recommend adding it to the highest widget in our view if we want to consume the Bloc in other widgets.

**Advanced usage**

```dart
class MyCounterWidget extends ReactorWidget<CounterBloc, CounterState> {
  MyCounterWidget({super.key});

  @override
  CounterBloc? blocDependency(BuildContext context) {
    return CounterBloc(initialValue);
  } 

  @override
  bool observeWhen(CounterState previous, CounterState current) {
    // Observer function will be called when the value is equal to 100
    return current.value == 100;
  }

  @override
  void observer(BuildContext context, CounterState state) {
    // Perform side effects, like logging or navigation
    Navigator.of(context).pushNamed('/secondPage');
  }

  @override
  bool buildWhen(CounterState previous, CounterState current) {
    // Only rebuild when the value is greather than 5
    return current.value > 5;
  }

  @override
  Widget build(BuildContext context, MyState state) {
    return Column(
      childern: [
        Text('Counter: ${state.value}'),
        MaterialButton(
          child: const Icon(Icons.add),
          onPressed: () {
            final bloc = getBloc(context);
            bloc.add(IncrementEvent());
          },
        ),
        MaterialButton(
          child: const Icon(Icons.add),
          onPressed: () {
            final bloc = getBloc(context);
            bloc.add(DecrementEvent());
          },
        ),
      ]
    );
  }
}
```

**Note:** If you don't want the widget to be rebuilt you can override the `observeOnly` getter.

### BlocInjector
Provides a convenient way to inject and manage `Bloc` instances in the widget tree. It also ensures the `Bloc` is properly disposed of when no longer needed.

**Basic usage**

```dart
BlocInjector<MyBloc>(
  bloc: MyBloc(),
  child: MyChildWidget(),
);
```

To get injected instance you can use:

```dart
BlocInjector.of<MyBloc>(context);
```

or

```dart
context.get<MyBloc>();
```

**Advanced usage**

If you don't need an automatic Bloc disposing when the widget is disposed set `closeOnDispose` to `false`.

```dart
BlocInjector<MyBloc>(
  bloc: MyBloc(),
  closeOnDispose: false,
  child: MyChildWidget(),
);

await BlocInjector.of<MyBloc>(context).close();
```
**Note:** Don't forget to call `close()` when the Bloc is no longer needed.

### BlocBuilder
The `BlocBuilder` widget listens to the state changes of a `Bloc` and rebuilds its widget tree using the provided `builder` function whenever a new state is emitted. The rebuilds can be filtered by the optional `buildWhen` function. This is useful for creating reactive UIs where the UI depends on the state of a `Bloc`.

**Basic usage**

This rebuilds the widget on every state emitted.

```dart
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return Text('Count: ${state.counter}');
  },
);
```


**Advanced usage**

This rebuilds the widget only when `IncrementState` is emitted.

```dart
BlocBuilder<CounterBloc, CounterState>(
  buildWhen: (previousState, currentState) => currentState is IncrementState,
  builder: (context, state) {
    return Text('Count: ${state.counter}');
  },
);
```

### BlocObserver
 A widget that observes to state changes in a `Bloc` and invokes a `observer` callback whenever the Bloc's state changes. The `BlocObserver` widget should be used for any code which needs to execute in response to a state change, such as navigation, showing a `SnackBar`, showing a `Dialog`, etc.
 
**Basic usage**

This call the listener on every state emitted.

```dart
BlocObserver<CounterBloc, CounterState>(
  observer: (context, state) {
    if(state is IncrementState){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Counter: $state')),
      );
    }
  },
  child: MyChildWidget(),
);
```

**Advanced usage**

This call the `observer` callback only when `IncrementState` is emitted.

```dart
BlocObserver<CounterBloc, CounterState>(
  observeWhen: (previousState, currentState) => currentState is IncrementState,
  observer: (context, state) {
    if(state is IncrementState){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Counter: $state')),
      );
    }
  },
  child: MyChildWidget(),
);
```

### BlocReactor
A widget that combines a `BlocObserver` and a `BlocBuilder` to simplify state management and UI rebuilding based on `Bloc` state changes.

**Basic usage**

This rebuilds the widget and call the `observer` callback on every state emitted.

```dart
BlocReactor<CounterBloc, CounterState>(
  observer: (context, state) {
    if (state.count > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Count is greater than 10!')),
      );
    }
  },
  builder: (context, state) {
    return Center(
      child: Text('Count: ${state.count}'),
    );
  },
);
```

**Advanced usage**

This call the `observer` callback only when `DecrementState` is emitted and rebuilds the widget only when `IncrementState` is emitted.

```dart
BlocReactor<CounterBloc, CounterState>(
  observeWhen: (previousState, currentState) => currentState is DecrementState,
  observer: (context, state) {
    if (state.count > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Count is greater than 10!')),
      );
    }
  },
  buildWhen: (previousState, currentState) => currentState is IncrementState,
  builder: (context, state) {
    return Center(
      child: Text('Count: ${state.count}'),
    );
  },
);
```

### MultiBlocInjector
A `MultiBlocInjector` is a widget that merges multiple `BlocInjector` injectors into a single widget tree. This is particularly useful for injecting multiple Blocs into the widget tree at a higher level, thereby making them available throughout the subtree.

**Basic usage**

```dart
MultiBlocInjector(
  injectors: [
    BlocInjector<MyBlocA>(
      bloc: MyBlocA(),
    ),
    BlocInjector<MyBlocB>(
      bloc: MyBlocB(),
    ),
  ],
  child: MyChildWidget(),
);
```

### MultiBlocObserver
`MultiBlocObserver` is a convenience widget that allows you to listen to multiple Blocs in a single location. It is commonly used in scenarios where you need to react to changes from multiple Blocs and perform actions such as navigation, showing dialogs, or updating the UI.

**Basic usage**

```dart
MultiBlocObserver(
  observers: [
    BlocObserver<BlocA, BlocAState>(
      observer: (context, state) {
        // Handle BlocA state changes
      },
    ),
    BlocObserver<BlocB, BlocBState>(
      observer: (context, state) {
        // Handle BlocB state changes
      },
    ),
  ],
  child: MyChildWidget(),
);
```
