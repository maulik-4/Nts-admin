import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../dashboard/data/models/dashboard_models.dart';
import '../models/task_model.dart';

final tasksRemoteDataSourceProvider = Provider<TasksRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TasksRemoteDataSource(dio);
});

class TasksRemoteDataSource {
  final Dio _dio;

  TasksRemoteDataSource(this._dio);

  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get(ApiEndpoints.tasks);
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['results'] is List) {
        return (data['results'] as List)
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Task> getTask(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.tasks}$id/');
      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid task response format.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Task> createTask(CreateTaskRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.tasks,
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from task creation.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Task> updateTask(int id, UpdateTaskRequest request) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.tasks}$id/',
        data: request.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from task update.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.tasks}$id/');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Task> completeTask(int id) async {
    try {
      final response = await _dio.post('${ApiEndpoints.tasks}$id/complete/');
      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from task completion.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<Task> reopenTask(int id) async {
    try {
      final response = await _dio.post('${ApiEndpoints.tasks}$id/reopen/');
      if (response.data is Map<String, dynamic>) {
        return Task.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response from task reopen.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<TaskComment> addComment(int id, String text) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.tasks}$id/add_comment/',
        data: {'text': text},
      );
      if (response.data is Map<String, dynamic>) {
        return TaskComment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(
        message: 'Invalid response from adding comment.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }

  Future<TaskStats> getTaskStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.taskStats);
      if (response.data is Map<String, dynamic>) {
        return TaskStats.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Invalid response for task stats.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.fromResponse(e.response?.statusCode, e.response?.data);
    }
  }
}
