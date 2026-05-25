import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/cpu.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class CPUPage extends StatefulWidget {
  const CPUPage({super.key});

  @override
  State<CPUPage> createState() => _CPUPageState();
}

class _CPUPageState extends State<CPUPage> {
  late int cores;
  late bool isRunning;
  late Stream<double> cpuGlobalUsageStream;
  late Stream<List<List<double>>> cpuCoresUsageStream;
  late Stream<List<BigInt>> cpuCoresSpeedStream;
  Future<Cpu>? cpuFuture;

  Stream<List<List<double>>> getCpuCoreUsages() async* {
    List<List<double>> result = [];
    while (isRunning) {
      Cpu cpu = await cpuFuture!;
      if (result.isEmpty) {
        List<double> coreUsages = cpu.coreUsages;

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
        List<double> coreUsages = cpu.coreUsages;
        for (int i = 0; i < coreUsages.length; i++) {
          result[i].add(coreUsages[i]);
        }
      }
      yield List.of(result);
    }
  }

  Stream<List<BigInt>> getCpuSpeed() async* {
    while (isRunning) {
      Cpu cpu = await cpuFuture!;
      var freqs = cpu.coreSpeeds;
      List<BigInt> data = [];
      for (int i = 0; i < freqs.length; i++) {
        data.add(freqs[i]);
      }
      yield List.of(data);
    }
  }

  Stream<double> getGlobalCpuUsage() async* {
    while (isRunning) {
      Cpu cpu = await cpuFuture!;
      yield cpu.totalCpuUsage;
    }
  }

  int bytesToMegabyte(BigInt toConvert) {
    return toConvert.toInt() ~/ 1024;
  }

  Future<void> periodCoreUpdate() async {
    Cpu cpu = await cpuFuture!;
    while (isRunning) {
      await cpu.fetchData();
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  @override
  void initState() {
    isRunning = true;
    cpuFuture ??= Cpu.newInstance();
    cpuCoresUsageStream = getCpuCoreUsages().asBroadcastStream();
    cpuCoresSpeedStream = getCpuSpeed().asBroadcastStream();
    cpuGlobalUsageStream = getGlobalCpuUsage().asBroadcastStream();
    periodCoreUpdate();
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
                      future: cpuFuture,
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
                          return Text(snapshot.data!.cpuVendor);
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "Physical Processors:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: cpuFuture,
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
                          BigInt res = snapshot.data!.cpuCores;
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
                      future: cpuFuture,
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
                          return Text(snapshot.data!.cpuBrand);
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "Logical Processors:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: cpuFuture,
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
                          return Text("${snapshot.data!.cpuThreads}");
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
                      future: cpuFuture,
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
                          BigInt res = snapshot.data!.l1Cache;
                          return Text("${bytesToMegabyte(res)} KB");
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "L2 Cache:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: cpuFuture,
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
                          return Text(
                            "${bytesToMegabyte(snapshot.data!.l2Cache)} KB",
                          );
                        }
                        return const Text("es ist ein Fehler passiert.");
                      },
                    ),
                    Text(
                      "L3 Cache:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder(
                      future: cpuFuture,
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
                          BigInt res = snapshot.data!.l3Cache;

                          return Text(
                            "${bytesToMegabyte(res)} KB (${(bytesToMegabyte(res) / cores).toStringAsFixed(0)} KB)",
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
                      future: cpuFuture,
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
                          bool res = snapshot.data!.aesSupport;
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
                      future: cpuFuture,
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
                          bool res = snapshot.data!.sha256Support;
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
                      future: cpuFuture,
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
                          var res = snapshot.data!.sseFeatures;
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
                                      stream: cpuCoresUsageStream,
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
                                              'core_${index}_${usageSnapshot.data![index].last}',
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
