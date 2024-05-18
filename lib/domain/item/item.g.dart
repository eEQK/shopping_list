// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      categoryAccent: (json['categoryAccent'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      purchased: json['purchased'] as bool? ?? false,
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'categoryAccent': instance.categoryAccent,
      'quantity': instance.quantity,
      'purchased': instance.purchased,
    };
