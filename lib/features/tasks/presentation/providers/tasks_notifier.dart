import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

final taskSearchQueryProvider = StateProvider<String>((ref) => '');
final taskStatusFilterProvider = StateProvider<TaskStatus?>((ref) => null);
final taskPriorityFilterProvider = StateProvider<TaskPriority?>((ref) => null);
final taskCaseFilterProvider = StateProvider<int?>((ref) => null);

final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
      final repository = ref.watch(tasksRepositoryProvider);
      return TasksNotifier(repository);
    });

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(taskStatusFilterProvider);
  final priorityFilter = ref.watch(taskPriorityFilterProvider);
  final caseFilter = ref.watch(taskCaseFilterProvider);

  return tasksAsync.whenData((tasks) {
    return tasks.where((t) {
      if (statusFilter != null && t.status != statusFilter) {
        return false;
      }
      if (priorityFilter != null && t.priority != priorityFilter) {
        return false;
      }
      if (caseFilter != null && t.caseId != caseFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final titleMatches = t.title.toLowerCase().contains(searchQuery);
        final descMatches =
            t.description?.toLowerCase().contains(searchQuery) ?? false;
        final caseMatches =
            t.caseTitle?.toLowerCase().contains(searchQuery) ?? false;
        final assignedMatches =
            t.assignedTo?.fullName.toLowerCase().contains(searchQuery) ?? false;
        return titleMatches || descMatches || caseMatches || assignedMatches;
      }
      return true;
    }).toList();
  });
});

final taskDetailProvider = FutureProvider.family<Task, int>((ref, id) async {
  final repository = ref.watch(tasksRepositoryProvider);
  return repository.getTask(id);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TasksRepository _repository;

  TasksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getTasks());
  }

  Future<Task> createTask(CreateTaskRequest request) async {
    final newTask = await _repository.createTask(request);
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data([newTask, ...state.value!]);
    } else {
      await loadTasks();
    }
    return newTask;
  }

  Future<Task> updateTask(int id, UpdateTaskRequest request) async {
    final updated = await _repository.updateTask(id, request);
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(
        state.value!.map((t) => t.id == id ? updated : t).toList(),
      );
    } else {
      await loadTasks();
    }
    return updated;
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((t) => t.id != id).toList());
    });
  }

  Future<Task> completeTask(int id) async {
    final updated = await _repository.completeTask(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((t) => t.id == id ? updated : t).toList(),
      );
    });
    return updated;
  }

  Future<Task> reopenTask(int id) async {
    final updated = await _repository.reopenTask(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((t) => t.id == id ? updated : t).toList(),
      );
    });
    return updated;
  }

  Future<TaskComment> addComment(int id, String text) async {
    final comment = await _repository.addComment(id, text);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((t) {
          if (t.id == id) {
            return t.copyWith(comments: [...t.comments, comment]);
          }
          return t;
        }).toList(),
      );
    });
    return comment;
  }
}
