# Flutter Widgets

## BoxDecoration

### Documentation

- https://api.flutter.dev/flutter/painting/BoxDecoration-class.html

### Properties

- borderRadius: BorderRadius.circular(10.0)
- color: Colors.Blue
- border: Border.all(color: Colors.red, width: 2.0)

## Center

### Documentation

- https://api.flutter.dev/flutter/widgets/Center-class.html

### Properties

- child:

## Container

### Documentation & useful

- https://api.flutter.dev/flutter/widgets/Container-class.html

### Properties

- child
- color
- width
- height

## Padding

### Documentation

- https://api.flutter.dev/flutter/widgets/Padding-class.html

### Properties

- padding: EdgeInsets.all(16.0)
- child: Container()

### tips

**When to use:**  
Use `Padding` when you need to add empty space around a widget to separate it from other widgets or the edges of its parent.

**General tips:**

- Use `EdgeInsets.all(value)` for uniform padding on all sides.
- Use `EdgeInsets.symmetric(horizontal: x, vertical: y)` for horizontal and vertical padding.
- Use `EdgeInsets.only(left: x, top: y, right: z, bottom: w)` for custom padding on specific sides.
- Padding can be nested for more complex layouts, but avoid excessive nesting for performance.
- Consider using `Container` with the `padding` property as an alternative for simple cases.

## ListView

### Documentation

- https://api.flutter.dev/flutter/widgets/ListView-class.html

### Properties

- children[]
- scrollDirection: Axis.horizontal
- reverse: true
- shrinkWrap: true

### tips

**When to use:**  
Use `ListView` when you need a scrollable list of widgets, especially when the number of items might be dynamic or long.

**General tips:**

- Prefer `ListView.builder` for large or infinite lists to improve performance.
- Use `shrinkWrap: true` if the `ListView` is inside another scrollable widget.
- Set `physics: NeverScrollableScrollPhysics()` to disable scrolling if needed.
- Use `scrollDirection` to switch between vertical and horizontal lists.
- Use `reverse: true` to reverse the order of items.
- For complex items, consider extracting them into separate widgets.

## Scaffold

### Documentation

- https://api.flutter.dev/flutter/material/Scaffold-class.html

### Properties

- appBar: AppBar
- body: Container
- floatingActionButton: FloatingActionButton

## ElevatedButton

### Documentation

- https://api.flutter.dev/flutter/material/ElevatedButton-class.html

### Properties

- onPressed: () => {}
- child: Text("Button") | Icon(Icons.add)
- style: ElevatedButton.styleFrom(primary: Colors.blue)

## Text

### Documentation

- https://api.flutter.dev/flutter/widgets/Text-class.html

### Properties

- style: color, fontSiz
- textAlign: TextAlign.center
- overflow: TextOverflow.ellipsis
- maxLines: 2

## Row

### Documentation & useful

- https://api.flutter.dev/flutter/widgets/Row-class.html
- the main axis is horizontal, different from Column

### Properties

- children[]
- mainAxisAlignment: MainAxisAlignment(start, spaceBetween, center, end, spaceAround, spaceEvenly)
- crossAxisAlignment

## Column

### Documentation

- https://api.flutter.dev/flutter/widgets/Column-class.html

### Properties

- children[]
- mainAxisAlignment
- crossAxisAlignment
<!-- others -->

## Stack

### Documentation

- https://api.flutter.dev/flutter/widgets/Stack-class.html

### Properties

- alignment
- children[]

## Stateless Widget

### Documentation

- https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html

### Example of implementation:

```dart
class MyStatelessWidget extends StatelessWidget {
    final String message;

    const MyStatelessWidget({Key? key, required this.message}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Text(message);
    }
}
```

## Stateful Widget

### Documentation

- https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html

### Example of implementation:

```dart
class MyStatefulWidget extends StatefulWidget {
    final String title;

    const MyStatefulWidget({Key? key, required this.title}) : super(key: key);

    @override
    _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
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
                title: Text(widget.title),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text('You have pushed the button this many times:'),
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
                child: Icon(Icons.add),
            ),
        );
    }
}
```

## LinearProgressIndicator

### Documentation

- https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html

### Properties

- color: Colors.blue
- value: 0.5

## Image

### Documentation

- https://api.flutter.dev/flutter/widgets/Image-class.html

### Example of use

```dart
// From asset
Image.asset('assets/images/my_image.png')

// From network
Image.network('https://example.com/image.png')

// From file
import 'dart:io';
Image.file(File('/path/to/image.png'))

// From memory
Image.memory(myImageBytes)
```

## ClipRRect

### Documentation

- https://api.flutter.dev/flutter/painting/ClipRRect-class.html
- used when child does not inherit the BoxDecoration properties

### Properties

- borderRadius: BorderRadius.circular(10.0)
- child: Container()

## AnimatedOpacity

### Documentation

- https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html

### Properties

- opacity
- duration: Duration(seconds: 1)
- child: Container()

## SizedBox

### Documentation

- https://api.flutter.dev/flutter/widgets/SizedBox-class.html

### Tips

- Use `SizedBox` when you want to add empty space between widgets.

### Properties

- height
- width
- child

# App Organization

- root/assets/images: require to edit pubspec.yaml. assets: - assets/images
- root/lib/
- lib/components
- lib/screens
- main.dart

# Firebase

- BaaS
- CloudFirestore: what is? Database in the Cloud
- CloudStorage: what is? Storage in the Cloud

## Documentation

