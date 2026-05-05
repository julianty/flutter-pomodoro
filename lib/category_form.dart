import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/category_picker.dart';
import 'package:flutter_pomodoro/firestore_service.dart';

const List<Color> defaultColors = [
  Colors.pinkAccent,
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.green,
  Colors.deepPurple,
  Colors.yellow,
];

const List<IconData> defaultIcons = [
  Icons.code,
  Icons.sports_esports,
  Icons.self_improvement,
  Icons.groups,
  Icons.menu_book,
  Icons.fitness_center,
  Icons.brush,
  Icons.music_note,
  Icons.science,
  Icons.work_outline,
  Icons.favorite_outline,
  Icons.travel_explore,
];

class CategoryForm extends StatefulWidget {
  final Category? category;
  const CategoryForm({super.key, this.category});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController textController;
  Color _selectedColor = defaultColors.first;
  IconData _selectedIcon = defaultIcons.first;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    if (widget.category != null) {
      textController.text = widget.category!.label;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  void onSelectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void onSelectIcon(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  void onSaveCategory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final category = Category(
      color: _selectedColor,
      label: textController.text,
      icon: _selectedIcon,
    );

    if (_isEditing) {
      category.id = widget.category!.id;
      FirestoreService().updateCategory(user.uid, category);
    } else {
      FirestoreService().saveCategory(user.uid, category);
    }
  }

  void handleDelete() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    FirestoreService().deleteCategory(user.uid, widget.category!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'Edit category' : 'New category',
                style: textTheme.titleMedium,
              ),
              if (_isEditing)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.error),
                  onPressed: () {
                    handleDelete();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Color', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var color in defaultColors)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ColorCircle(
                    color: color,
                    onTap: onSelectColor,
                    selected: color == _selectedColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Icon', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var icon in defaultIcons)
                GestureDetector(
                  onTap: () => onSelectIcon(icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: icon == _selectedIcon
                          ? _selectedColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: icon == _selectedIcon
                            ? _selectedColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            onPressed: () {
              onSaveCategory();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
      onTap: () => onTap(color),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2.5,
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
