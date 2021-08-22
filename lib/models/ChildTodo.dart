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
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the ChildTodo type in your schema. */
@immutable
class ChildTodo extends Model {
  static const classType = const _ChildTodoModelType();
  final String id;
  final String? _title;
  final bool? _isComplete;
  final Todo? _parent;
  final String? _order;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  bool get isComplete {
    try {
      return _isComplete!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  Todo? get parent {
    return _parent;
  }
  
  String get order {
    try {
      return _order!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  const ChildTodo._internal({required this.id, required title, required isComplete, parent, required order}): _title = title, _isComplete = isComplete, _parent = parent, _order = order;
  
  factory ChildTodo({String? id, required String title, required bool isComplete, Todo? parent, required String order}) {
    return ChildTodo._internal(
      id: id == null ? UUID.getUUID() : id,
      title: title,
      isComplete: isComplete,
      parent: parent,
      order: order);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChildTodo &&
      id == other.id &&
      _title == other._title &&
      _isComplete == other._isComplete &&
      _parent == other._parent &&
      _order == other._order;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ChildTodo {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("isComplete=" + (_isComplete != null ? _isComplete!.toString() : "null") + ", ");
    buffer.write("parent=" + (_parent != null ? _parent!.toString() : "null") + ", ");
    buffer.write("order=" + "$_order");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ChildTodo copyWith({String? id, String? title, bool? isComplete, Todo? parent, String? order}) {
    return ChildTodo(
      id: id ?? this.id,
      title: title ?? this.title,
      isComplete: isComplete ?? this.isComplete,
      parent: parent ?? this.parent,
      order: order ?? this.order);
  }
  
  ChildTodo.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _isComplete = json['isComplete'],
      _parent = json['parent']?['serializedData'] != null
        ? Todo.fromJson(new Map<String, dynamic>.from(json['parent']['serializedData']))
        : null,
      _order = json['order'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'isComplete': _isComplete, 'parent': _parent?.toJson(), 'order': _order
  };

  static final QueryField ID = QueryField(fieldName: "childTodo.id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField ISCOMPLETE = QueryField(fieldName: "isComplete");
  static final QueryField PARENT = QueryField(
    fieldName: "parent",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Todo).toString()));
  static final QueryField ORDER = QueryField(fieldName: "order");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ChildTodo";
    modelSchemaDefinition.pluralName = "ChildTodos";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PUBLIC,
        operations: [
          ModelOperation.CREATE,
          ModelOperation.UPDATE,
          ModelOperation.DELETE,
          ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: ChildTodo.TITLE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: ChildTodo.ISCOMPLETE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.belongsTo(
      key: ChildTodo.PARENT,
      isRequired: false,
      targetName: "childTodoParentId",
      ofModelName: (Todo).toString()
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: ChildTodo.ORDER,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _ChildTodoModelType extends ModelType<ChildTodo> {
  const _ChildTodoModelType();
  
  @override
  ChildTodo fromJson(Map<String, dynamic> jsonData) {
    return ChildTodo.fromJson(jsonData);
  }
}