import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailScreen extends StatefulWidget {
  final int? hour;
  final int? minutes;

  const DetailScreen({Key? key, this.hour, this.minutes}) : super(key: key);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: AspectRatio(
        aspectRatio: 1.7,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: Color(0xff2c4260),
          child: _BarChart(hour: widget.hour,minutes: widget.minutes,),
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final int? hour;
  final int? minutes;

  const _BarChart({Key? key, this.hour, this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        alignment: BarChartAlignment.spaceAround,
        maxY: minutes!.toDouble(),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: EdgeInsets.all(0),
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(rod.y.round().toString(), TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: SideTitles(
      showTitles: true,
      getTextStyles: (context, value) => TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      margin: 20,
      getTitles: (double value) {
        switch (value.toInt()) {
          case 0:
            return '$hour';
          default:
            return '';
        }
      },
    ),
    leftTitles: SideTitles(
      showTitles: true,
      getTextStyles: (context,value)=>TextStyle(
        color: Colors.white
      )
    ),
    topTitles: SideTitles(showTitles: false),
    rightTitles: SideTitles(showTitles: false),
  );

  FlBorderData get borderData => FlBorderData(
    show: false,
  );

  List<BarChartGroupData> get barGroups => [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(y: minutes!.toDouble(), colors: [Colors.lightBlueAccent, Colors.greenAccent])], showingTooltipIndicators: [0],),
  ];
}