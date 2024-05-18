import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Avatar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '3D Sample Avatar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  final TextEditingController _textEditingController = TextEditingController();
  final String defaultAnimation = 'Rig|cycle_talking';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.playAnimation(animationName: defaultAnimation);
    });
    // controller.playAnimation(animationName: 'Rig|cycle_talking');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            onPressed: () {
              controller.playAnimation();
            },
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton.small(
            onPressed: () {
              controller.pauseAnimation();
            },
            child: const Icon(Icons.pause),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton.small(
            onPressed: () {
              controller.resetAnimation();
            },
            child: const Icon(Icons.replay_circle_filled),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton.small(
            onPressed: () async {
              List<String> availableAnimations =
                  await controller.getAvailableAnimations();
              print(
                  'Animations : $availableAnimations -- Length : ${availableAnimations.length}');
              chosenAnimation =
                  await showPickerDialog(availableAnimations, chosenAnimation);
              controller.playAnimation(animationName: chosenAnimation);
            },
            child: const Icon(Icons.format_list_bulleted_outlined),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton.small(
            onPressed: () {
              controller.setCameraOrbit(20, 20, 25);
            },
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(
            height: 4,
          ),
          FloatingActionButton.small(
            onPressed: () {
              controller.resetCameraOrbit();
            },
            child: const Icon(Icons.cameraswitch_outlined),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              child: Flutter3DViewer(
                progressBarColor: Colors.blue,
                controller: controller,
                src: 'assets/sadhu_sitting_idle.fbx.fbx',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Enter command',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String command = _textEditingController.text.trim();
                    _handleCommand(command);
                    _textEditingController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showPickerDialog(List<String> inputList,
      [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) {
          return SizedBox(
            height: 250,
            child: ListView.separated(
              itemCount: inputList.length,
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, inputList[index]);
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${index + 1}'),
                        Text(inputList[index]),
                        Icon(chosenItem == inputList[index]
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off)
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (ctx, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 0.6,
                  indent: 10,
                  endIndent: 10,
                );
              },
            ),
          );
        });
  }

  void _handleCommand(String command) {
    if (command.startsWith('play ')) {
      String animationName = command.substring(5);
      controller.playAnimation(animationName: animationName);
    } else if (command == 'pause') {
      controller.pauseAnimation();
    } else if (command == 'reset') {
      controller.resetAnimation();
    } else if (command.startsWith('camera orbit ')) {
      List<String> parts = command.split(' ');
      if (parts.length == 4) {
        double x = double.parse(parts[2]);
        double y = double.parse(parts[3]);
        double z = double.parse(parts[4]);
        controller.setCameraOrbit(x, y, z);
      }
    } else if (command == 'reset camera') {
      controller.resetCameraOrbit();
    } else {
      print('Unknown command: $command');
    }
  }
}
