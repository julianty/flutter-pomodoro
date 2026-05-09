// const List<IconData> defaultIcons = [
//   Icons.code,
//   Icons.sports_esports,
//   Icons.self_improvement,
//   Icons.groups,
//   Icons.menu_book,
//   Icons.fitness_center,
//   Icons.brush,
//   Icons.music_note,
//   Icons.science,
//   Icons.work_outline,
//   Icons.favorite_outline,
//   Icons.travel_explore,
// ];

import 'package:flutter/material.dart';

List<String> defaultIcons = [
  'development',
  'gaming',
  'recreation',
  'meetings',
  'reading',
  'fitness',
  'art',
  'music',
  'study',
  'work',
  'love',
  'travel',
];

Map<String, IconData> iconMap = {
  'development': Icons.code,
  'gaming': Icons.sports_esports,
  'recreation': Icons.self_improvement,
  'meetings': Icons.groups,
  'reading': Icons.menu_book,
  'fitness': Icons.fitness_center,
  'art': Icons.brush,
  'music': Icons.music_note,
  'study': Icons.science,
  'work': Icons.work_outline,
  'love': Icons.favorite_outline,
  'travel': Icons.travel_explore,
};

final reverseIconMap = Map.fromEntries(
  iconMap.entries.map((e) => MapEntry(e.value, e.key)),
);
