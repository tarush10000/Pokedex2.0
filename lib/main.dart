// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
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
  final List<PokemonData> _photos = [];

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
          MaterialPageRoute(builder: (context) => ListScreen(photos: _photos)),
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
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('Pokedex 2.0', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(204, 50, 42, 100),
      ),
      drawer: Drawer(
        width: 90,
        child: Container(
          color: Colors.red,
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

  const SearchScreen(
      {super.key, required this.apiKey});

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
                            child: SizedBox(
                              width: 150.0,
                              height: 150.0,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Center(
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: SpiderChart(
                                data: [
                                  hp / 1,
                                  attack / 1,
                                  defense / 1,
                                  spAttack / 1,
                                  spDefense / 1,
                                  speed / 1,
                                ],
                                maxValue: 150, // the maximum value that you want to represent (essentially sets the data scale of the chart)
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
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('HP: $hp'),
                                  Text('Attack: $attack'),
                                  Text('Defense: $defense'),
                                  Text('Special Attack: $spAttack'),
                                  Text('Special Defense: $spDefense'),
                                  Text('Speed: $speed'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Text('Type:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(response3Text),
                      const Text('Abilities:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(_abilities),
                      const Text('Description:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(_description),
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
                          child: SizedBox(
                            width: 150.0,
                            height: 150.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Center(
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: SpiderChart(
                              data: [
                                hp / 1,
                                attack / 1,
                                defense / 1,
                                spAttack / 1,
                                spDefense / 1,
                                speed / 1,
                              ],
                              maxValue: 150, // the maximum value that you want to represent (essentially sets the data scale of the chart)
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
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HP: $hp'),
                                Text('Attack: $attack'),
                                Text('Defense: $defense'),
                                Text('Special Attack: $spAttack'),
                                Text('Special Defense: $spDefense'),
                                Text('Speed: $speed'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Text('Type:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(response3Text),
                    const Text('Abilities:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(_abilities),
                    const Text('Description:', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(_description),
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
          iconColor: Colors.red,
          alignment: Alignment.center,
          buttonPadding: EdgeInsets.zero,
          shadowColor: Colors.black,
          backgroundColor: Colors.red,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                color: Colors.white,
                backgroundColor: Colors.red,
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
      backgroundColor: Colors.red,
      appBar: AppBar(
        title:
            const Text('Search', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ),
      body: Theme(
        data: ThemeData(
          primaryColor: Colors.red,
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
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white, // Icon color
                    shape: const CircleBorder(), // Make the button circular
                    padding:
                        const EdgeInsets.all(16), // Adjust padding as needed
                  ),
                  child: const Icon(
                    Icons.camera,
                    color: Colors.red, // Icon color
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
}

class ListScreen extends StatelessWidget {
  final List<PokemonData> photos;

  const ListScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.file(photos[index].image),
            title: Text(photos[index].name),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String apiKey;

  const SettingsScreen(
      {super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateApiKeyScreen(currentApiKey: apiKey),
                  ),
                );
              },
              child: const Text('Change API Key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cleanDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo list cleared')));
              },
              child: const Text('Clear Photo List'),
            ),
          ],
        ),
      ),
    );
  }
  
  void cleanDatabase() {
  final db = openDatabase('pokedex.db');
  db.then((database) {
    database.delete('photos');
  });
  }
}

class UpdateApiKeyScreen extends StatefulWidget {
  final String currentApiKey;

  const UpdateApiKeyScreen({super.key, required this.currentApiKey});
  @override
  _UpdateApiKeyScreenState createState() => _UpdateApiKeyScreenState();
}

class _UpdateApiKeyScreenState extends State<UpdateApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.currentApiKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update API Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'Enter New API Key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateApiKey(_apiKeyController.text);
              },
              child: const Text('Update API Key'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateApiKey(String newApiKey) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'API_KEY', value: newApiKey);
    Navigator.pop(context); // Navigate back after updating the API key
  }
}
