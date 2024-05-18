import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shopping_list/domain/item/item.dart';
import 'package:shopping_list/domain/item/item_controller.dart';
import 'package:shopping_list/ui/widgets/constants.dart';

class EditScreen extends ConsumerStatefulWidget {
  static const route = '/edit';

  const EditScreen({super.key});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Item;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj przedmiot'),
      ),
      body: FormBuilder(
        key: _formKey,
        initialValue: {
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
        },
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'name',
                  validator: FormBuilderValidators.required(),
                  decoration: const InputDecoration(
                    labelText: 'Nazwa',
                    fillColor: Colors.white,
                  ),
                ),
                kVerticalSpace12,
                FormBuilderTextField(
                  name: 'category',
                  validator: FormBuilderValidators.required(),
                  decoration: const InputDecoration(
                    labelText: 'Kategoria',
                    fillColor: Colors.white,
                  ),
                ),
                kVerticalSpace12,
                FormBuilderSlider(
                  name: 'quantity',
                  divisions: 9,
                  initialValue: item.quantity.toDouble(),
                  min: 1,
                  max: 10,
                  decoration: const InputDecoration(
                    labelText: 'Ilość',
                    fillColor: Colors.white,
                  ),
                ),
                kVerticalSpace24,
                ElevatedButton(
                  onPressed: () => _onSave(item),
                  child: const Text('Zapisz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave(Item item) {
    if (_formKey.currentState!.saveAndValidate()) {
      ref.read(itemControllerProvider.notifier).update(
            item.copyWith(
              name: _formKey.currentState!.value['name'] as String,
              category: _formKey.currentState!.value['category'] as String,
              quantity:
                  (_formKey.currentState!.value['quantity'] as num).toInt(),
            ),
          );
      Navigator.of(context).pop();
    }
  }
}
