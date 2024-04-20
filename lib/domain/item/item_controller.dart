import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shopping_list/domain/item/item.dart';
import 'package:uuid/v4.dart';

part 'item_controller.g.dart';

@riverpod
class ItemController extends _$ItemController {
  @override
  List<Item> build() => [
        Item(
          id: const UuidV4().generate(),
          name: 'Mleko',
          category: 'Nabiał',
          quantity: 3,
        ),
        Item(
          id: const UuidV4().generate(),
          name: 'Pierś z kurczaka',
          category: 'Mięso',
          quantity: 2,
        ),
        Item(
          id: const UuidV4().generate(),
          name: 'Twaróg 0%',
          category: 'Nabiał',
          quantity: 1,
        ),
        Item(
          id: const UuidV4().generate(),
          name: 'Bułki',
          category: 'Pieczywo',
          quantity: 6,
        ),
        Item(
          id: const UuidV4().generate(),
          name: 'Croissant',
          category: 'Pieczywo',
          quantity: 2,
        ),
      ];

  void add(String name, String category, int quantity) {
    state = <Item>[
      ...state,
      Item(
        id: const UuidV4().generate(),
        name: name,
        category: category,
        quantity: quantity,
      ),
    ];
  }

  void update(Item item) {
    state = state.map((e) => e.id == item.id ? item : e).toList();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
