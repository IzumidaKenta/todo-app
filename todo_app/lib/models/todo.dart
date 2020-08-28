class Todo {
  final int id;
  final String title;
  final bool checked;

  Todo({
    this.id,
    this.title,
    this.checked,
  });

  Todo.fromJson(Map<String, dynamic> json)
    :id = json['id'],
     title = json['title'],
     checked = json['checked'];

  Map<String, dynamic> toJson() => {
    'title' : title,
    'checked': checked,
  };
}

