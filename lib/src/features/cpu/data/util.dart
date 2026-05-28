List<List<double>> toGraphModel(
  List<List<double>> result,
  List<double> listToProcess,
) {
  if (result.isEmpty) {
    List<double> coreUsages = listToProcess;

    for (int i = 0; i < coreUsages.length; i++) {
      List<double> values = [];
      for (int j = 0; j < 100; j++) {
        if (j == 0) {
          values.add(0.0);
          continue;
        }
        if (j == 1) {
          values.add(100.0);
          continue;
        }
        if (j == 2) {
          values.add(coreUsages[i]);
          continue;
        }
        values.add(0.0);
      }

      result.add(values);
    }
  } else {
    if (result[0].length > 100) {
      for (int i = 0; i < result.length; i++) {
        result[i].removeAt(2);
      }
    }
    List<double> coreUsages = listToProcess;
    for (int i = 0; i < coreUsages.length; i++) {
      result[i].add(coreUsages[i]);
    }
  }
  return List.of(result);
}

int bytesToMegabyte(BigInt toConvert) {
  return toConvert.toInt() ~/ 1024;
}
