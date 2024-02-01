# DRUMMR 

A Drum instrument sequencer and player

coded using visual studio code

## Navigation
- [Features_and_Usage](#Features_and_Usage)
- [Installation](#Installation)
- [Dependancies](#Dependancies)


## Features_and_Usage

- **Sequencer Grid:** Draw a drum rhythm on the sequencer grid. Each row represents a different drum instrument. Colour of cell is the same as colour of the drum pad on the bottom to help identify the instrument.

- **The Drum Kit :** Mix and match between the kick, snare, hi-hat, high tom, low tom to create unique sequences. Click on a drum pad to play back a specific instrument.

- **Playback Controls:** Play, pause, and stop the sequencer to hear your drum patterns in action.

- **Storing and Manipulating Drum Patterns:** Click Save which will save the current drum pattern on the sequencer grid to storage. Click the Load on the right of the save button to load the saved pattern from storage to the sequencer grid. This will overwrite the current pattern on the grid, if there is any. Click the Clear button located on the top right to reset the sequencer grid state.

## Installation

1. Navigate to the downloaded folder
2. Install dependancies by running "flutter pub get"
3. Run the program by running "flutter run"
4. CHOOSE between Chrome (1) or Edge (2)

## Dependancies

- [flutter](https://flutter.dev/): The framework used. SDK 3.13.6

- [flutter_sequencer](https://pub.dev/packages/flutter_sequencer):Flutter package for creating and playing audio sequences.

- [audioplayers](https://pub.dev/packages/audioplayers): A Flutter plugin to play audio files.

- [hive](https://pub.dev/packages/hive): A database.

- [hive_flutter](https://pub.dev/packages/hive_flutter): Official Hive plugin for Flutter, providing support for Flutter widgets.

- [path_provider](https://pub.dev/packages/path_provider): A Flutter plugin for determining application-specific paths.

