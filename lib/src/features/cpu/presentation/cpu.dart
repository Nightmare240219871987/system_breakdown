import 'package:flutter/material.dart';
import 'package:system_breakdown/src/features/cpu/data/util.dart';
import 'package:system_breakdown/src/rust/api/cpu.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class CPUPage extends StatefulWidget {
  const CPUPage({super.key});

  @override
  State<CPUPage> createState() => _CPUPageState();
}

class _CPUPageState extends State<CPUPage> {
  List<List<double>> result = [];
  late int cores;
  late bool isRunning;
  Stream<Cpu>? updatePeriodlyStream;
  Future<Cpu>? cpuFuture;

  Stream<Cpu> getUpdates() async* {
    Cpu cpu = await cpuFuture!;
    while (isRunning) {
      await cpu.fetchData();
      yield cpu;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  @override
  void initState() {
    super.initState();
    isRunning = true;
    cpuFuture ??= Cpu.newInstance();
    updatePeriodlyStream ??= getUpdates();
  }

  @override
  void dispose() {
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            "CPU Informationen",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: cpuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text(
                    "Fehler: ${snapshot.error}",
                    style: TextStyle(color: Colors.red),
                  );
                }
                if (snapshot.hasData) {
                  Cpu cpu = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // ------- 1 --------
                      Column(
                        children: [
                          Text(
                            "Hersteller",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(cpu.cpuVendor),
                          Text(
                            "Brand",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(cpu.cpuBrand),
                        ],
                      ),
                      // ------- 2 --------
                      Column(
                        children: [
                          Text(
                            "Physische Kerne",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${cpu.cpuCores.toInt()}"),
                          Text(
                            "Logische Kerne",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${cpu.cpuThreads}"),
                        ],
                      ),
                      // ------- 3 --------
                      Column(
                        children: [
                          Text(
                            "L1 Cache",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${bytesToMegabyte(cpu.l1Cache)} KB"),
                          Text(
                            "L2 Cache",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${bytesToMegabyte(cpu.l2Cache)} KB"),
                          Text(
                            "L3 Cache",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${bytesToMegabyte(cpu.l3Cache)} KB (${bytesToMegabyte(cpu.l3Cache) ~/ cpu.cpuCores.toInt()} KB)",
                          ),
                        ],
                      ),
                      // ------- 4 --------
                      Column(
                        children: [
                          Text(
                            "Hardware AES",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${cpu.aesSupport}"),
                          Text(
                            "Hardware SHA256",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${cpu.sha256Support}"),
                          Text(
                            "SSE Features",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(cpu.sseFeatures),
                        ],
                      ),
                    ],
                  );
                }
                return const Text(
                  "Etwas ist Schief gegangen.",
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Divider(color: Colors.grey.shade400, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder(
              stream: updatePeriodlyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text(
                    "Fehler: ${snapshot.error}",
                    style: TextStyle(color: Colors.red),
                  );
                }
                if (snapshot.hasData) {
                  // ------- Stream Data --------
                  Cpu cpu = snapshot.data!;
                  return Column(
                    children: [
                      const Text(
                        "Globale CPU Auslastung",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Text("CPU Auslastung:"),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: cpu.totalCpuUsage / 100,
                              minHeight: 15,
                            ),
                          ),
                          Text("${cpu.totalCpuUsage.toStringAsFixed(2)}%"),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 32),
                        child: Divider(color: Colors.grey.shade400, height: 1),
                      ),
                      const Text(
                        "Kern Auslastungen",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                        ),
                        itemCount: cpu.coreUsages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "cpu$index",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("${cpu.coreSpeeds[index]} Mhz"),
                                SfSparkBarChart(
                                  key: ValueKey(
                                    "core${index}_${cpu.coreUsages[index]}",
                                  ),
                                  data:
                                      toGraphModel(
                                            result,
                                            cpu.coreUsages,
                                          )[index]
                                          as List<num>,
                                  color: Colors.lightBlue,
                                  labelDisplayMode:
                                      SparkChartLabelDisplayMode.none,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const Text(
                  "Es ist etwas schief gegengen.",
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
