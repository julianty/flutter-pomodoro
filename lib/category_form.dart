import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/category_picker.dart';
import 'package:flutter_pomodoro/firestore_service.dart';

List<Color> defaultColors = [
  Colors.pinkAccent,
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.green,
  Colors.deepPurple,
  Colors.yellow,
];

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController textController;
  Color _selectedColor = defaultColors.first;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  void onSelectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void onSaveCategory() {
    User? user = FirebaseAuth.instance.currentUser;
    Category category = Category(
      color: _selectedColor,
      label: textController.text,
      icon: (Icons.ac_unit_outlined),
    );
    FirestoreService().saveCategory(user!.uid, category);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(controller: textController),
          Row(
            children: [
              for (var color in defaultColors)
                ColorCircle(
                  color: color,
                  onTap: onSelectColor,
                  selected: color == _selectedColor,
                ),
            ],
          ),
          TextButton(
            onPressed: () {
              onSaveCategory();
              Navigator.pop(context);
            },
            child: Text('Save Category'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;
  final void Function(Color) onTap;
  final bool selected;
  const ColorCircle({
    super.key,
    required this.color,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(color);
      },
      child: Container(
        decoration: selected
            ? BoxDecoration(shape: BoxShape.circle, border: Border.all())
            : null,
        child: CircleAvatar(backgroundColor: color),
      ),
    );
  }
}
