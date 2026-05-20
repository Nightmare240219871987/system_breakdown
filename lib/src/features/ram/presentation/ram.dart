import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/api/ram.dart';

class RAMPage extends StatefulWidget {
  const RAMPage({super.key});

  @override
  State<RAMPage> createState() => _RAMPageState();
}

class _RAMPageState extends State<RAMPage> {
  late bool isRunning;
  late Stream<BigInt> usedMemoryStream;
  late Stream<BigInt> availableMemoryStream;

  late Stream<BigInt> usedSwapStream;
  late Stream<BigInt> freeSwapStream;

  Stream<BigInt> getUsedMemoryStream() async* {
    while (isRunning) {
      BigInt used = await getUsedMemory();
      yield used;
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Stream<BigInt> getAvailableMemoryStream() async* {
    while (isRunning) {
      BigInt available = await getAvailableRam();
      yield available;
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Stream<BigInt> getUsedSwapStream() async* {
    while (isRunning) {
      BigInt used = await getUsedSwap();
      yield used;
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Stream<BigInt> getFreeSwapStream() async* {
    while (isRunning) {
      BigInt available = await getFreeSwap();
      yield available;
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  int bytesToMegabyte(BigInt toConvert) {
    double temp = toConvert.toDouble();
    temp /= 1024 * 1024;
    return temp.toInt();
  }

  @override
  void initState() {
    isRunning = true;
    usedMemoryStream = getUsedMemoryStream();
    availableMemoryStream = getAvailableMemoryStream();
    usedSwapStream = getUsedSwapStream();
    freeSwapStream = getFreeSwapStream();
    super.initState();
  }

  @override
  void dispose() {
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text("Memory", style: TextStyle(fontWeight: FontWeight.bold)),
            FutureBuilder(
              future: getTotalRam(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler Passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Total Memory : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
            StreamBuilder(
              stream: usedMemoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Used Memory : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
            StreamBuilder(
              stream: availableMemoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Available Memory : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
          ],
        ),
        Column(
          children: [
            const Text("Swap", style: TextStyle(fontWeight: FontWeight.bold)),
            FutureBuilder(
              future: getTotalSwap(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler Passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Total Swap : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
            StreamBuilder(
              stream: usedSwapStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Used Swap : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
            StreamBuilder(
              stream: freeSwapStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (snapshot.hasError) {
                  return Text("Es ist ein Fehler passiert : ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  return Text(
                    "Available Swap : ${bytesToMegabyte(snapshot.data!)} MB",
                  );
                }
                return const Text("Es ist ein Fehler passiert.");
              },
            ),
          ],
        ),
      ],
    );
  }
}
