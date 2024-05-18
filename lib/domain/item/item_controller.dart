import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shopping_list/domain/item/item.dart';
import 'package:uuid/v4.dart';

part 'item_controller.g.dart';

final _colors = [
  0xffe0b2c1,
  0xffe1f5fe,
  0xffe7f9f9,
  0xfffff9e6,
  0xfff3e8ff,
  0xffc2e0d0,
];

@riverpod
class ItemController extends _$ItemController {
  @override
  List<Item> build() => [
        _createItem(
          name: 'Mleko',
          category: 'Nabiał',
          quantity: 3,
        ),
        _createItem(
          name: 'Pierś z kurczaka',
          category: 'Mięso',
          quantity: 2,
        ),
        _createItem(
          name: 'Twaróg 0%',
          category: 'Nabiał',
          quantity: 1,
        ),
        _createItem(
          name: 'Bułki',
          category: 'Pieczywo',
          quantity: 6,
        ),
        _createItem(
          name: 'Croissant',
          category: 'Pieczywo',
          quantity: 2,
        ),
      ];

  void add(String name, String category, int quantity) {
    state = <Item>[
      ...state,
      _createItem(
        name: name,
        category: category,
        quantity: quantity,
      ),
    ];
  }

  Item _createItem({
    required String name,
    required String category,
    required int quantity,
  }) {
    final color = _colors[category.hashCode % _colors.length];
    return Item(
      id: const UuidV4().generate(),
      name: name,
      category: category,
      categoryAccent: color,
      quantity: quantity,
    );
  }

  void update(Item item) {
    item = item.copyWith(
      categoryAccent: _colors[item.category.hashCode % _colors.length],
    );

    state = state
        .map(
          (e) => e.id == item.id ? item : e,
        )
        .toList();
  }

  void updateAll(Item Function(Item) update) {
    state = state
        .map(
          (e) => update(e).copyWith(
            categoryAccent:
                _colors[update(e).category.hashCode % _colors.length],
          ),
        )
        .toList();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void removeWhere(bool Function(Item) predicate) {
    state = state.whereNot((item) => predicate(item)).toList();
  }
}
