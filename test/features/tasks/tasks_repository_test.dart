import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/api_exception.dart';
import 'package:flutter_application_1/features/dashboard/data/models/dashboard_models.dart';
import 'package:flutter_application_1/features/tasks/data/datasources/tasks_remote_data_source.dart';
import 'package:flutter_application_1/features/tasks/data/models/task_model.dart';
import 'package:flutter_application_1/features/tasks/data/repositories/tasks_repository.dart';

class MockTasksRemoteDataSource implements TasksRemoteDataSource {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Initial Case Filing',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      caseId: 4,
      caseTitle: 'State vs Sharma',
    ),
  ];

  bool shouldThrowError = false;

  @override
  Future<List<Task>> getTasks() async {
    if (shouldThrowError) {
      throw const ApiException(message: 'Network error loading tasks');
    }
    return _tasks;
  }

  @override
  Future<Task> getTask(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Task not found');
    return _tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<Task> createTask(CreateTaskRequest request) async {
    if (shouldThrowError) throw const ApiException(message: 'Validation error');
    final task = Task(
      id: _tasks.length + 1,
      title: request.title,
      description: request.description,
      caseId: request.caseId,
      priority: request.priority,
      status: request.status,
      dueDate: request.dueDate,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(int id, UpdateTaskRequest request) async {
    if (shouldThrowError) throw const ApiException(message: 'Update error');
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw const ApiException(message: 'Not found');
    final updated = _tasks[index].copyWith(
      title: request.title,
      description: request.description,
      status: request.status,
      priority: request.priority,
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Delete error');
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<Task> completeTask(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Complete error');
    final index = _tasks.indexWhere((t) => t.id == id);
    final updated = _tasks[index].copyWith(status: TaskStatus.completed);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<Task> reopenTask(int id) async {
    if (shouldThrowError) throw const ApiException(message: 'Reopen error');
    final index = _tasks.indexWhere((t) => t.id == id);
    final updated = _tasks[index].copyWith(status: TaskStatus.pending);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<TaskComment> addComment(int id, String text) async {
    if (shouldThrowError) throw const ApiException(message: 'Comment error');
    return TaskComment(id: 1, text: text, createdAt: DateTime.now());
  }

  @override
  Future<TaskStats> getTaskStats() async {
    if (shouldThrowError) throw const ApiException(message: 'Stats error');
    return const TaskStats(
      total: 1,
      pending: 1,
      inProgress: 0,
      completed: 0,
      overdue: 0,
    );
  }
}

void main() {
  group('TasksRepository Tests', () {
    late MockTasksRemoteDataSource mockDataSource;
    late TasksRepository repository;

    setUp(() {
      mockDataSource = MockTasksRemoteDataSource();
      repository = TasksRepository(mockDataSource);
    });

    test('getTasks returns task list successfully', () async {
      final tasks = await repository.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Initial Case Filing');
    });

    test('createTask creates and appends task', () async {
      const req = CreateTaskRequest(
        title: 'Draft Bail Application',
        priority: TaskPriority.urgent,
        status: TaskStatus.pending,
      );
      final created = await repository.createTask(req);
      expect(created.id, 2);
      expect(created.title, 'Draft Bail Application');

      final all = await repository.getTasks();
      expect(all.length, 2);
    });

    test('completeTask and reopenTask mutate task status', () async {
      final completed = await repository.completeTask(1);
      expect(completed.status, TaskStatus.completed);

      final reopened = await repository.reopenTask(1);
      expect(reopened.status, TaskStatus.pending);
    });

    test('deleteTask removes task from repository', () async {
      await repository.deleteTask(1);
      final all = await repository.getTasks();
      expect(all.isEmpty, true);
    });

    test('rethrows ApiException on remote error', () async {
      mockDataSource.shouldThrowError = true;
      expect(() => repository.getTasks(), throwsA(isA<ApiException>()));
    });
  });
}
