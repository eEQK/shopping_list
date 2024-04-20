import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/domain/item/item.dart';
import 'package:shopping_list/domain/item/item_controller.dart';
import 'package:shopping_list/ui/widgets/constants.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:yaru/yaru.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(itemControllerProvider).map((e) => e.category).toSet();

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

  Widget _buildFilters(Set<String> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: categories
            .map(
              (e) => FilterChip(
                label: Text(e),
                selected: selectedCategories.contains(e),
                onSelected: (s) => setState(() {
                  if (s) {
                    selectedCategories.add(e);
                  } else {
                    selectedCategories.remove(e);
                  }
                }),
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
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    if (_editMode) {
      return _NewItemTile(
        initialItem: widget.item,
        saveLabel: 'Zapisz',
        onSave: (values) {
          ref.read(itemControllerProvider.notifier).update(
                widget.item.copyWith(
                  name: values['name']!,
                  category: values['category']!,
                ),
              );
          setState(() {
            _editMode = false;
          });
        },
      );
    }

    return YaruTile(
      title: Text(widget.item.name),
      subtitle: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          widget.item.category,
          style: const TextStyle(fontSize: 14, color: Colors.indigo),
        ),
      ),
      trailing: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: Colors.indigo.withOpacity(0.03),
            ),
            onPressed: () {
              ref.read(itemControllerProvider.notifier).update(
                    widget.item.copyWith(quantity: widget.item.quantity + 1),
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
            onPressed: () => setState(() {
              _editMode = !_editMode;
            }),
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
    this.initialItem,
  });

  final Item? initialItem;
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
        initialValue: {
          'name': widget.initialItem?.name ?? '',
          'category': widget.initialItem?.category ?? '',
        },
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
