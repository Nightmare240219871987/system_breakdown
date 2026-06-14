import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/ram.dart';

class RAMPage extends StatefulWidget {
  const RAMPage({super.key});

  @override
  State<RAMPage> createState() => _RAMPageState();
}

class _RAMPageState extends State<RAMPage> {
  Future<Ram>? futureRam;
  Stream<Ram>? streamRam;
  static final TextStyle _textStyle = TextStyle(fontWeight: FontWeight.bold);

  Stream<Ram> getUpdates() async* {
    Ram ram = await futureRam!;
    while (mounted) {
      await ram.fetchData();
      yield ram;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  int bytesToMegabyte(BigInt toConvert) {
    double temp = toConvert.toDouble();
    temp /= 1024 * 1024;
    return temp.toInt();
  }

  double transferRate(int mt, int dataWidth) {
    double res = mt * dataWidth / 8 / 1024;
    return res;
  }

  @override
  void initState() {
    super.initState();
    futureRam = Ram.newInstance();
    streamRam ??= getUpdates().asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("RAM Nutzung", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                StreamBuilder(
                  stream: streamRam,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Ram ram = snapshot.data!;
                      return SizedBox(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 8,
                              children: [
                                SizedBox(width: 32),
                                Text(
                                  "Arbeitsspeicher gesamt : ${bytesToMegabyte(ram.totalRam)} MiB",
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 32,
                                  height: 16,
                                  color: Colors.red,
                                ),
                                Text(
                                  "Arbeitsspeicher belegt : ${bytesToMegabyte(ram.usedRam)} MiB",
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 32,
                                  height: 16,
                                  color: Colors.lightGreen,
                                ),
                                Text(
                                  "Arbeitsspeicher frei : ${bytesToMegabyte(ram.freeRam)} MiB",
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 32,
                                  height: 16,
                                  color: Colors.green,
                                ),
                                Text(
                                  "Arbeitsspeicher verfügbar : ${bytesToMegabyte(ram.availableRam)} MiB",
                                ),
                              ],
                            ),

                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 32.0),
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 0,
                                      titleSunbeamLayout: true,
                                      sections: [
                                        PieChartSectionData(
                                          titleStyle: _textStyle,
                                          title:
                                              "${(100.0 / ram.totalRam.toDouble() * ram.usedRam.toDouble()).toStringAsFixed(0)}%",
                                          color: Colors.red,
                                          value: bytesToMegabyte(
                                            ram.usedRam,
                                          ).toDouble(),
                                          radius: 100,
                                        ),
                                        PieChartSectionData(
                                          titleStyle: _textStyle,
                                          title:
                                              "${(100.0 / ram.totalRam.toDouble() * ram.availableRam.toDouble()).toStringAsFixed(0)}%",
                                          color: Colors.green,
                                          value: bytesToMegabyte(
                                            ram.availableRam - ram.freeRam,
                                          ).toDouble(),
                                          radius: 100,
                                        ),
                                        PieChartSectionData(
                                          titleStyle: _textStyle,
                                          title:
                                              "${(100.0 / ram.totalRam.toDouble() * ram.freeRam.toDouble()).toStringAsFixed(0)}%",
                                          color: Colors.lightGreen,
                                          value: bytesToMegabyte(
                                            ram.freeRam,
                                          ).toDouble(),
                                          radius: 100,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Text("Etwas ist schief gegangen.");
                  },
                ),
              ],
            ),
            Column(
              children: [
                StreamBuilder(
                  stream: streamRam,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Ram ram = snapshot.data!;
                      return SizedBox(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 8,
                              children: [
                                SizedBox(width: 32),
                                Text(
                                  "Auslagerung gesamt : ${bytesToMegabyte(ram.totalSwap)} MiB",
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 32,
                                  height: 16,
                                  color: Colors.red,
                                ),
                                Text(
                                  "Auslagerung belegt : ${bytesToMegabyte(ram.usedSwap)} MiB",
                                ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Container(
                                  width: 32,
                                  height: 16,
                                  color: Colors.green,
                                ),
                                Text(
                                  "Auslagerung verfügbar : ${bytesToMegabyte(ram.freeSwap)} MiB",
                                ),
                              ],
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 48.0),
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 0,
                                      titleSunbeamLayout: true,
                                      sections: [
                                        PieChartSectionData(
                                          titleStyle: _textStyle,
                                          title:
                                              "${(100.0 / ram.totalSwap.toDouble() * ram.usedSwap.toDouble()).toStringAsFixed(0)}%",
                                          color: Colors.red,
                                          value: bytesToMegabyte(
                                            ram.totalRam ~/
                                                BigInt.from(100) *
                                                ram.usedSwap,
                                          ).toDouble(),
                                          radius: 100,
                                        ),
                                        PieChartSectionData(
                                          titleStyle: _textStyle,
                                          title:
                                              "${(100.0 / ram.totalSwap.toDouble() * ram.freeSwap.toDouble()).toStringAsFixed(0)}%",
                                          color: Colors.green,
                                          value: bytesToMegabyte(
                                            ram.freeSwap,
                                          ).toDouble(),
                                          radius: 100,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Text("Etwas ist schief gegangen.");
                  },
                ),
              ],
            ),
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 32.0), child: Divider()),
        Text("Ram Information", style: TextStyle(fontWeight: FontWeight.bold)),
        StreamBuilder(
          stream: streamRam,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Ram ram = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Slot 1",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text("RAM Typ : "),
                            Text("${ram.ramType.elementAtOrNull(0)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Soll Takt : "),
                            Text("${ram.ramSpeed.elementAtOrNull(0)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Ist Takt : "),
                            Text(
                              "${ram.ramSpeedConfigured.elementAtOrNull(0)}",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Bandbreite : "),
                            Text("${ram.ramBandWidth.elementAtOrNull(0)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Datentransferrate : "),
                            Text(
                              "${transferRate(ram.ramSpeedConfigured.elementAt(3).toInt(), ram.ramBandWidth.elementAt(0).toInt())} GiB/s",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Slot 2",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text("RAM Typ : "),
                            Text("${ram.ramType.elementAtOrNull(1)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Soll Takt : "),
                            Text("${ram.ramSpeed.elementAtOrNull(1)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Ist Takt : "),
                            Text(
                              "${ram.ramSpeedConfigured.elementAtOrNull(1)}",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Bandbreite : "),
                            Text("${ram.ramBandWidth.elementAtOrNull(1)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Datentransferrate : "),
                            Text(
                              "${transferRate(ram.ramSpeedConfigured.elementAt(3).toInt(), ram.ramBandWidth.elementAt(1).toInt())} GiB/s",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Slot 3",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text("RAM Typ : "),
                            Text("${ram.ramType.elementAtOrNull(2)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Soll Takt : "),
                            Text("${ram.ramSpeed.elementAtOrNull(2)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Ist Takt : "),
                            Text(
                              "${ram.ramSpeedConfigured.elementAtOrNull(2)}",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Bandbreite : "),
                            Text("${ram.ramBandWidth.elementAtOrNull(2)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Datentransferrate : "),
                            Text(
                              "${transferRate(ram.ramSpeedConfigured.elementAt(3).toInt(), ram.ramBandWidth.elementAt(2).toInt())} GiB/s",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Slot 4",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text("RAM Typ : "),
                            Text("${ram.ramType.elementAtOrNull(3)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Soll Takt : "),
                            Text("${ram.ramSpeed.elementAtOrNull(3)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Ist Takt : "),
                            Text(
                              "${ram.ramSpeedConfigured.elementAtOrNull(3)}",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Bandbreite : "),
                            Text("${ram.ramBandWidth.elementAtOrNull(3)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Datentransferrate : "),
                            Text(
                              "${transferRate(ram.ramSpeedConfigured.elementAt(3).toInt(), ram.ramBandWidth.elementAt(3).toInt())} GiB/s",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return Text(
              "Es ist etwas schief gelaufen.",
              style: TextStyle(color: Colors.red),
            );
          },
        ),
      ],
    );
  }
}
