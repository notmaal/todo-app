import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.editFunction,
    this.onAddDateTime,
    this.dateTime,
  });

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final VoidCallback? editFunction;
  final VoidCallback? onAddDateTime;
  final DateTime? dateTime;


  @override
  Widget build(BuildContext context) {
    final formattedDate = dateTime != null
        ? DateFormat('yyyy-MM-dd – HH:mm').format(dateTime!)
        : "No Date & Time Set";
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 0,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                checkColor: Colors.yellow,
                activeColor: Colors.black,
                side: const BorderSide(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: taskCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.black,
                        decorationThickness: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.black,
                  onPressed: editFunction,
                ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                color: Colors.black,
                onPressed: onAddDateTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
