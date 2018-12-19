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
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
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
    List<Widget> intWidgets = [
      Padding(
        padding: const EdgeInsets.all(8.0).copyWith(bottom: 4.0),
        child: new Text("\$",
            style: Theme.of(context).textTheme.headline.copyWith(
                  color: themeData.accentColor,
                )),
      ),
    ];
    for (var i = 0; i < numSize; i++) {
      intWidgets.add(new NumberPicker.multi(
        itemExtent: 30,
        integerListViewWidth: 30,
        initialValue: _currentIntValues[i],
        onChanged: (num value) {
          setState(() {
            _currentIntValues[i] = value;

            int pow = 1;
            num newCurrentValue = 0;
            for (var j = numSize - 1; j >= 0; j--) {
              newCurrentValue += pow * _currentIntValues[j];
              pow *= 10;
            }
            _currentIntValue = newCurrentValue;
          });
        },
      ));

      if (i != numSize - 1) {
        intWidgets.add(new Container(
          height: 30.0,
          width: 1.0,
          color: Colors.black12,
          margin: const EdgeInsets.only(left: 2.0, right: 2.0),
        ));
      }
    }

    decimalNumberPicker = new NumberPicker.decimal(
        itemExtent: 25,
        integerListViewWidth: 45,
        decimalListViewWidth: 40,
        initialValue: _currentDoubleValue,
        minValue: 0,
        maxValue: 100,
        decimalPlaces: 2,
        suffixText: "%",
        onChanged: _handleValueChanged);

    Color middleColor = const Color(0x00ffffff);
    Color edgeColor = themeData.scaffoldBackgroundColor;
    Color mixedColor = Color.lerp(middleColor, edgeColor, 0.75);
    Color mixedColor2 = Color.lerp(middleColor, edgeColor, 0.90);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      edgeColor,
                      mixedColor2,
                      mixedColor,
                      middleColor,
                      middleColor,
                      mixedColor,
                      mixedColor2,
                      edgeColor,
                    ],
                  ),
                ),
                child: new Row(
                  children: intWidgets.toList(),
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              new Text("${currencyFormat.format(_currentIntValue)}",
                  style: themeData.textTheme.headline),
              Container(
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      edgeColor,
                      mixedColor2,
                      mixedColor,
                      middleColor,
                      middleColor,
                      mixedColor,
                      mixedColor2,
                      edgeColor,
                    ],
                  ),
                ),
                child: decimalNumberPicker,
              ),
              new Text(rateFormat.format(_currentDoubleValue / 100.0),
                  style: themeData.textTheme.headline),
            ],
          ),
        ));
  }
}
