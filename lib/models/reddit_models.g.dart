// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reddit_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RedditProfileAdapter extends TypeAdapter<RedditProfile> {
  @override
  final int typeId = 0;

  @override
  RedditProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RedditProfile(
      username: fields[0] as String,
      totalKarma: fields[1] as int,
      accountAge: fields[2] as String,
      status: fields[3] as String,
      toxicity: fields[4] as double,
      nsfw: fields[5] as double,
      controversialIndex: fields[6] as double,
      recentPosts: (fields[7] as List).cast<RedditPost>(),
      recentComments: (fields[8] as List).cast<RedditComment>(),
      afterToken: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RedditProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.totalKarma)
      ..writeByte(2)
      ..write(obj.accountAge)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.toxicity)
      ..writeByte(5)
      ..write(obj.nsfw)
      ..writeByte(6)
      ..write(obj.controversialIndex)
      ..writeByte(7)
      ..write(obj.recentPosts)
      ..writeByte(8)
      ..write(obj.recentComments)
      ..writeByte(9)
      ..write(obj.afterToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RedditPostAdapter extends TypeAdapter<RedditPost> {
  @override
  final int typeId = 1;

  @override
  RedditPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RedditPost(
      id: fields[0] as String,
      subreddit: fields[1] as String,
      title: fields[2] as String,
      url: fields[3] as String?,
      permalink: fields[4] as String?,
      ups: fields[5] as int,
      numComments: fields[6] as int,
      time: fields[7] as String,
      rawTimestamp: fields[8] as int,
      isNsfw: fields[9] as bool,
      source: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RedditPost obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subreddit)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.permalink)
      ..writeByte(5)
      ..write(obj.ups)
      ..writeByte(6)
      ..write(obj.numComments)
      ..writeByte(7)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.rawTimestamp)
      ..writeByte(9)
      ..write(obj.isNsfw)
      ..writeByte(10)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RedditCommentAdapter extends TypeAdapter<RedditComment> {
  @override
  final int typeId = 2;

  @override
  RedditComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RedditComment(
      id: fields[0] as String,
      subreddit: fields[1] as String,
      body: fields[2] as String,
      linkTitle: fields[3] as String?,
      permalink: fields[4] as String?,
      ups: fields[5] as int,
      rawTimestamp: fields[6] as int,
      time: fields[7] as String,
      isControversial: fields[8] as bool,
      isNsfw: fields[9] as bool,
      source: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RedditComment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subreddit)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.linkTitle)
      ..writeByte(4)
      ..write(obj.permalink)
      ..writeByte(5)
      ..write(obj.ups)
      ..writeByte(6)
      ..write(obj.rawTimestamp)
      ..writeByte(7)
      ..write(obj.time)
      ..writeByte(8)
      ..write(obj.isControversial)
      ..writeByte(9)
      ..write(obj.isNsfw)
      ..writeByte(10)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
