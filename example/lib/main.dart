import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(new ExampleApp());
}

var currencyFormat = new NumberFormat.simpleCurrency(
  locale: 'en_US',
  name: 'USD',
  decimalDigits: 0,
);

var rateFormat = new NumberFormat("##0.00%", "en_US");

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NumberPicker Example',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
      ),
      home: new MyHomePage(title: 'NumberPicker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIntValue = 0;
  double _currentDoubleValue = 3.0;
  NumberPicker integerNumberPicker;
  NumberPicker decimalNumberPicker;
  List<int> _currentIntValues = [];
  final int numSize = 7;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < numSize; i++) {
      _currentIntValues.add(0);
    }
  }

  _handleValueChanged(num value) {
    if (value != null) {
      if (value is int) {
        setState(() => _currentIntValue = value);
      } else {
        setState(() => _currentDoubleValue = value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    List<Color> gradient = generateGradient(
        themeData.scaffoldBackgroundColor.withAlpha(0),
        themeData.scaffoldBackgroundColor);

    Widget ratePicker =
        buildRatePicker(gradient, _currentDoubleValue, _handleValueChanged);

    bool light = true;
    Widget multiPicker = new MultiPicker(
      digits: 7,
      onChanged: _handleValueChanged,
      prefixText: "\$",
      dividerColor: light ? Colors.black12 : Colors.white70,
    );

    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title)),
        body: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              multiPicker,
              new Text("${currencyFormat.format(_currentIntValue)}",
                  style: themeData.textTheme.headline),
              ratePicker,
              new Text(rateFormat.format(_currentDoubleValue / 100.0),
                  style: themeData.textTheme.headline),
            ])));
  }
}

List<Color> generateGradient(Color middleColor, Color edgeColor) {
  Color mixedColor = Color.lerp(middleColor, edgeColor, 0.75);
  Color mixedColor2 = Color.lerp(middleColor, edgeColor, 0.90);
  return [
    edgeColor,
    mixedColor2,
    mixedColor,
    middleColor,
    middleColor,
    mixedColor,
    mixedColor2,
    edgeColor,
  ];
}

Widget buildRatePicker(List<Color> gradient, double currentValue,
    ValueChanged<num> handleValueChanged) {
  NumberPicker numberPicker = new NumberPicker.decimal(
      itemExtent: 25,
      integerListViewWidth: 45,
      decimalListViewWidth: 40,
      initialValue: currentValue,
      minValue: 0,
      maxValue: 100,
      decimalPlaces: 2,
      suffixText: "%",
      onChanged: handleValueChanged);

  return Container(
    foregroundDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradient,
      ),
    ),
    child: numberPicker,
  );
}

class MultiPicker extends StatefulWidget {
  MultiPicker(
      {Key key,
      @required this.digits,
      @required this.onChanged,
      this.suffixText = "",
      this.prefixText = "",
      this.dividerColor = Colors.black12})
      : super(key: key);

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  /// Number of digits for multi picker
  final int digits;

  /// Prefix text
  final String prefixText;

  /// Suffix text
  final String suffixText;

  final Color dividerColor;

  @override
  _MultiPickerState createState() => new _MultiPickerState();
}

class _MultiPickerState extends State<MultiPicker> {
  List<int> _currentIntValues = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < this.widget.digits; i++) {
      _currentIntValues.add(0);
    }
  }

  ValueChanged<num> onListChanged(int index) {
    return (num value) {
      setState(() {
        _currentIntValues[index] = value;

        int pow = 1;
        num newCurrentValue = 0;
        for (var j = this.widget.digits - 1; j >= 0; j--) {
          newCurrentValue += pow * _currentIntValues[j];
          pow *= 10;
        }

        this.widget.onChanged(newCurrentValue);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    List<Widget> childWidgets = [];

    // Insert prefix text
    if (this.widget.prefixText != "") {
      childWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 4.0),
          child: new Text(this.widget.prefixText,
              style: Theme.of(context).textTheme.headline.copyWith(
                    color: themeData.accentColor,
                  ))));
    }

    Container verticalDivider = new Container(
      height: 85,
      width: 1.0,
      color: this.widget.dividerColor,
      margin: const EdgeInsets.only(left: 1.0, right: 1.0),
    );
    for (var i = 0; i < this.widget.digits; i++) {
      childWidgets.add(new NumberPicker.multi(
        itemExtent: 30,
        integerListViewWidth: 30,
        initialValue: _currentIntValues[i],
        onChanged: onListChanged(i),
      ));

      if (i != this.widget.digits - 1) {
        childWidgets.add(verticalDivider);
      }
    }

    // Insert prefix text
    if (this.widget.suffixText != "") {
      childWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: 4.0),
          child: new Text(this.widget.suffixText,
              style: Theme.of(context).textTheme.headline.copyWith(
                    color: themeData.accentColor,
                  ))));
    }

    List<Color> gradient = generateGradient(
        themeData.scaffoldBackgroundColor.withAlpha(0),
        themeData.scaffoldBackgroundColor);

    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
      ),
      child: new Row(
        children: childWidgets.toList(),
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
