import 'package:fl_chart/fl_chart.dart';

List<List<double>> toGraphModel(
  List<List<double>> result,
  List<double> listToProcess,
) {
  if (result.isEmpty) {
    for (int i = 0; i < listToProcess.length; i++) {
      result.add([0]);
    }
    for (int i = 0; i < result.length; i++) {
      for (int j = 0; j < 99; j++) {
        result[i].add(0);
      }
      result[i].add(listToProcess[i]);
    }
    return List.of(result);
  } else {
    if (result[0].length >= 100) {
      for (int i = 0; i < result.length; i++) {
        result[i].removeAt(0);
      }
    }

    for (int i = 0; i < listToProcess.length; i++) {
      result[i].add(listToProcess[i]);
    }

    return List.of(result);
  }
}

List<List<FlSpot>> toSpots(List<List<double>> results) {
  List<List<FlSpot>> spots = [];

  for (int i = 0; i < results.length; i++) {
    spots.add([]);
    double timeline = 0;
    for (int j = 0; j < results[i].length; j++) {
      spots[i].add(FlSpot(timeline, results[i][j]));
      timeline++;
    }
  }
  return spots;
}

int bytesToMegabyte(BigInt toConvert) {
  return toConvert.toInt() ~/ 1024;
}
