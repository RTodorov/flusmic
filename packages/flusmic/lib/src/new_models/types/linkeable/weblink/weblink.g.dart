// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weblink.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weblink _$WeblinkFromJson(Map<String, dynamic> json) {
  return Weblink(
    json['link_type'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$WeblinkToJson(Weblink instance) => <String, dynamic>{
      'link_type': instance.linkType,
      'url': instance.url,
    };
