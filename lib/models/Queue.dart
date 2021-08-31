/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// ignore_for_file: public_member_api_docs

import 'ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the Queue type in your schema. */
@immutable
class Queue extends Model {
  static const classType = const _QueueModelType();
  final String id;
  final String? _title;
  final bool? _favorited;
  final String? _order;
  final bool? _isOrdered;
  final List<Todo>? _todos;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  String get title {
    try {
      return _title!;
    } catch (e) {
      throw new DataStoreException(
          DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
              DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  bool get favorited {
    try {
      return _favorited!;
    } catch (e) {
      throw new DataStoreException(
          DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
              DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  String get order {
    try {
      return _order!;
    } catch (e) {
      throw new DataStoreException(
          DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
              DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  bool get isOrdered {
    try {
      return _isOrdered!;
    } catch (e) {
      throw new DataStoreException(
          DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
              DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  List<Todo> get todos {
    try {
      return _todos!;
    } catch (e) {
      throw new DataStoreException(
          DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
              DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString());
    }
  }

  const Queue._internal(
      {required this.id,
      required title,
      required favorited,
      required order,
      required isOrdered,
      required todos})
      : _title = title,
        _favorited = favorited,
        _order = order,
        _isOrdered = isOrdered,
        _todos = todos;

  factory Queue(
      {String? id,
      required String title,
      required bool favorited,
      required String order,
      required bool isOrdered,
      required List<Todo> todos}) {
    return Queue._internal(
        id: id == null ? UUID.getUUID() : id,
        title: title,
        favorited: favorited,
        order: order,
        isOrdered: isOrdered,
        todos: todos != null ? List<Todo>.unmodifiable(todos) : todos);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Queue &&
        id == other.id &&
        _title == other._title &&
        _favorited == other._favorited &&
        _order == other._order &&
        _isOrdered == other._isOrdered &&
        DeepCollectionEquality().equals(_todos, other._todos);
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Queue {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("favorited=" + (_favorited != null ? _favorited!.toString() : "null") + ", ");
    buffer.write("order=" + "$_order" + ", ");
    buffer.write("isOrdered=" + (_isOrdered != null ? _isOrdered!.toString() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  Queue copyWith(
      {String? id,
      String? title,
      bool? favorited,
      String? order,
      bool? isOrdered,
      List<Todo>? todos}) {
    return Queue(
        id: id ?? this.id,
        title: title ?? this.title,
        favorited: favorited ?? this.favorited,
        order: order ?? this.order,
        isOrdered: isOrdered ?? this.isOrdered,
        todos: todos ?? this.todos);
  }

  Queue.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _title = json['title'],
        _favorited = json['favorited'],
        _order = json['order'],
        _isOrdered = json['isOrdered'],
        _todos = json['todos'] is List
            ? (json['todos'] as List)
                .where((e) => e?['serializedData'] != null)
                .map((e) => Todo.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
                .toList()
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': _title,
        'favorited': _favorited,
        'order': _order,
        'isOrdered': _isOrdered,
        'todos': _todos?.map((e) => e.toJson()).toList()
      };

  static final QueryField ID = QueryField(fieldName: "queue.id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField FAVORITED = QueryField(fieldName: "favorited");
  static final QueryField ORDER = QueryField(fieldName: "order");
  static final QueryField ISORDERED = QueryField(fieldName: "isOrdered");
  static final QueryField TODOS = QueryField(
      fieldName: "todos",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Todo).toString()));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Queue";
    modelSchemaDefinition.pluralName = "Queues";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Queue.TITLE, isRequired: true, ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Queue.FAVORITED, isRequired: true, ofType: ModelFieldType(ModelFieldTypeEnum.bool)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Queue.ORDER, isRequired: true, ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: Queue.ISORDERED, isRequired: true, ofType: ModelFieldType(ModelFieldTypeEnum.bool)));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
        key: Queue.TODOS,
        isRequired: false,
        ofModelName: (Todo).toString(),
        associatedKey: Todo.QUEUEID));
  });
}

class _QueueModelType extends ModelType<Queue> {
  const _QueueModelType();

  @override
  Queue fromJson(Map<String, dynamic> jsonData) {
    return Queue.fromJson(jsonData);
  }
}
