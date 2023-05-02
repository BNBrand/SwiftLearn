
class CommentModel  {

  String? postId;
  String? displayName;
  String? photoURL;
  String? createdAt;
  String? comment;

  CommentModel({
    required this.postId,
    required this.photoURL,
    required this.displayName,
    required this.comment,
    required this.createdAt
  });
    CommentModel.fromJson(Map<String, dynamic> json){
      postId = json['postId'];
      displayName = json['displayName'];
      photoURL = json['photoURL'];
      comment = json['comment'];
      createdAt = json['createdAt'];
    }

    Map<String, dynamic> toJson(){
      final Map<String, dynamic> data = Map<String, dynamic>();
      data['postId'] = postId;
      data['displayName'] = displayName;
      data['photoURL'] = photoURL;
      data['comment'] = comment;
      data['createdAt'] = createdAt;

      return data;
    }
  }