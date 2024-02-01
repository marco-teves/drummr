import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part 'main.g.dart';
// audio sample assets from FL Studio 21
// icon assets from flaticon.com https://www.flaticon.com/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init hive
  await Hive.initFlutter();
  Hive.registerAdapter(SequencerGridAdapter());
  runApp(DrumSequencerApp());
}
// runs the main app, initialises the database

class DrumSequencerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrumSequencer(),
    );
  }
}

@HiveType(typeId: 0)
class SequencerGrid {
  @HiveField(0)
  String gridString;
  SequencerGrid(this.gridString);
}
// adapter for Sequencer Grid

class DrumSequencer extends StatefulWidget {
  @override
  _DrumSequencerState createState() => _DrumSequencerState();
}

class _DrumSequencerState extends State<DrumSequencer> {
  final AudioCache audioCache = AudioCache();
  final List<String> drumSounds = [
    'kick.wav',
    'snare.wav',
    'hat.wav',
    'tom1.wav',
    'tom2.wav',
  ];

  Map<String, String> soundIcons = {
    'kick.wav': 'assets/kick.png',
    'snare.wav': 'assets/snare.png',
    'hat.wav': 'assets/hat.png',
    'tom1.wav': 'assets/tom1.png',
    'tom2.wav': 'assets/tom1.png',
    // assigns the samples an icon
  };

  Map<int, int> beatsPerMin = {
    120: 250,
    150: 400,
  };

  Map<String, Color> soundColors = {
    'kick.wav': const Color.fromARGB(255, 0, 59, 148),
    'snare.wav': const Color.fromARGB(255, 30, 148, 0),
    'hat.wav': const Color.fromARGB(255, 148, 141, 0),
    'tom1.wav': const Color.fromARGB(255, 133, 0, 148),
    'tom2.wav': const Color.fromARGB(255, 148, 0, 0),
    // assigns the samples a colour , any button that has to do with the sample will be coloured accordingly
  };

  List<List<bool>> sequencerGrid =
      List.generate(5, (index) => List.generate(16, (index) => false));
  // creates a list that represents the buttons of the sequencer either on  or off

  Timer? _sequencerTimer;
  int _currentColumn = 0;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // initialise the sequencer
  }

  void _playColumn(int colIndex) {
    for (int rowIndex = 0; rowIndex < sequencerGrid.length; rowIndex++) {
      // will loop through each button within the column
      if (sequencerGrid[rowIndex][colIndex]) {
        // are there buttons that are pressed down the column?
        _playSound(drumSounds[rowIndex]);
        // if so all sounds accordingly
      }
    }
  }

  void _startSequencer() {
    // the program will play a single column then will wait 250ms to play the next column
    const columnInterval = Duration(milliseconds: 250);
    _sequencerTimer = Timer.periodic(columnInterval, (timer) {
      if (mounted) {
        _playColumn(_currentColumn);
        _currentColumn = (_currentColumn + 1) % sequencerGrid[0].length;
      }
    });
    setState(() {
      isPlaying = true;
      // also tells the program that it it playing
    });
  }

  void _stopSequencer() {
    _sequencerTimer?.cancel();
    _currentColumn = 0; // resets to the starting column of the sequencer
    setState(() {
      isPlaying = false;
    });
    // will cancel the timer and will set the sate as not playing
  }

  //Hive Database Functions

  String sequencerGridToString() {
    return sequencerGrid
        .map((row) => row.map((value) => value ? 'y' : 'n').join())
        // each value within a row will be converted to a string on or off y = on n = off
        .join();
    // joins each character into one full string
  }

  void sequencerGridFromString(String gridString) {
    for (int rowIndex = 0; rowIndex < sequencerGrid.length; rowIndex++) {
      // this will loop through the rows
      for (int colIndex = 0;
          colIndex < sequencerGrid[rowIndex].length;
          colIndex++) {
        // this will loop through the columns
        sequencerGrid[rowIndex][colIndex] =
            // accesses the list using the index of row and column. = means we are assinging something to it
            gridString[rowIndex * sequencerGrid[rowIndex].length + colIndex] ==
                // accesses the character in the list
                'y'; // is the character y? if so set it to true
      }
    }
    setState(
        () {}); // this will then update the widgets to display the new pattern
  }

  Future<void> savePattern() async {
    final storage = await Hive.openBox<SequencerGrid>('SAVED PATTERN');
    // opens a box called storage (saved pattern)
    final gridString = sequencerGridToString();
    // uses sequencerGridToString to convert sequencer to string
    final sequencerGrid = SequencerGrid(gridString);
    // makes an object of said string

    if (storage.isNotEmpty) {
      await storage.put(0,
          sequencerGrid); // if there is an existing pattern saved, overwrite it at index 0
    } else {
      await storage.add(sequencerGrid); // otherwise just add it
    }
  }

  Future<void> loadPattern() async {
    final storage = await Hive.openBox<SequencerGrid>('SAVED PATTERN');
    // opens a box called storage (saved pattern)
    if (storage.isNotEmpty) {
      // checls if storage has a pattern stored
      final sequencerGrid = storage.getAt(0);
      // if there is, then retrive the pattern
      if (sequencerGrid != null) {
        // is the sequencer grid filled in?
        sequencerGridFromString(sequencerGrid.gridString);
        // replace the pattern on the grid with the new one
      }
    }
  }

  Future<void> deletePattern() async {
    // clears the current pattern on the grid (not on storage)
    for (int rowIndex = 0; rowIndex < sequencerGrid.length; rowIndex++) {
      List<bool> row = sequencerGrid[rowIndex];
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        row[colIndex] = false;
      }
    } // goes through all the buttons in the sequencer grid and set it to false (off)

    setState(() {}); // updates the visuals to match the new state of the grid
  }

  void _playSound(String sound) {
    audioCache.play(sound);
  }

  // plays the sequence
  void _toggleSequencer() {
    if (isPlaying) {
      _stopSequencer();
    } else {
      _startSequencer();
    }
  }

  // for the play/pause button if its playing stop the sequence
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(40, 40, 40, 1),
      //appBar: AppBar(
      //title: const Text('DRUMMR'),
      //backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      //),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: isPlaying ? 'Pause' : 'Play', // Tooltip message
                      child: ElevatedButton(
                        onPressed: () {
                          _toggleSequencer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 108, 10, 10),
                        ),
                        child: isPlaying
                            ? const ImageIcon(
                                AssetImage('assets/pause.png'),
                                size: 32,
                                color: Colors.white,
                              )
                            : const ImageIcon(
                                AssetImage('assets/play.png'),
                                size: 32,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    Tooltip(
                      message:
                          'Saves the current sequencer pattern on the grid to storage. Overwrites the current saved pattern',
                      child: ElevatedButton(
                          onPressed: () async {
                            await savePattern();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 20, 20, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text('SAVE')),
                    ),
                    Tooltip(
                      message: 'Loads the saved pattern from storage',
                      child: ElevatedButton(
                        onPressed: () async {
                          await loadPattern();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 20, 20, 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text('LOAD'),
                      ),
                    ),
                    const Spacer(
                      flex: 2,
                    ),
                    const Text(
                      'DRUMMR',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(
                      flex: 2,
                    ),
                    const Spacer(),
                    Tooltip(
                      message:
                          'Clears the current pattern on the sequencer grid',
                      child: OutlinedButton(
                        onPressed: () async {
                          await deletePattern();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 48, 3, 3),
                          foregroundColor: Color.fromARGB(255, 186, 17, 17),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 108, 10, 10),
                            width: 2.0,
                          ),
                        ),
                        child: const Text('CLEAR'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 16,
              ),
              itemBuilder: (context, index) {
                int rowIndex = index ~/ 16;
                int colIndex = index % 16;
                Color cellColor = sequencerGrid[rowIndex][colIndex]
                    ? soundColors[drumSounds[rowIndex]] ?? Colors.grey
                    : const Color.fromARGB(255, 28, 28, 28);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      sequencerGrid[rowIndex][colIndex] =
                          !sequencerGrid[rowIndex][colIndex];
                    });
                  },
                  child: Container(
                    color: cellColor,
                    margin: const EdgeInsets.all(2),
                  ),
                );
              },
              itemCount: 16 * drumSounds.length,
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < drumSounds.length; i++)
                Expanded(
                  child: Tooltip(
                    message: 'Play ${drumSounds[i]}',
                    child: ElevatedButton(
                      onPressed: () {
                        _playSound(drumSounds[i]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            soundColors[drumSounds[i]] ?? Colors.red,
                        minimumSize: const Size(256, 256),
                      ),
                      child: ImageIcon(
                        AssetImage(
                          soundIcons[drumSounds[i]] ?? 'assets/default.png',
                        ),
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
