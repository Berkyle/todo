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


/** This is an auto generated class representing the Todo type in your schema. */
@immutable
class Todo extends Model {
  static const classType = const _TodoModelType();
  final String id;
  final String? _title;
  final bool? _isComplete;
  final Template? _template;
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
  
  Template? get template {
    return _template;
  }
  
  String get order {
    try {
      return _order!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  const Todo._internal({required this.id, required title, required isComplete, template, required order}): _title = title, _isComplete = isComplete, _template = template, _order = order;
  
  factory Todo({String? id, required String title, required bool isComplete, Template? template, required String order}) {
    return Todo._internal(
      id: id == null ? UUID.getUUID() : id,
      title: title,
      isComplete: isComplete,
      template: template,
      order: order);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Todo &&
      id == other.id &&
      _title == other._title &&
      _isComplete == other._isComplete &&
      _template == other._template &&
      _order == other._order;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Todo {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("isComplete=" + (_isComplete != null ? _isComplete!.toString() : "null") + ", ");
    buffer.write("template=" + (_template != null ? _template!.toString() : "null") + ", ");
    buffer.write("order=" + "$_order");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Todo copyWith({String? id, String? title, bool? isComplete, Template? template, String? order}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isComplete: isComplete ?? this.isComplete,
      template: template ?? this.template,
      order: order ?? this.order);
  }
  
  Todo.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _isComplete = json['isComplete'],
      _template = json['template']?['serializedData'] != null
        ? Template.fromJson(new Map<String, dynamic>.from(json['template']['serializedData']))
        : null,
      _order = json['order'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'isComplete': _isComplete, 'template': _template?.toJson(), 'order': _order
  };

  static final QueryField ID = QueryField(fieldName: "todo.id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField ISCOMPLETE = QueryField(fieldName: "isComplete");
  static final QueryField TEMPLATE = QueryField(
    fieldName: "template",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Template).toString()));
  static final QueryField ORDER = QueryField(fieldName: "order");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Todo";
    modelSchemaDefinition.pluralName = "Todos";
    
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
      key: Todo.TITLE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Todo.ISCOMPLETE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.belongsTo(
      key: Todo.TEMPLATE,
      isRequired: false,
      targetName: "todoTemplateId",
      ofModelName: (Template).toString()
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Todo.ORDER,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _TodoModelType extends ModelType<Todo> {
  const _TodoModelType();
  
  @override
  Todo fromJson(Map<String, dynamic> jsonData) {
    return Todo.fromJson(jsonData);
  }
}