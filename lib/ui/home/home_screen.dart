import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/domain/item/item.dart';
import 'package:shopping_list/domain/item/item_controller.dart';
import 'package:shopping_list/ui/edit/edit_screen.dart';
import 'package:shopping_list/ui/widgets/constants.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shopping_list/utils/records.dart';
import 'package:yaru/yaru.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const route = '/';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> selectedCategories = [];

  bool reordering = false;

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(itemControllerProvider)
        .map((e) => (e.category, e.categoryAccent))
        .toSet();

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.grey.lighten(37),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              children: [
                kVerticalSpace12,
                _NewItemTile(
                  onSave: (values) {
                    ref.read(itemControllerProvider.notifier).add(
                          values['name']!,
                          values['category']!,
                          1,
                        );
                  },
                  saveLabel: 'Dodaj',
                ),
                _buildFilters(categories),
                _ItemList(
                  categories: selectedCategories,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(Set<(String, int)> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: <Widget>[
          const _MenuOptionsButton(),
        ]
            .followedBy(
              categories.mapR2(
                (category, color) => FilterChip(
                  label: Text(category),
                  selected: selectedCategories.contains(category),
                  selectedColor: Color(color),
                  onSelected: (s) => setState(() {
                    if (s) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  }),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Icon(Icons.shopping_cart),
      ),
      actions: [
        YaruWindowControl(
          type: YaruWindowControlType.close,
          onTap: () => SystemNavigator.pop(),
        ),
        kHorizontalSpace12,
      ],
    );
  }
}

class _MenuOptionsButton extends ConsumerStatefulWidget {
  const _MenuOptionsButton();

  @override
  ConsumerState<_MenuOptionsButton> createState() => _MenuOptionsButtonState();
}

class _MenuOptionsButtonState extends ConsumerState<_MenuOptionsButton> {
  final controller = MenuController();

  @override
  Widget build(BuildContext context) {
    final itemController = ref.watch(itemControllerProvider.notifier);

    return MenuAnchor(
      controller: controller,
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.check),
          onPressed: () =>
              itemController.updateAll((e) => e.copyWith(purchased: true)),
          child: const Text('Mark all as completed'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_forever),
          onPressed: () => itemController.removeWhere((e) => true),
          child: const Text('Remove all'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete),
          onPressed: () => itemController.removeWhere((e) => e.purchased),
          child: const Text('Remove all completed'),
        ),
      ],
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => controller.open(),
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  const _ItemList({this.categories = const []});

  final List<String> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref
        .watch(itemControllerProvider)
        .where((e) => categories.isEmpty || categories.contains(e.category))
        .toList();

    return Column(
      children: items.reversed.map((e) => _ItemTile(item: e)).toList(),
    );
  }
}

class _ItemTile extends ConsumerStatefulWidget {
  const _ItemTile({
    required this.item,
  });

  final Item item;

  @override
  ConsumerState<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends ConsumerState<_ItemTile> {
  @override
  Widget build(BuildContext context) {
    final accent = Color(widget.item.categoryAccent);

    return YaruTile(
      title: Text(widget.item.name),
      subtitle: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.6),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          widget.item.category,
          style: TextStyle(fontSize: 14, color: accent.darken(70)),
        ),
      ),
      trailing: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: Colors.indigo.withOpacity(0.03),
            ),
            onPressed: widget.item.quantity >= 10
                ? null
                : () {
                    ref.read(itemControllerProvider.notifier).update(
                          widget.item
                              .copyWith(quantity: widget.item.quantity + 1),
                        );
                  },
          ),
          SizedBox(
            width: 32,
            child: Text(
              widget.item.quantity.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            style: IconButton.styleFrom(
              backgroundColor: Colors.indigo.withOpacity(0.03),
            ),
            onPressed: widget.item.quantity <= 1
                ? null
                : () {
                    ref.read(itemControllerProvider.notifier).update(
                          widget.item
                              .copyWith(quantity: widget.item.quantity - 1),
                        );
                  },
          ),
          kHorizontalSpace24,
          YaruIconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed(
              EditScreen.route,
              arguments: widget.item,
            ),
          ),
          kHorizontalSpace8,
          YaruIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(itemControllerProvider.notifier).remove(widget.item.id);
            },
          ),
        ],
      ),
      leading: YaruCheckbox(
        value: widget.item.purchased,
        onChanged: (_) {
          ref
              .read(itemControllerProvider.notifier)
              .update(widget.item.copyWith(purchased: !widget.item.purchased));
        },
      ),
    );
  }
}

class _NewItemTile extends ConsumerStatefulWidget {
  const _NewItemTile({
    required this.saveLabel,
    required this.onSave,
  });

  final String saveLabel;
  final ValueChanged<Map<String, String>> onSave;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __NewItemTileState();
}

class __NewItemTileState extends ConsumerState<_NewItemTile> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FormBuilder(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Nazwa',
                  fillColor: Colors.white,
                ),
                validator: FormBuilderValidators.required(),
              ),
            ),
            kHorizontalSpace12,
            Expanded(
              child: FormBuilderTextField(
                name: 'category',
                decoration: const InputDecoration(
                  labelText: 'Kategoria',
                  fillColor: Colors.white,
                ),
                validator: FormBuilderValidators.required(),
                onSubmitted: (_) => _onSave(),
              ),
            ),
            kHorizontalSpace12,
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(widget.saveLabel),
              onPressed: () => _onSave(),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.saveAndValidate()) {
      widget.onSave(_formKey.currentState!.value.cast());
      _formKey.currentState!.reset();
    }
  }
}
