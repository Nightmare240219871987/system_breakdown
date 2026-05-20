import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/cpu.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class CPUPage extends StatefulWidget {
  const CPUPage({super.key});

  @override
  State<CPUPage> createState() => _CPUPageState();
}

class _CPUPageState extends State<CPUPage> {
  late int cores = 0;
  late bool isRunning;
  late Stream<List<List<double>>> cpuCoresStream;
  late Stream<List<BigInt>> cpuCoresSpeedStream;
  late Stream<double> cpuGlobalUsageStream;

  Stream<List<List<double>>> getCpuCoreUsages() async* {
    List<List<double>> result = [];
    while (isRunning) {
      if (result.isEmpty) {
        List<double> coreUsages = await getCoreUsages();

        for (int i = 1; i < coreUsages.length; i++) {
          result.add([0, 100, coreUsages[i]]);
        }
      } else {
        if (result[0].length > 100) {
          for (int i = 0; i < result.length; i++) {
            result[i].removeAt(2);
          }
        }
        List<double> coreUsages = await getCoreUsages();
        for (int i = 1; i < coreUsages.length; i++) {
          result[i - 1].add(coreUsages[i]);
        }
      }
      yield List.of(result);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Stream<List<BigInt>> getCpuSpeed() async* {
    while (isRunning) {
      var freqs = await getCpusSpeed();
      List<BigInt> data = [];
      for (int i = 1; i < freqs.length; i++) {
        data.add(freqs[i]);
      }
      yield List.of(data);
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  Stream<double> getGlobalCpuUsage() async* {
    while (isRunning) {
      var usage = await getCoreUsages();
      yield usage[0];
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  int bytesToMegabyte(BigInt toConvert) {
    return toConvert.toInt() ~/ 1024;
  }

  @override
  void initState() {
    isRunning = true;
    cpuGlobalUsageStream = getGlobalCpuUsage().asBroadcastStream();
    cpuCoresStream = getCpuCoreUsages().asBroadcastStream();
    cpuCoresSpeedStream = getCpuSpeed().asBroadcastStream();
    super.initState();
  }

  @override
  void dispose() {
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            "CPU Informationen",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              verticalDirection: VerticalDirection.down,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Hersteller:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getVendor(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "Physical Processors:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getPhysicalCores(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          BigInt res = snapshot.data!;
                          cores = res.toInt();
                          return Text("$res");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Brand:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getBrand(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "Logical Processors:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getThreads(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          return Text("${snapshot.data!}");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "L1 Cache:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getL1Cache(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          (BigInt, BigInt) res = snapshot.data!;
                          return Text("${bytesToMegabyte(res.$1 * res.$2)} KB");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "L2 Cache:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getL2Cache(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          return Text("${bytesToMegabyte(snapshot.data!)} KB");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "L3 Cache:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getL3Cache(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          (BigInt, BigInt) res = snapshot.data!;

                          return Text(
                            "${bytesToMegabyte(res.$1 * res.$2)} KB (${(bytesToMegabyte(res.$1 * res.$2) / cores).toStringAsFixed(0)} KB)",
                          );
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Hardware Verschlüsselung:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getEncryptionAcceleration(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          bool res = snapshot.data!;
                          return Text(res ? "Ja" : "Nein");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "Hardware Hashing:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getHashAcceleration(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          bool res = snapshot.data!;
                          return Text(res ? "Ja" : "Nein");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "SSE Featuresets:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: getSseExtensions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("");
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Es ist ein Fehler Passiert. ${snapshot.error}",
                          );
                        }
                        if (snapshot.hasData) {
                          var res = snapshot.data!;
                          return Text(res.toString());
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Text(
            "Globale CPU Auslastung",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Text("cpu Total: "),
              Expanded(
                child: StreamBuilder(
                  stream: cpuGlobalUsageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("");
                    }
                    if (snapshot.hasError) {
                      return Text(
                        "Es ist ein Fehler passiert. ${snapshot.error}",
                      );
                    }
                    if (snapshot.hasData) {
                      double usage = snapshot.data!;
                      return Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey.shade400,
                              value: usage / 100.0,
                              minHeight: 15,
                            ),
                          ),
                          Text("${usage.toStringAsFixed(2)}%"),
                        ],
                      );
                    }
                    return const Text("Es ist ein Fehler passiert.");
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Divider(color: Colors.grey.shade400, height: 1),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Core Auslastungen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: cpuCoresSpeedStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        "Es ist ein Fehler passiert : ${snapshot.error}",
                      );
                    }
                    if (snapshot.hasData) {
                      return Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 250,
                              ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text("cpu$index"),
                                  Text("${snapshot.data![index]}MHz"),
                                  Expanded(
                                    child: StreamBuilder<List<List<double>>>(
                                      stream: cpuCoresStream,
                                      builder: (context, usageSnapshot) {
                                        if (usageSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text("Lade Daten...");
                                        }
                                        if (usageSnapshot.hasError) {
                                          return Text(
                                            "Es ist ein Fehler passiert : ${usageSnapshot.error}",
                                          );
                                        }
                                        if (usageSnapshot.hasData) {
                                          return SfSparkAreaChart(
                                            key: ValueKey(
                                              'core_${index}_${usageSnapshot.data![index]}',
                                            ),
                                            data: usageSnapshot.data![index],
                                            color: Colors.lightBlue,
                                            labelDisplayMode:
                                                SparkChartLabelDisplayMode.none,
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          );
                                        }
                                        return const Text(
                                          "Es ist ein Fehler passiert.",
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const Text("Es ist ein Fehler passiert.");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
