import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/data/models/dashboard_models.dart';
import '../datasources/tasks_remote_data_source.dart';
import '../models/task_model.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final remoteDataSource = ref.watch(tasksRemoteDataSourceProvider);
  return TasksRepository(remoteDataSource);
});

class TasksRepository {
  final TasksRemoteDataSource _remoteDataSource;

  TasksRepository(this._remoteDataSource);

  Future<List<Task>> getTasks() => _remoteDataSource.getTasks();

  Future<Task> getTask(int id) => _remoteDataSource.getTask(id);

  Future<Task> createTask(CreateTaskRequest request) =>
      _remoteDataSource.createTask(request);

  Future<Task> updateTask(int id, UpdateTaskRequest request) =>
      _remoteDataSource.updateTask(id, request);

  Future<void> deleteTask(int id) => _remoteDataSource.deleteTask(id);

  Future<Task> completeTask(int id) => _remoteDataSource.completeTask(id);

  Future<Task> reopenTask(int id) => _remoteDataSource.reopenTask(id);

  Future<TaskComment> addComment(int id, String text) =>
      _remoteDataSource.addComment(id, text);

  Future<TaskStats> getTaskStats() => _remoteDataSource.getTaskStats();
}
