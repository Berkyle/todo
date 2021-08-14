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

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the Template type in your schema. */
@immutable
class Template extends Model {
  static const classType = const _TemplateModelType();
  final String id;
  final String? _title;
  final int? _durationMinutes;

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
  
  int? get durationMinutes {
    return _durationMinutes;
  }
  
  const Template._internal({required this.id, required title, durationMinutes}): _title = title, _durationMinutes = durationMinutes;
  
  factory Template({String? id, required String title, int? durationMinutes}) {
    return Template._internal(
      id: id == null ? UUID.getUUID() : id,
      title: title,
      durationMinutes: durationMinutes);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Template &&
      id == other.id &&
      _title == other._title &&
      _durationMinutes == other._durationMinutes;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Template {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("durationMinutes=" + (_durationMinutes != null ? _durationMinutes!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Template copyWith({String? id, String? title, int? durationMinutes}) {
    return Template(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes);
  }
  
  Template.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _durationMinutes = json['durationMinutes'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'durationMinutes': _durationMinutes
  };

  static final QueryField ID = QueryField(fieldName: "template.id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField DURATIONMINUTES = QueryField(fieldName: "durationMinutes");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Template";
    modelSchemaDefinition.pluralName = "Templates";
    
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
      key: Template.TITLE,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Template.DURATIONMINUTES,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
  });
}

class _TemplateModelType extends ModelType<Template> {
  const _TemplateModelType();
  
  @override
  Template fromJson(Map<String, dynamic> jsonData) {
    return Template.fromJson(jsonData);
  }
}