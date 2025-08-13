# Flutter Widgets

<!-- start doc template -->

## Template

### Documentation

### Properties

<!-- end doc template -->

## Padding

### Documentation

- https://api.flutter.dev/flutter/widgets/Padding-class.html

### Properties

- padding: EdgeInsets.all(16.0)

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

## Container

### Documentation & useful

- https://api.flutter.dev/flutter/widgets/Container-class.html

### Properties

- child
- color
- width
- height

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
