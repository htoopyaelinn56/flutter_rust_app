// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Task Manager'),
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
  var operator = Operator.Plus;
  final firstValueController = TextEditingController();
  final secondValueController = TextEditingController();

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
            ref.watch(ifSystemInfoSupportedProvider).when(
                  data: (data) {
                    if (data) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      Text('Ram - ${data.memory} GB'),
                                    ],
                                  );
                                },
                                error: (e, st) => Text('$e'),
                                loading: () => const CircularProgressIndicator(),
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
                                error: (e, st) => Text('$e $st'),
                                loading: () => const CircularProgressIndicator(),
                              ),
                        ],
                      );
                    } else {
                      return const Text('Not supported');
                    }
                  },
                  error: (e, st) => Text('$e'),
                  loading: () => const CircularProgressIndicator(),
                ),
            const Divider(),
            const Text(
              'Rust Caluclator',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    onChanged: (_) {
                      setState(() {});
                    },
                    controller: firstValueController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'First Number',
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    onChanged: (_) {
                      setState(() {});
                    },
                    controller: secondValueController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Second Number',
                    ),
                  ),
                ),
                DropdownMenu<Operator>(
                  enableSearch: false,
                  initialSelection: operator,
                  onSelected: (value) {
                    operator = value!;
                    setState(() {});
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(label: '+', value: Operator.Plus),
                    DropdownMenuEntry(label: '-', value: Operator.Minus),
                    DropdownMenuEntry(label: '×', value: Operator.Multiply),
                    DropdownMenuEntry(label: '÷', value: Operator.Divide),
                  ],
                ),
                const Text(' = '),
                Expanded(
                  child: ref
                      .watch(
                        calculateProvider(
                          CalculateFamilyModel(
                            firstValue: int.tryParse(firstValueController.text) ?? 0,
                            secondValue: int.tryParse(secondValueController.text) ?? 0,
                            operator: operator,
                          ),
                        ),
                      )
                      .when(
                        data: (data) {
                          return Text('$data');
                        },
                        error: (e, st) => Text('$e'),
                        loading: () => const CircularProgressIndicator(),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final ifSystemInfoSupportedProvider = FutureProvider<bool>((ref) async {
  return api.ifSysInfoSupported();
});

final systemInfoProvider = FutureProvider<Components>((ref) async {
  return api.getSysInfo();
});

final getCpuProvider = FutureProvider<String>((ref) async {
  return api.getCpu();
});

final cpuUsageProvider = StreamProvider<List<double>>((ref) async* {
  await for (final i in api.streamCpuUsage()) {
    yield i.toList();
  }
});

class CalculateFamilyModel extends Equatable {
  final int firstValue;
  final int secondValue;
  final Operator operator;
  const CalculateFamilyModel({
    required this.firstValue,
    required this.secondValue,
    required this.operator,
  });

  @override
  List<Object> get props => [firstValue, secondValue, operator];
}

final calculateProvider = FutureProvider.family.autoDispose<int, CalculateFamilyModel>((ref, model) async {
  return api.calculate(
    firstValue: model.firstValue,
    secondValue: model.secondValue,
    operator: model.operator,
  );
});
