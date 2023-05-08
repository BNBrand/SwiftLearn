
class NoteModel  {

  final String title;

  NoteModel({
    required this.title,
  });
  factory NoteModel.fromJson(Map<String, dynamic> json){
    return NoteModel(
        title: json['title']
    );
  }

  Map<String, dynamic> toJson(){
    return {
    'title': title
    };
  }
}