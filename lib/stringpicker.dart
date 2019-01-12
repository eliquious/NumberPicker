import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created by Max Franks

class StringPickerItem {
  final String label;
  final int value;

  StringPickerItem(this.label, this.value);
}

///NumberPicker is a widget designed to pick a number between #minValue and #maxValue
class StringPicker extends StatelessWidget {
  ///height of every list element
  static const double DEFAULT_ITEM_EXTENT = 25.0;

  ///constructor for integer number picker
  StringPicker.list({
    Key key,
    @required int initialValue,
    @required this.values,
    @required this.onChanged,
    this.itemExtent = DEFAULT_ITEM_EXTENT,
    this.listViewWidth = 120,
    this.suffixText = "",
    this.rowAlignment = MainAxisAlignment.center,
  })  : assert(initialValue != null),
        assert(values != null),
        selectedValue = initialValue,
        intScrollController = new ScrollController(
          initialScrollOffset: indexOf(values, initialValue) * itemExtent,
        ),
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  ///height of every list element in pixels
  final double itemExtent;

  /// List of values in picker
  final List<StringPickerItem> values;

  ///view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  ///width of integer (and whole number) list view in pixels
  final double listViewWidth;

  ///ScrollController used for integer list
  final ScrollController intScrollController;

  ///Currently selected integer value
  final int selectedValue;

  /// suffixText adds text after the list elements
  final String suffixText;

  final MainAxisAlignment rowAlignment;
  //
  //----------------------------- PUBLIC ------------------------------
  //

  static int indexOf(List<StringPickerItem> values, int value) {
    for (int i = 0; i < values.length; i++) {
      if (values[i].value == value) {
        return i;
      }
    }
    return 0;
  }

  animateInt(int valueToSelect) {
    int index = indexOf(values, valueToSelect);
    _animate(intScrollController, index * itemExtent);
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    TextStyle selectedStyle =
        themeData.textTheme.headline.copyWith(color: themeData.accentColor);

    // Row children
    List<Widget> rowChildren = <Widget>[
      _integerListView(themeData),
    ];

    // Add suffix if needed
    if (suffixText != "") {
      // Suffix text widget
      rowChildren.add(new Align(
        alignment: Alignment.center,
        child: new Text(suffixText, style: selectedStyle),
      ));
    }

    return new Row(
      children: rowChildren.toList(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _integerListView(ThemeData themeData) {
    TextStyle defaultStyle =
        themeData.textTheme.title.copyWith(fontWeight: FontWeight.w300);
    TextStyle selectedStyle =
        themeData.textTheme.headline.copyWith(color: themeData.accentColor);

//    int itemCount = (maxValue - minValue) ~/ step + 3;
    int itemCount = values.length + 2;

    Widget listView = new ListView.builder(
      physics: new BouncingScrollPhysics(),
      controller: intScrollController,
      itemExtent: itemExtent,
      itemCount: itemCount,
      cacheExtent: _calculateCacheExtent(itemCount),
      itemBuilder: (BuildContext context, int index) {
        bool isExtra = index == 0 || index == itemCount - 1;
        StringPickerItem item = new StringPickerItem("", values[0].value);

        if (!isExtra) {
          item = values[index - 1];
        }

        //define special style for selected (middle) element
        final TextStyle itemStyle =
            item.value == selectedValue ? selectedStyle : defaultStyle;

        return isExtra
            ? Container()
            : new Center(
                child: new Align(
                  alignment: Alignment.centerLeft,
//                  child: new Text(value.toString(), style: itemStyle),
                  child: new Text(item.label, style: itemStyle),
                ),
              );
      },
    );

    return new NotificationListener(
      child: new Container(
        height: _listViewHeight,
        width: listViewWidth,
        child: listView,
      ),
      onNotification: _onIntegerNotification,
    );
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  int _intValueFromIndex(int index) {
    if (index == 0) {
      return values[0].value;
    } else if (index > values.length) {
      return values[values.length - 1].value;
    }

    // minValue + (index - 1) * step
    return values[index - 1].value;
  }

  bool _onIntegerNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //calculate
      int intIndexOfMiddleElement =
          (notification.metrics.pixels + _listViewHeight / 2) ~/ itemExtent;
      int intValueInTheMiddle = _intValueFromIndex(intIndexOfMiddleElement);
      intValueInTheMiddle = _normalizeIntegerMiddleValue(intValueInTheMiddle);

      if (_userStoppedScrolling(notification, intScrollController)) {
        //center selected value
        animateInt(intValueInTheMiddle);
      }

      //update selection
      if (intValueInTheMiddle != selectedValue) {
        //return integer value
        num newValue = (intValueInTheMiddle);

        onChanged(newValue);
      }
    }
    return true;
  }

  ///There was a bug, when if there was small integer range, e.g. from 1 to 5,
  ///When user scrolled to the top, whole listview got displayed.
  ///To prevent this we are calculating cacheExtent by our own so it gets smaller if number of items is smaller
  double _calculateCacheExtent(int itemCount) {
    double cacheExtent = 250.0; //default cache extent
    if ((itemCount - 2) * DEFAULT_ITEM_EXTENT <= cacheExtent) {
      cacheExtent = ((itemCount - 3) * DEFAULT_ITEM_EXTENT);
    }
    return cacheExtent;
  }

  ///When overscroll occurs on iOS,
  ///we can end up with value not in the range between [minValue] and [maxValue]
  ///To avoid going out of range, we change values out of range to border values.
  int _normalizeMiddleValue(int valueInTheMiddle, int min, int max) {
    return math.max(math.min(valueInTheMiddle, max), min);
  }

  int _normalizeIntegerMiddleValue(int integerValueInTheMiddle) {
    //make sure that max is a multiple of step

    int max = values[values.length - 1].value;
    int min = values[0].value;

    return max > min
        ? _normalizeMiddleValue(integerValueInTheMiddle, min, max)
        : _normalizeMiddleValue(integerValueInTheMiddle, max, min);
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(
      Notification notification, ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  ///scroll to selected value
  _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
  }
}
