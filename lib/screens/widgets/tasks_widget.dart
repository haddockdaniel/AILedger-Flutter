import 'package:flutter/material.dart';
import 'package:autoledger/models/task_model.dart';
import 'package:autoledger/services/task_service.dart';
import 'package:autoledger/services/contact_service.dart';
import 'package:autoledger/models/contact_model.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:autoledger/utils/voice_events.dart';
import 'package:autoledger/services/scheduler_service.dart';
import 'package:autoledger/widgets/search_bar.dart';
import 'package:autoledger/widgets/confirmation_dialog.dart';
import 'package:autoledger/screens/widgets/task_form_screen.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';  // ← new

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  List<Task> _tasks = [];
  List<Task> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    VoiceEventBus().on<VoiceIntentEvent>().listen(_handleVoiceIntent);
    VoiceEventBus().on<VoiceEvent>().listen(_handleVoiceEvent);
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    _tasks = await TaskService.getTasks();
    _applySearch(_searchController.text);
	_scheduleReminders();
    setState(() => _loading = false);
  }

  void _applySearch(String q) {
    final term = q.toLowerCase();
    _filtered = _tasks.where((t) {
      return t.description.toLowerCase().contains(term) ||
             t.priority.toLowerCase().contains(term);
    }).toList();
    setState(() {});
  }

  void _scheduleReminders() {
    for (final t in _tasks) {
      if (t.autoReminders && !t.isCompleted) {
        SchedulerService.scheduleTaskReminder(
          t,
          t.dueDate,
          () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task due: ${t.description}')),
              );
            }
          },
        );
      }
    }
  }

  Future<void> _openForm([Task? edit]) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(editTask: edit)),
    );
    if (result != null) {
      await _loadTasks();
    }
  }

  Future<void> _deleteTask(Task t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Delete Task',
        content: 'Delete task "${t.description}"?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed == true) {
      await TaskService.deleteTask(t.taskId);
      SchedulerService.cancelTask(t.taskId);
      await _loadTasks();
    }
  }

  Future<void> _handleVoiceIntent(VoiceIntentEvent evt) async {
    switch (evt.intent) {
      case 'add_task':
        _openForm();
        break;
      case 'edit_task':
        final id = evt.slots?['taskId'];
        if (id != null) {
          final match = _tasks.where((t) => t.taskId == id);
          if (match.isNotEmpty) {
            _openForm(match.first);
          }
        }
        break;
      case 'delete_task':
        final id = evt.slots?['taskId'];
        if (id != null) {
          final match = _tasks.where((t) => t.taskId == id);
          if (match.isNotEmpty) _deleteTask(match.first);
        }
        break;
      case 'search_tasks':
        final q = evt.slots?['query'] ?? '';
        _searchController.text = q;
        _applySearch(q);
        break;
      case 'complete_task':
        final id = evt.slots?['taskId'];
        if (id != null) {
          await TaskService.markTaskComplete(id);
		            SchedulerService.cancelTask(id);
          await _loadTasks();
        }
        break;
      case 'schedule_task':
        final desc = evt.slots?['description'];
        final dateStr = evt.slots?['date'];
        final timeStr = evt.slots?['time'];
        if (desc != null && dateStr != null && timeStr != null) {
          final due = DateTime.parse('$dateStr $timeStr');
          final task = Task(
            taskId: '',
            userId: '',
            description: desc,
            entryDate: DateTime.now(),
            dueDate: due,
            isCompleted: false,
            priority: 'Medium',
            customerId: null,
            autoReminders: true,
          );
          final created = await TaskService.createTask(task);
          await SchedulerService.scheduleTaskReminder(created, due, () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task due: ${created.description}')),
              );
            }
          });
          await _loadTasks();
        }
        break;
    }
  }
  
    Future<void> _handleVoiceEvent(VoiceEvent evt) async {
    if (evt.type != 'action') return;
    switch (evt.payload) {
      case 'task.complete':
        final id = evt.data['taskId'];
        if (id != null) {
          await TaskService.markTaskComplete(id.toString());
          SchedulerService.cancelTask(id.toString());
          _loadTasks();
        }
        break;
      case 'task.delete':
        final id = evt.data['taskId'];
        if (id != null) {
          final index = _tasks.indexWhere((t) => t.taskId == id);
          if (index != -1) _deleteTask(_tasks[index]);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          controller: _searchController,
          hintText: 'Search tasks...',
          onChanged: _applySearch,
        ),
        Expanded(
          child: _loading
              ? const SkeletonLoader()  // ← replaced spinner
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: _filtered.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No tasks found')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final t = _filtered[i];
                            return ListTile(
                              title: Text(t.description),
                              subtitle: Text(
							'Due: ${t.dueDate.toLocal().toShortDateString()} • ${t.priority}'
                              ),
                              leading: Checkbox(
								value: t.isCompleted,
                                onChanged: (val) async {
                                  final updated = Task(
                                    taskId: t.taskId,
                                    userId: t.userId,
                                    description: t.description,
                                    entryDate: t.entryDate,
                                    dueDate: t.dueDate,
                                    isCompleted: val ?? false,
                                    priority: t.priority,
                                    customerId: t.customerId,
                                    autoReminders: t.autoReminders,
                                    calendarEventId: t.calendarEventId,
                                  );
                                  await TaskService.updateTask(updated);
								    if (val == true) {
                                    SchedulerService.cancelTask(t.taskId);
                                  }
                                  _loadTasks();
                                },
                              ),
                              onTap: () => _openForm(t),
                              onLongPress: () => _deleteTask(t),
                            );
                          },
                        ),
                ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'addTask',
          tooltip: 'Add Task',
          child: const Icon(Icons.add),
          onPressed: () => _openForm(),
        ),
      ],
    );
  }
}

extension DateHelpers on DateTime {
  String toShortDateString() => '${month}/${day}/${year}';
}
