import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/section_card.dart';

final Set<Category> defaultCategories = {
  Category(label: 'Dev', icon: Icons.code, color: Colors.brown, id: 'dev'),
  Category(
    label: 'Hobby',
    icon: Icons.sports_esports,
    color: Colors.deepOrangeAccent,
    id: 'hobby',
  ),
  Category(
    label: 'Recreation',
    icon: Icons.self_improvement,
    color: Colors.blueGrey,
    id: 'rec',
  ),
  Category(
    label: 'Meetings',
    icon: Icons.groups,
    color: Colors.lightGreen,
    id: 'meetings',
  ),
};

class Category {
  final String label;
  final IconData icon;
  final Color color;
  String? id;

  Category({
    required this.label,
    required this.icon,
    this.color = Colors.indigo,
    this.id,
  });
}

class CategoryPicker extends StatelessWidget {
  final Set<Category> categories;
  final void Function(Category) onChanged;
  final Category? selectedCategory;
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'CATEGORY',
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.7,
        shrinkWrap: true,
        children: [
          for (var cat in categories)
            CategoryCard(
              category: cat,
              isActive: cat.id == selectedCategory?.id,
              onTap: onChanged,
            ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isActive;
  final void Function(Category) onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: isActive
              ? null
              : Border.all(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  width: 0.5,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon),
            Center(child: Text(category.label)),
          ],
        ),
      ),
    );
  }
}
