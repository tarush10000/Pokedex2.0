// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:sqflite/sqflite.dart';

class PokemonData {
  final String name;
  final File image;
  final int HP;
  final int Attack;
  final int Defense;
  final int SpAttack;
  final int SpDefense;
  final int Speed;
  final String Type;
  final String Ability;
  final String Description;
  PokemonData(
      {required this.name,
      required this.image,
      this.HP = 0,
      this.Attack = 0,
      this.Defense = 0,
      this.SpAttack = 0,
      this.SpDefense = 0,
      this.Speed = 0,
      this.Type = '',
      this.Ability = '',
      this.Description = ''});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image.path,
      'HP': HP,
      'Attack': Attack,
      'Defense': Defense,
      'SpAttack': SpAttack,
      'SpDefense': SpDefense,
      'Speed': Speed,
      'Type': Type,
      'Ability': Ability,
      'Description': Description,
    };
  }
  @override
  String toString() {
    return 'PokemonData{name: $name, image: $image, HP: $HP, Attack: $Attack, Defense: $Defense, SpAttack: $SpAttack, SpDefense: $SpDefense, Speed: $Speed, Type: $Type, Ability: $Ability, Description: $Description}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: unused_local_variable
  final database = openDatabase(
    'pokedex.db',
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE photos(name TEXT PRIMARY KEY, image TEXT, HP INTEGER, Attack INTEGER, Defense INTEGER, SpAttack INTEGER, SpDefense INTEGER, Speed INTEGER, Type TEXT, Ability TEXT, Description TEXT)',
      );
    },
  );
  const storage = FlutterSecureStorage();
  String? apiKey = await storage.read(key: 'API_KEY');
  if (apiKey == null) {
    runApp(const MaterialApp(home: SetApiKeyScreen()));
  } else {
    runApp(MyApp(apiKey: apiKey));
  }
}

class SetApiKeyScreen extends StatefulWidget {
  const SetApiKeyScreen({super.key, Key? newKey});

  @override
  _SetApiKeyScreenState createState() => _SetApiKeyScreenState();
}

class _SetApiKeyScreenState extends State<SetApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set API Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'Enter API Key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveApiKey(_apiKeyController.text);
              },
              child: const Text('Save API Key'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveApiKey(String apiKey) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'API_KEY', value: apiKey);
    runApp(MyApp(apiKey: apiKey));
  }
}

class MyApp extends StatelessWidget {
  final String apiKey;

  const MyApp({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(apiKey: apiKey),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String apiKey;

  const HomeScreen({super.key, required this.apiKey});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _navigateTo(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SearchScreen(apiKey: widget.apiKey)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(apiKey: widget.apiKey)),
        );
        break;
    }
  }

  void removePokemon() {
    final db = openDatabase('pokedex.db');
    db.then((database) {
      database.delete('photos');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text('Pokedex 2.0', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 219, 0, 0),
      ),
      drawer: Drawer(
        width: 90,
        child: Container(
          color: const Color.fromARGB(255, 219, 0, 0),
          child: Center(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true, // Center the content vertically
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    onTap: () {
                      _navigateTo(0);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: const Icon(Icons.list, color: Colors.white),
                    onTap: () {
                      _navigateTo(1);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    onTap: () {
                      _navigateTo(2);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Select an option from the menu',
            style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic)),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String apiKey;
  const SearchScreen({super.key, required this.apiKey});

  @override
  _SearchScreenState createState() => _SearchScreenState();
  
  void addPokemon(String name, File image, int HP, int Attack, int Defense, int SpAttack, int SpDefense, int Speed, String Type, String Ability, String Description) {
    final db = openDatabase('pokedex.db');
    db.then((database) {
      database.insert(
        'photos',
        {
          'name': name,
          'image': image.path,
          'HP': HP,
          'Attack': Attack,
          'Defense': Defense,
          'SpAttack': SpAttack,
          'SpDefense': SpDefense,
          'Speed': Speed,
          'Type': Type,
          'Ability': Ability,
          'Description': Description,
        },
      );
    });
    debugPrint('Pokemon added $name');
  }
}

class _SearchScreenState extends State<SearchScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _type = '';
  String _abilities = '';
  String _description = '';
  late GenerativeModel _model;
  late BuildContext _dialogContext;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: widget.apiKey);
  }

  Future<void> _openImagePicker() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      _showLoadingDialog();

      final imageBytes = await _image!.readAsBytes();
      String responseText = '';
      try{
        final response = await _model.generateContent([
          Content.multi([
            TextPart("Describe in 1 paragraph what the object or plant or animal or human or fictional creature this image is: "),
            DataPart('image/jpeg', imageBytes),
          ])
        ]);
        responseText = response.text?.trim() ?? '';
      }
      catch (error) {
        Navigator.of(_dialogContext).pop();
        debugPrint('Error: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while processing the image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      String response1Text = '';
      String response2Text = '';
      String response3Text = '';
      String response4Text = '';
      String response5Text = '';

      try {
        // Generate the name of the pokemon
        final response1 = await _model.generateContent([
          Content.multi([
            TextPart("Assuming this description: \"$responseText\", make up a 1 word name for it if it is a fictional creature. If it is an existing Pokemon, tell its' real name. If it is a real animal or plant tell its real name. If it is a person, make a non-insulting name if you don't know the name, otherwise return the name. DON'T RETURN ANYTHING OTHER THAN THE NAME."),
          ])
        ]);
        response1Text = response1.text?.trim() ?? '';
        debugPrint('Name: $response1Text]');
        
        // Check if the name already exists in the list
        bool nameExists = await searchPokemonName(response1Text);
        debugPrint('Matched Name: $nameExists');
        if (!nameExists) {
          try{
            final response2 = await _model.generateContent([
              Content.multi([
                TextPart("Assuming this description of a pokemon: \"$responseText\", based on the name generated, \"$response1Text\", provide the HP, Attack, Defense, SpAttack, SpDefense and Speed of the pokemon. If the pokemon doesn't exist or is based on some real plant, animal, human or object, make up the stats that seem to suit it (like high speed stat for a race car but less strength) JUST RETURN THE STATS, NOTHING ELSE."),
              ])
            ]);
            response2Text = response2.text?.trim() ?? '';
            debugPrint('Response 2: $response2Text');
            Map<String, int> extractStats(String response2Text) {
              Map<String, int> stats = {};
              List<String> lines = response2Text.split('\n');
              for (String line in lines) {
                List<String> parts = line.split(':');
                if (parts.length == 2) {
                  String key = parts[0].trim();
                  int value = int.tryParse(parts[1].trim()) ?? 0;
                  stats[key] = value;
                }
              }
              return stats;
            }

            Map<String, int> stats = extractStats(response2Text);
            int hp = stats['HP'] ?? 0;
            int attack = stats['Attack'] ?? 0;
            int defense = stats['Defense'] ?? 0;
            int spAttack = stats['SpAttack'] ?? 0;
            int spDefense = stats['SpDefense'] ?? 0;
            int speed = stats['Speed'] ?? 0;

            debugPrint('Stats: $stats');

            // Generate the typing of the pokemon
            final response3 = await _model.generateContent([
              Content.multi([
                TextPart("Assuming this description of a pokemon: \"$responseText\". Based on the name generated, \"$response1Text\", and the description, provide the typing of the pokemon. JUST RETURN THE TYPING, NOTHING ELSE."),
              ])
            ]);
            response3Text = response3.text?.trim() ?? '';
            debugPrint('Response 3: $response3Text');

            // Generate the description of the pokemon
            final response4 = await _model.generateContent([
              Content.multi([
                TextPart("Assuming this description of a pokemon: \"$responseText\" named \"$response1Text\" and of type \"$response3Text\". Provide a short description of the pokemon. Description could be like a fictional story of the pokemon or any real info. JUST RETURN THE DESCRIPTION, NOTHING ELSE."),
              ])
            ]);
            response4Text = response4.text?.trim() ?? '';
            debugPrint('Response 4 Text: $response4Text');

            // Generate the abilities of the pokemon
            final response5 = await _model.generateContent([
              Content.multi([
                TextPart("Assuming this description of a pokemon: \"$responseText\" named \"$response1Text\" and of type \"$response3Text\". Provide a list of abilities of pokemon. JUST RETURN A MAXIMUM OF 3 ABILITIES AND SMALL DESCRIPTION OF EACH ABILITY, NOTHING ELSE. DON'T WRITE ANY OTHER TEXT AND PRESENT IT IN A LIST FORMAT WITHOUT ASTERISKS."),
              ])
            ]);
            response5Text = response5.text?.trim() ?? '';
            debugPrint('Response 5: $response5Text');

            // Add the pokemon to the database
            _type = response3Text;
            _description = response4Text;
            _abilities = response5Text;
            widget.addPokemon(response1Text, _image!, hp, attack, defense, spAttack, spDefense, speed, _type, _abilities, _description);

            Navigator.of(_dialogContext).pop();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(response1.text!, style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Center(
                            child: Container(
                              width: 150.0,
                              height: 150.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => speak(),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromARGB(255, 219, 0, 0),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                                width: 120,
                                height: 120,
                                child: SpiderChart(
                                  data: [
                                    hp.toDouble(),
                                    attack.toDouble(),
                                    defense.toDouble(),
                                    spAttack.toDouble(),
                                    spDefense.toDouble(),
                                    speed.toDouble(),
                                  ],
                                  maxValue: 150,
                                  colors: const <Color>[
                                    Colors.red,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.yellow,
                                    Colors.indigo,
                                    Colors.orange,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HP: $hp}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Attack: $attack', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Defense: $defense', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Attack: $spAttack', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Defense: $spDefense', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Speed: $speed', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                ],
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: _getGradientForType(_type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Type:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(_type, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                        const Text(
                          'Abilities:',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _abilities,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Description:',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () => okPressed(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
        }
        catch(error){
          Navigator.of(_dialogContext).pop();
          debugPrint('Error: $error');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while processing the image. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        }
        else{
          Navigator.of(_dialogContext).pop();
          final pokemon = await searchPokemon(response1Text);
          int hp = pokemon.HP;
          int attack = pokemon.Attack;
          int defense = pokemon.Defense;
          int spAttack = pokemon.SpAttack;
          int spDefense = pokemon.SpDefense;
          int speed = pokemon.Speed;
          _type = pokemon.Type;
          _abilities = pokemon.Ability;
          _description = pokemon.Description;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(response1.text!, style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Center(
                          child: Container(
                              width: 150.0,
                              height: 150.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            ),
                        ),
                        Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => speak(),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromARGB(255, 219, 0, 0),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                          SizedBox(
                                width: 120,
                                height: 120,
                                child: SpiderChart(
                                  data: [
                                    hp.toDouble(),
                                    attack.toDouble(),
                                    defense.toDouble(),
                                    spAttack.toDouble(),
                                    spDefense.toDouble(),
                                    speed.toDouble(),
                                  ],
                                  maxValue: 150,
                                  colors: const <Color>[
                                    Colors.red,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.yellow,
                                    Colors.indigo,
                                    Colors.orange,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HP: $hp}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Attack: $attack', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Defense: $defense', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Attack: $spAttack', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Defense: $spDefense', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Speed: $speed', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                ],
                              ),
                        ],
                    ),
                    const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: _getGradientForType(_type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Type:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(_type, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                        const Text(
                          'Abilities:',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _abilities,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Description:',
                          style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () => okPressed(),
                          child: const Text('OK'),
                        ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
      catch (error) {
        Navigator.of(_dialogContext).pop();
        debugPrint('Error: $error');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while processing the image. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return AlertDialog(
          title: const Text('Searching', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
          iconColor: const Color.fromARGB(255, 224, 50, 59),
          alignment: Alignment.center,
          buttonPadding: EdgeInsets.zero,
          shadowColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 224, 50, 59),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                color: Colors.white,
                backgroundColor: Color.fromARGB(255, 224, 50, 59),
              )),
              Center(child: SizedBox(height: 16)),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                  });
                  Navigator.of(_dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 255, 0, 0))),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 219, 0, 0),
      ),
      body: Theme(
        data: ThemeData(
          primaryColor: const Color.fromARGB(255, 219, 0, 0),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: screenWidth * 0.8,
                height: screenWidth * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                ),
                child: _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.contain,
                      )
                    : Container(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _openImagePicker,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 219, 0, 0),
                    backgroundColor: Colors.white, // Icon color
                    shape: const CircleBorder(), // Make the button circular
                    padding:
                        const EdgeInsets.all(16), // Adjust padding as needed
                  ),
                  child: const Icon(
                    Icons.camera,
                    color: Color.fromARGB(255, 219, 0, 0), // Icon color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  searchPokemon(String s) async {
    final database = await openDatabase('pokedex.db');
    final List<Map<String, dynamic>> maps = await database.query('photos', where: 'name = ?', whereArgs: [s]);
    if (maps.isNotEmpty) {
      return PokemonData(
        name: maps[0]['name'],
        image: File(maps[0]['image']),
        HP: maps[0]['HP'],
        Attack: maps[0]['Attack'],
        Defense: maps[0]['Defense'],
        SpAttack: maps[0]['SpAttack'],
        SpDefense: maps[0]['SpDefense'],
        Speed: maps[0]['Speed'],
        Type: maps[0]['Type'],
        Ability: maps[0]['Ability'],
        Description: maps[0]['Description'],
      );
    }
  }
  
  Future<bool> searchPokemonName(String response1text) async {
  final database = await openDatabase('pokedex.db');
  List<Map<String, dynamic>> list = await database.rawQuery(
    'SELECT * FROM photos WHERE name = ?',
    [response1text],
  );
  debugPrint('List: $list');
  return list.isNotEmpty;
}
  speak() async {
    debugPrint('Speaking');
    const platform = MethodChannel('ttschannel');
    debugPrint(platform.toString());
    try {
      platform.invokeMethod('speak', {'text': _description});
      debugPrint('Spoke');
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }
  
  okPressed() async {
    debugPrint('OK Pressed');
    Navigator.pop(context);
    const platform = MethodChannel('ttschannel');
    try {
      await platform.invokeMethod('pause');
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }
  
  _getGradientForType(String type) {
    Map<String, List<Color>> typeColors = {
      'Fire': [Colors.red],
      'Water': [Colors.blue],
      'Grass': [Colors.green],
      'Electric': [Colors.yellow],
      'Steel': [Colors.grey],
      'Ice': [Colors.cyan],
      'Psychic': [Colors.purple],
      'Dragon': [Colors.indigo],
      'Dark': [Colors.black87],
      'Fairy': [Colors.pink],
      'Fighting': [Colors.brown],
      'Flying': [Colors.lightBlueAccent],
      'Poison': [Colors.purple],
      'Ground': [Colors.brown],
      'Rock': [Colors.brown],
      'Bug': [Colors.lightGreen],
      'Ghost': [Colors.deepPurple],
    };

    List<String> types = type.split('/');
    if (types.length == 2) {
      return LinearGradient(
        colors: [
          ...?typeColors[types[0]],
          ...?typeColors[types[1]],
        ],
      );
    } else if (types.length == 1) {
      return LinearGradient(
        colors: typeColors[types[0]] ?? [Colors.white, Colors.white],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.white, Colors.white],
      );
    }
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<PokemonData> _pokemonList = [];

  @override
  void initState() {
    super.initState();
    _loadPokemonData();
  }

  Future<void> _loadPokemonData() async {
    final database = await openDatabase('pokedex.db');
    final List<Map<String, dynamic>> maps = await database.query('photos');

    setState(() {
      _pokemonList = List.generate(maps.length, (i) {
        return PokemonData(
          name: maps[i]['name'],
          image: File(maps[i]['image']),
          HP: maps[i]['HP'],
          Attack: maps[i]['Attack'],
          Defense: maps[i]['Defense'],
          SpAttack: maps[i]['SpAttack'],
          SpDefense: maps[i]['SpDefense'],
          Speed: maps[i]['Speed'],
          Type: maps[i]['Type'],
          Ability: maps[i]['Ability'],
          Description: maps[i]['Description'],
        );
      });
    });
  }

void _showPokemonDetails(PokemonData pokemon) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          pokemon.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Make background transparent to show gradient
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    pokemon.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => speak(pokemon.Description),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: SpiderChart(
                                  data: [
                                    pokemon.HP.toDouble(),
                                    pokemon.Attack.toDouble(),
                                    pokemon.Defense.toDouble(),
                                    pokemon.SpAttack.toDouble(),
                                    pokemon.SpDefense.toDouble(),
                                    pokemon.Speed.toDouble(),
                                  ],
                                  maxValue: 150,
                                  colors: const <Color>[
                                    Colors.red,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.yellow,
                                    Colors.indigo,
                                    Colors.orange,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HP: ${pokemon.HP}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Attack: ${pokemon.Attack}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Defense: ${pokemon.Defense}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Attack: ${pokemon.SpAttack}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Sp. Defense: ${pokemon.SpDefense}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                  Text('Speed: ${pokemon.Speed}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: _getGradientForType(pokemon.Type),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Type:',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  pokemon.Type,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Abilities:',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pokemon.Ability,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Description:',
                            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pokemon.Description,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () => okPressed(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      );
    },
  );
}


  LinearGradient _getGradientForType(String type) {
    Map<String, List<Color>> typeColors = {
      'Fire': [Colors.red],
      'Water': [Colors.blue],
      'Grass': [Colors.green],
      'Electric': [Colors.yellow],
      'Steel': [Colors.grey],
      'Ice': [Colors.cyan],
      'Psychic': [Colors.purple],
      'Dragon': [Colors.indigo],
      'Dark': [Colors.black87],
      'Fairy': [Colors.pink],
      'Fighting': [Colors.brown],
      'Flying': [Colors.lightBlueAccent],
      'Poison': [Colors.purple],
      'Ground': [Colors.brown],
      'Rock': [Colors.brown],
      'Bug': [Colors.lightGreen],
      'Ghost': [Colors.deepPurple],
    };

    List<String> types = type.split('/');
    if (types.length == 2) {
      return LinearGradient(
        colors: [
          ...?typeColors[types[0]],
          ...?typeColors[types[1]],
        ],
      );
    } else if (types.length == 1) {
      return LinearGradient(
        colors: typeColors[types[0]] ?? [Colors.white, Colors.white],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.white, Colors.white],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 219, 0, 0),
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: ListView.builder(
                itemCount: _pokemonList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 191, 6, 3),
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(width: 10), // Spacing between number and image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  _pokemonList[index].image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          _pokemonList[index].name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _pokemonList[index].Type,
                          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                        onTap: () => _showPokemonDetails(_pokemonList[index]),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        width: MediaQuery.of(context).size.width * 0.8,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  );
                },
              )

      ),
    );
  }
  
  speak(String description) {
    debugPrint('Speaking');
    const platform = MethodChannel('ttschannel');
    debugPrint(platform.toString());
    try {
      platform.invokeMethod('speak', {'text': description});
      debugPrint('Spoke');
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }
  
  okPressed() async {
    debugPrint('OK Pressed');
    Navigator.pop(context);
    const platform = MethodChannel('ttschannel');
    try {
      await platform.invokeMethod('pause');
    } on PlatformException catch (e) {
      debugPrint("Failed to invoke method: '${e.message}'.");
    }
  }
}

class SettingsScreen extends StatelessWidget {
  final String apiKey;

  const SettingsScreen({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 182, 32, 24),
      ),
      body: Container(
        color: const Color.fromARGB(255, 224, 50, 59),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 224, 50, 59), backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateApiKeyScreen(currentApiKey: apiKey),
                  ),
                );
              },
              child: const Text('Change API Key', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 224, 50, 59), backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                cleanDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo list cleared')));
              },
              child: const Text('Clear Photo List', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void cleanDatabase() async {
    final db = await openDatabase('pokedex.db');
    await db.delete('photos');
  }
}

class UpdateApiKeyScreen extends StatefulWidget {
  final String currentApiKey;

  const UpdateApiKeyScreen({super.key, required this.currentApiKey});

  @override
  _UpdateApiKeyScreenState createState() => _UpdateApiKeyScreenState();
}

class _UpdateApiKeyScreenState extends State<UpdateApiKeyScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentApiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update API Key', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 182, 32, 24),
      ),
      body: Container(
        color: const Color.fromARGB(255, 224, 50, 59),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                labelStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 224, 50, 59), backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                // Save the new API key and go back
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
