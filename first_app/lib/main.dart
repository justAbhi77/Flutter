import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'First App',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromRGBO(202, 211, 200, 1.0)),
            scaffoldBackgroundColor: Color.fromRGBO(44, 58, 71, 1)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getnext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    var style = TextStyle(color: Color.fromRGBO(236, 240, 241, 1));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A random Awesome idea hehahahahahahahahah:',
              style: style,
            ),
            WordPairText(pair: pair),
            // ↓ Add this.
            ElevatedButton(
              onPressed: () {
                appState.getnext();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Color.fromRGBO(44, 58, 71, 1);
                    }
                    return Color.fromRGBO(
                        0, 0, 0, 1); // Use the component's default.
                  },
                ),
              ),
              child: Text(
                'Next',
                style: style,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WordPairText extends StatelessWidget {
  const WordPairText({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: Color.fromRGBO(86, 97, 108, 1),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
