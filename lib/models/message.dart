class Message {
  Message({
    required this.toid,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromid,
    required this.sent,
    this.replyTo,
    this.replyToMessage,
    this.reactions,
  });

  late final String toid;
  late final String msg;
  late final String read;
  late final String fromid;
  late final String sent;
  late final Type type;

  // New fields for reply functionality
  late final String? replyTo;
  late final String? replyToMessage;

  // New field for reactions
  late final Map<String, dynamic>? reactions;

  Message.fromJson(Map<String, dynamic> json) {
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromid = json['fromid'].toString();
    sent = json['sent'].toString();
    replyTo = json['reply_to']?.toString();
    replyToMessage = json['reply_to_message']?.toString();
    reactions = json['reactions'] as Map<String, dynamic>?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toid'] = toid;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromid'] = fromid;
    data['sent'] = sent;
    if (replyTo != null) data['reply_to'] = replyTo;
    if (replyToMessage != null) data['reply_to_message'] = replyToMessage;
    if (reactions != null) data['reactions'] = reactions;
    return data;
  }
}

enum Type { text, image }