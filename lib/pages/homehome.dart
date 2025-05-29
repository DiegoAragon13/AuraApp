import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeHome extends StatefulWidget {
  const HomeHome({Key? key}) : super(key: key);

  @override
  State<HomeHome> createState() => _HomeHomeState();
}

class _HomeHomeState extends State<HomeHome> {
  final DateTime currentDate = DateTime.now();
  late DateTime selectedDate;
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    fetchTasks();
  }

  // Método para obtener tareas de Firestore para la fecha seleccionada
  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Formato de fecha para Firestore (YYYY-MM-DD)
      String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: 'current_user_id') // Reemplaza con la autenticación real
          .where('date', isEqualTo: dateKey)
          .get();

      setState(() {
        tasks = snapshot.docs
            .map((doc) => Task(
          id: doc.id,
          title: doc['title'],
          isCompleted: doc['isCompleted'] ?? false,
        ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar tareas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para actualizar el estado de una tarea
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });

      // Actualiza el estado local
      setState(() {
        final index = tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          tasks[index] = Task(
            id: tasks[index].id,
            title: tasks[index].title,
            isCompleted: isCompleted,
          );
        }
      });
    } catch (e) {
      print('Error al actualizar tarea: $e');
    }
  }

  // Método para añadir una nueva tarea
  Future<void> addTask(String title) async {
    try {
      // Formato de fecha para Firestore
      String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Añadir tarea a Firestore
      DocumentReference docRef = await FirebaseFirestore.instance.collection('tasks').add({
        'userId': 'current_user_id', // Reemplaza con la autenticación real
        'title': title,
        'isCompleted': false,
        'date': dateKey,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Actualiza el estado local
      setState(() {
        tasks.add(Task(
          id: docRef.id,
          title: title,
          isCompleted: false,
        ));
      });
    } catch (e) {
      print('Error al añadir tarea: $e');
    }
  }

  // Método para eliminar una tarea
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      // Actualiza el estado local
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      print('Error al eliminar tarea: $e');
    }
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva tarea para ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(
            hintText: 'Introduce el nombre de la tarea',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.trim().isNotEmpty) {
                addTask(taskController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF483D8B),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E9), // Color lavanda claro
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF483D8B),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la aplicación
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Aura Mind',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363062),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienestar diario',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Widget del calendario
              CalendarWidget(
                currentDate: currentDate,
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  fetchTasks();
                },
              ),
              const SizedBox(height: 24),

              // Widget de tareas diarias
              Expanded(
                child: DailyTasksWidget(
                  tasks: tasks,
                  isLoading: isLoading,
                  selectedDate: selectedDate,
                  onTaskStatusChanged: (taskId, value) {
                    updateTaskStatus(taskId, value);
                  },
                  onTaskDeleted: (taskId) {
                    deleteTask(taskId);
                  },
                  onAddTask: _showAddTaskDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelo para la tarea
class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}

class CalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    Key? key,
    required this.currentDate,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1).weekday;
    final today = DateTime.now().day;

    // Ajuste para que la semana comience el lunes (1) y termine el domingo (7)
    final adjustedFirstDay = firstDayOfMonth == 7 ? 0 : firstDayOfMonth;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del calendario
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF363062),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Mayo ${currentYear}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF363062),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Lun', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Mar', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Mié', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Jue', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Vie', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Sáb', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Dom', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),

          // Grid de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: adjustedFirstDay + daysInMonth,
            itemBuilder: (context, index) {
              if (index < adjustedFirstDay) {
                return Container(); // Espacios en blanco para los días anteriores al inicio del mes
              }

              final day = index - adjustedFirstDay + 1;

              // Verificar si este día es el seleccionado
              final isSelected = selectedDate.day == day &&
                  selectedDate.month == currentDate.month &&
                  selectedDate.year == currentDate.year;

              // Verificar si es hoy
              final isToday = today == day;

              return InkWell(
                onTap: () {
                  final selectedDateTime = DateTime(currentYear, currentMonth, day);
                  onDateSelected(selectedDateTime);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF483D8B)
                        : isToday
                        ? const Color(0xFFD4C1EC)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DailyTasksWidget extends StatelessWidget {
  final List<Task> tasks;
  final bool isLoading;
  final DateTime selectedDate;
  final Function(String, bool) onTaskStatusChanged;
  final Function(String) onTaskDeleted;
  final VoidCallback onAddTask;

  const DailyTasksWidget({
    Key? key,
    required this.tasks,
    required this.isLoading,
    required this.selectedDate,
    required this.onTaskStatusChanged,
    required this.onTaskDeleted,
    required this.onAddTask,
  }) : super(key: key);

  int getCompletedTasksCount() {
    return tasks.where((task) => task.isCompleted).length;
  }

  double getCompletionPercentage() {
    return tasks.isEmpty
        ? 0
        : getCompletedTasksCount() / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage = getCompletionPercentage() * 100;
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contenedor de título con Flexible
              Flexible(
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF363062),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tareas diarias',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF363062),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Espacio entre los elementos
              const SizedBox(width: 8),
              // Texto de porcentaje con FittedBox
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${completionPercentage.toInt()}% completado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de tareas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 56,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay tareas para este día',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Añadir tarea'),
                        onPressed: onAddTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF483D8B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    onTaskDeleted(task.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            value: task.isCompleted,
                            activeColor: const Color(0xFF483D8B),
                            onChanged: (bool? value) {
                              if (value != null) {
                                onTaskStatusChanged(task.id, value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}