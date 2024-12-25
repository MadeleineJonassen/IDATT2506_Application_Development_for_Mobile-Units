import 'package:flutter/material.dart';

import '../model/todo.dart';
import '../constants/color.dart';
import '../widgets/todo_item.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  late var todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _categoryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> categories = [
    'All',
    'Work',
    'Personal',
    'Shopping',
    'Other',
  ];
  String _selectedCategory = 'All';


  @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    _foundToDo.sort((a, b) {
      if (a.isDone && !b.isDone) {
        return -1;
      } else if (!a.isDone && b.isDone) {
        return 1;
      }
      return 0;
    });
    return Scaffold(
      backgroundColor: tdBGColor,

      // ----- TOP BAR -----
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 50
            ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _showAddCategoryDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tdGreen,
                ),
                icon: const Icon(
                  Icons.add,
                  color: tdBlack,
                  size: 20,
                ),
                label: const Text(
                  'Category',
                  style: TextStyle(
                    color: tdBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              FilledButton
                  .icon(
                onPressed: _showEditDeleteCategoryDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tdBrown,
                ),
                icon: const Icon(
                  Icons.edit,
                  color: tdBlack,
                  size: 20,
                ),
                label: const Text(
                  'Category',
                  style: TextStyle(
                    color: tdBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),

          // ----- CATEGORY FIELD -----
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                    _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_left),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = categories[index];
                            _runFilterByCategory(_selectedCategory);
                          });
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: _selectedCategory == categories[index]
                                ? tdBrown
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: _selectedCategory == categories[index]
                                  ? tdBlack
                                  : tdGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                IconButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_right),
                ),
              ]),
          ),

          // ----- TASK SECTION -----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 30,
                        bottom: 20,
                      ),
                      child: const Text(
                        'My To-Dos',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    for (ToDo todoo in _foundToDo.reversed)
                      ToDoItem(
                        todo: todoo,
                        onToDoChanged: _handleToDoChange,
                        onDeleteItem: _deleteToDoItem,
                      ),
                  ],
                ),
              ),
            ),

          ],
      ),
          ),

          // ----- ADD TASK -----
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child:
              FilledButton(
                onPressed: _showAddToDoDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tdGreenTrans,
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    color: tdBlack,
                    fontSize: 46,
                  ),
                ),
              ),
            ),
          )],

      ),
    );
  }

  void _runFilterByCategory(String category) {
    setState(() {
      if (category == null || category == 'All') {
        _foundToDo = todosList;
      } else {
        _foundToDo =
            todosList.where((todo) => todo.category == category).toList();
      }
    });
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      int index = todosList.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        todosList[index] = ToDo(
          id: todo.id,
          todoText: todo.todoText,
          isDone: !todo.isDone,
          category: todo.category,
        );
        _runFilterByCategory(_selectedCategory);
      }
    });
  }

  void _showAddToDoDialog() {
    String? selectedCategory;
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New To-Do'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Name the task...',
                    ),
                    onSubmitted: (String value) {
                      if (value.trim().isNotEmpty && selectedCategory != null) {
                        _addToDoItemWithCategory(
                          value.trim(),
                          selectedCategory!,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .where((cat) => cat != 'All')
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty &&
                        selectedCategory != null) {
                      _addToDoItemWithCategory(
                        nameController.text.trim(),
                        selectedCategory!,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: tdGreenDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: tdGrey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _addToDoItemWithCategory(String toDoName, String category) {
    setState(() {
      todosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDoName,
        category: category,
      ));
      _runFilterByCategory(_selectedCategory);
    });
  }
  void _deleteToDoItem(String id) {
    ToDo? todoToDelete = todosList.firstWhere((item) => item.id == id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete To-Do'),
          content: Text(
              'Are you sure you want to delete the to-do item "${todoToDelete
                  .todoText}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todosList =
                      todosList.where((item) => item.id != id).toList();
                  _runFilterByCategory(_selectedCategory);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              hintText: 'Enter category name',
            ),
            onSubmitted: (String value) {
              String newCategory = value.trim();
              if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                setState(() {
                  categories.add(newCategory);
                });
                _categoryController.clear();
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newCategory = _categoryController.text.trim();
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  setState(() {
                    categories.add(newCategory);
                  });
                  _categoryController.clear();
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: tdGreenDark,
                  fontWeight: FontWeight.bold,
                ),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: tdGrey),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showEditDeleteCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory;
        final editController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: const Text('Select category'),
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories
                        .where((cat) => cat != 'All')
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedCategory = newValue;
                        editController.text = newValue ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: editController,
                    decoration: const InputDecoration(
                      hintText: 'Edit category name...',
                    ),
                    onSubmitted: (String value) {
                      if (value.trim().isNotEmpty &&
                          !categories.contains(value.trim())) {
                        setState(() {
                          int index = categories.indexOf(selectedCategory!);
                          categories[index] = value.trim();
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                if (selectedCategory != null) ...[
                  TextButton(
                    onPressed: () {
                      if (editController.text.trim().isNotEmpty &&
                          !categories.contains(editController.text.trim())) {
                        setState(() {
                          int index = categories.indexOf(selectedCategory!);
                          categories[index] = editController.text.trim();
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: tdGreenDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showDeleteCategoryConfirmationDialog(selectedCategory!);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: tdGrey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showDeleteCategoryConfirmationDialog(String categoryToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete the category "$categoryToDelete"?\n'
                  'This will also remove all associated tasks.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: tdGrey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  categories.remove(categoryToDelete);
                  todosList =
                      todosList.where((todo) => todo.category != categoryToDelete).toList();
                  if (_selectedCategory == categoryToDelete) {
                    _selectedCategory = 'All';
                    _runFilterByCategory(_selectedCategory);
                  }
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }



}
