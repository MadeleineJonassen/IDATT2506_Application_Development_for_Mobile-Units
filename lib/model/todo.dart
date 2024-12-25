class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  String category;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.category = 'Other',
  });

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Morning Exercise', isDone: true, category: 'Personal'),
      ToDo(id: '02', todoText: 'Check Emails', isDone: true, category: 'Work'),
      ToDo(id: '03', todoText: 'Buy Milk', category: 'Shopping'),
      ToDo(id: '04', todoText: 'Team Meeting', category: 'Work'),
      ToDo(id: '05', todoText: 'Work on mobile apps for 2 hours', category: 'Work'),
      ToDo(id: '06', todoText: 'Dinner with Holt', category: 'Personal'),
    ];
  }
}
