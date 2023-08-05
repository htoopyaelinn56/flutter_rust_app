import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Task Manager With Rust'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ref.watch(systemInfoProvider).when(
                  data: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CPU - ${data.cpu}'),
                        Text('System Name - ${data.systemName}'),
                        Text('Kernal - ${data.kernal}'),
                        Text('OS Version - ${data.osVersion}'),
                        Text('Host Name - ${data.hostName}'),
                        Text('Ram - ${data.memory}'),
                      ],
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
            const SizedBox(height: 10),
            ref.watch(cpuUsageProvider).when(
                  data: (data) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < data.length; i++)
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: kThemeAnimationDuration,
                                  builder: (_, value, __) => CircularProgressIndicator(
                                    value: value,
                                    color: Colors.red,
                                    strokeWidth: 4,
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  tween: Tween(begin: 0, end: data[i] / 100),
                                ),
                                Center(
                                  child: Text('CPU $i\n${data[i].toStringAsFixed(2)}%'),
                                )
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
          ],
        ),
      ),
    );
  }
}

final systemInfoProvider = FutureProvider<Components>((ref) async {
  return api.getSysInfo();
});

final cpuUsageProvider = StreamProvider<List<double>>((ref) async* {
  await for (final i in api.streamCpuUsage()) {
    yield i.toList();
  }
});
