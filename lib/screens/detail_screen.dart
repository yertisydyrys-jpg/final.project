import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';
import '../providers/theme_settings.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false;
  bool _isCardActive = true;
  final _nameController = TextEditingController();
  final _newNoteController = TextEditingController();

  String _displayName = 'Guest User';
  List<NoteItem> _notes = [];
  bool _isLoadingLocalData = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_display_name') ?? 'Guest User';
    final savedNotes = prefs.getString('notes_list');

    final notes = savedNotes == null
        ? <NoteItem>[]
        : (jsonDecode(savedNotes) as List<dynamic>)
              .map(
                (item) =>
                    NoteItem.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList();

    if (!mounted) return;

    setState(() {
      _displayName = name;
      _nameController.text = name;
      _notes = notes;
      _isLoadingLocalData = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('user_display_name', name);

    if (!saved) {
      throw StateError('Could not save the display name.');
    }

    if (!mounted) return;
    setState(() {
      _displayName = name.isEmpty ? 'Guest User' : name;
    });
  }

  Future<void> _persistNotes() async {
    final json = jsonEncode(_notes.map((note) => note.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('notes_list', json);

    if (!saved) {
      throw StateError('Could not save the notes.');
    }
  }

  Future<void> _addNote() async {
    final title = _newNoteController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final note = NoteItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      dateText: now.toLocal().toString().split(' ').first,
      isCompleted: false,
    );

    setState(() {
      _notes.insert(0, note);
      _newNoteController.clear();
    });

    await _persistNotes();
  }

  Future<void> _toggleNote(int index, bool isCompleted) async {
    final note = _notes[index];

    setState(() {
      _notes[index] = NoteItem(
        id: note.id,
        title: note.title,
        dateText: note.dateText,
        isCompleted: isCompleted,
      );
    });

    await _persistNotes();
  }

  Future<void> _deleteNote(int index) async {
    setState(() {
      _notes.removeAt(index);
    });

    await _persistNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayName),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF02569B), Color(0xFF0175C2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: const Color(0xFF01B569),
                              child: Container(
                                height: 160,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Premium Black Card',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          _isCardActive
                                              ? Icons.check_circle
                                              : Icons.pause_circle,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '**** **** **** 8842',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ALIKHAN DEV',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '08/28',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 35,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  _isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  size: 20,
                                  color: const Color(0xFF02569B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isBookmarked = !_isBookmarked;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Personal Visa Platinum',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monthly Limit: \$10,000.00',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Card Badges & Perks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: const [
                              Chip(
                                avatar: Icon(Icons.flash_on, size: 16),
                                label: Text('Contactless'),
                              ),
                              Chip(
                                avatar: Icon(Icons.security, size: 16),
                                label: Text('3D Secure'),
                              ),
                              Chip(
                                avatar: Icon(Icons.card_giftcard, size: 16),
                                label: Text('2% Cashback'),
                              ),
                              Chip(
                                avatar: Icon(Icons.flight, size: 16),
                                label: Text('Lounge Key'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 0,
                            color: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              title: const Text('Card Status'),
                              subtitle: Text(
                                _isCardActive
                                    ? 'Active and operational'
                                    : 'Frozen',
                              ),
                              value: _isCardActive,
                              onChanged: (val) {
                                setState(() {
                                  _isCardActive = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _saveName,
                                  child: const Text('Save'),
                                ),
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Dark mode'),
                                value: context
                                    .watch<ThemeSettings>()
                                    .isDarkMode,
                                onChanged: (value) async {
                                  await context
                                      .read<ThemeSettings>()
                                      .setDarkMode(value);
                                },
                              ),
                              const Divider(),
                              TextField(
                                controller: _newNoteController,
                                decoration: InputDecoration(
                                  labelText: 'New note',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _addNote,
                                  ),
                                ),
                                onSubmitted: (_) => _addNote(),
                              ),
                              if (_isLoadingLocalData)
                                const LinearProgressIndicator()
                              else
                                ...List.generate(_notes.length, (index) {
                                  final note = _notes[index];

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Checkbox(
                                      value: note.isCompleted,
                                      onChanged: (value) async {
                                        if (value != null) {
                                          await _toggleNote(index, value);
                                        }
                                      },
                                    ),
                                    title: Text(
                                      note.title,
                                      style: TextStyle(
                                        decoration: note.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(note.dateText),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        await _deleteNote(index);
                                      },
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02569B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction action executed!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'New Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
