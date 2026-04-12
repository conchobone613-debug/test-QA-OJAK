import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType { text, image, system }

@freezed
class Message with _$Message {
  const factory Message({
    required String messageId,
    required String chatRoomId,
    required String senderId,
    @Default('') String text,
    String? imageUrl,
    @Default(MessageType.text) MessageType type,
    @JsonKey(fromJson: _timestampToDateTimeNullable, toJson: _dateTimeToTimestampNullable)
    DateTime? readAt,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @Default(false) bool isDeleted,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

DateTime _timestampToDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

dynamic _dateTimeToTimestamp(DateTime dt) => Timestamp.fromDate(dt);

DateTime? _timestampToDateTimeNullable(dynamic value) {
  if (value == null) return null;
  return _timestampToDateTime(value);
}

dynamic _dateTimeToTimestampNullable(DateTime? dt) {
  if (dt == null) return null;
  return Timestamp.fromDate(dt);
}