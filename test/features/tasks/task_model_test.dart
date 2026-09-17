import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/tasks/data/models/task_model.dart';

void main() {
  group('Task Model & Enums Tests', () {
    test('TaskPriority parsing and display names', () {
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('medium'), TaskPriority.medium);
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('urgent'), TaskPriority.urgent);
      expect(TaskPriority.fromString('unknown'), TaskPriority.medium);
      expect(TaskPriority.fromString(null), TaskPriority.medium);

      expect(TaskPriority.urgent.displayName, 'Urgent');
    });

    test('TaskStatus parsing and display names', () {
      expect(TaskStatus.fromString('pending'), TaskStatus.pending);
      expect(TaskStatus.fromString('in_progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('in progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('completed'), TaskStatus.completed);
      expect(TaskStatus.fromString('cancelled'), TaskStatus.cancelled);
      expect(TaskStatus.fromString(null), TaskStatus.pending);

      expect(TaskStatus.inProgress.displayName, 'In Progress');
    });

    test('Parses full Task from backend json', () {
      final json = {
        'id': 2,
        'title': 'Draft Response Petition',
        'description': 'Prepare initial draft for civil appeal response.',
        'case': 4,
        'case_title': 'State vs Sharma',
        'assigned_to': {
          'id': 11,
          'username': 'associate_lawyer',
          'email': 'associate@example.com',
          'first_name': 'Rohan',
          'last_name': 'Verma',
        },
        'created_by': {
          'id': 10,
          'username': 'senior_advocate',
          'email': 'senior@example.com',
          'first_name': '',
          'last_name': '',
        },
        'priority': 'high',
        'status': 'pending',
        'due_date': '2026-09-30',
        'completed_at': null,
        'created_at': '2026-09-16T08:12:01.657555Z',
        'updated_at': '2026-09-16T08:12:01.657602Z',
        'comments': [
          {
            'id': 1,
            'author': {
              'id': 10,
              'username': 'senior_advocate',
              'email': 'senior@example.com',
              'first_name': 'A.',
              'last_name': 'K.',
            },
            'text': 'Initial review completed.',
            'created_at': '2026-09-16T08:15:17.587509Z',
          },
        ],
      };

      final task = Task.fromJson(json);

      expect(task.id, 2);
      expect(task.title, 'Draft Response Petition');
      expect(
        task.description,
        'Prepare initial draft for civil appeal response.',
      );
      expect(task.caseId, 4);
      expect(task.caseTitle, 'State vs Sharma');
      expect(task.assignedTo, isNotNull);
      expect(task.assignedTo!.fullName, 'Rohan Verma');
      expect(task.createdBy, isNotNull);
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.pending);
      expect(task.dueDate, '2026-09-30');
      expect(task.isCompleted, false);
      expect(task.comments.length, 1);
      expect(task.comments.first.text, 'Initial review completed.');
      expect(task.comments.first.author?.fullName, 'A. K.');
    });

    test('CreateTaskRequest and UpdateTaskRequest serialization', () {
      const createReq = CreateTaskRequest(
        title: 'Review brief',
        description: 'Detailed analysis',
        caseId: 5,
        assignedToId: 12,
        priority: TaskPriority.urgent,
        status: TaskStatus.pending,
        dueDate: '2026-10-05',
      );

      final cJson = createReq.toJson();
      expect(cJson['title'], 'Review brief');
      expect(cJson['description'], 'Detailed analysis');
      expect(cJson['case'], 5);
      expect(cJson['assigned_to_id'], 12);
      expect(cJson['priority'], 'urgent');
      expect(cJson['due_date'], '2026-10-05');

      const updateReq = UpdateTaskRequest(status: TaskStatus.completed);
      final uJson = updateReq.toJson();
      expect(uJson['status'], 'completed');
      expect(uJson.containsKey('title'), false);
    });
  });
}
