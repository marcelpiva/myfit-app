import 'package:flutter_test/flutter_test.dart';
import 'package:myfit_app/features/trainer_workout/presentation/providers/trainer_students_provider.dart';

import '../../helpers/fixtures/student_fixtures.dart';

void main() {
  group('TrainerStudent', () {
    test('should create with required fields', () {
      const student = TrainerStudent(
        id: 'student-1',
        name: 'João Silva',
      );

      expect(student.id, 'student-1');
      expect(student.name, 'João Silva');
    });

    test('should have correct default values', () {
      const student = TrainerStudent(
        id: 'student-1',
        name: 'João Silva',
      );

      expect(student.isActive, true);
      expect(student.totalWorkouts, 0);
      expect(student.completedWorkouts, 0);
      expect(student.adherencePercent, 0);
      expect(student.email, isNull);
      expect(student.avatarUrl, isNull);
      expect(student.phone, isNull);
      expect(student.joinedAt, isNull);
      expect(student.lastWorkoutAt, isNull);
      expect(student.currentWorkoutName, isNull);
      expect(student.goal, isNull);
      expect(student.stats, isNull);
    });

    group('isNew', () {
      test('should return true when joined within 30 days', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          joinedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        expect(student.isNew, true);
      });

      test('should return true when joined exactly 30 days ago', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(student.isNew, true);
      });

      test('should return false when joined more than 30 days ago', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          joinedAt: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(student.isNew, false);
      });

      test('should return false when joinedAt is null', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
        );
        expect(student.isNew, false);
      });
    });

    group('lastActivity', () {
      test('should return "Nunca" when lastWorkoutAt is null', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
        );
        expect(student.lastActivity, 'Nunca');
      });

      test('should return "Hoje" for today', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          lastWorkoutAt: DateTime.now(),
        );
        expect(student.lastActivity, 'Hoje');
      });

      test('should return "Ontem" for yesterday', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          lastWorkoutAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(student.lastActivity, 'Ontem');
      });

      test('should return days for less than a week', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          lastWorkoutAt: DateTime.now().subtract(const Duration(days: 4)),
        );
        expect(student.lastActivity, 'Há 4 dias');
      });

      test('should return weeks for less than a month', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          lastWorkoutAt: DateTime.now().subtract(const Duration(days: 14)),
        );
        expect(student.lastActivity, 'Há 2 semanas');
      });

      test('should return months for more than 30 days', () {
        final student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
          lastWorkoutAt: DateTime.now().subtract(const Duration(days: 60)),
        );
        expect(student.lastActivity, 'Há 2 meses');
      });
    });

    group('initials', () {
      test('should return first two letters of single name', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'João',
        );
        expect(student.initials, 'JO');
      });

      test('should return first letter of first and last name', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'João Silva',
        );
        expect(student.initials, 'JS');
      });

      test('should return first letter of first two names for multiple names', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'João Carlos Silva',
        );
        expect(student.initials, 'JC');
      });

      test('should handle single character name', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'J',
        );
        expect(student.initials, 'J');
      });

      test('should return uppercase initials', () {
        const student = TrainerStudent(
          id: 'student-1',
          name: 'maria santos',
        );
        expect(student.initials, 'MS');
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = StudentFixtures.active();
        final copy = original.copyWith(
          name: 'Updated Name',
          isActive: false,
        );

        expect(copy.name, 'Updated Name');
        expect(copy.isActive, false);
        expect(copy.id, original.id);
        expect(copy.email, original.email);
      });

      test('should maintain all fields when copying', () {
        final original = StudentFixtures.active();
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.email, original.email);
        expect(copy.avatarUrl, original.avatarUrl);
        expect(copy.phone, original.phone);
        expect(copy.isActive, original.isActive);
        expect(copy.joinedAt, original.joinedAt);
        expect(copy.lastWorkoutAt, original.lastWorkoutAt);
        expect(copy.currentWorkoutName, original.currentWorkoutName);
        expect(copy.totalWorkouts, original.totalWorkouts);
        expect(copy.completedWorkouts, original.completedWorkouts);
        expect(copy.adherencePercent, original.adherencePercent);
        expect(copy.goal, original.goal);
        expect(copy.stats, original.stats);
      });
    });

    group('fixture variations', () {
      test('active student should have expected values', () {
        final student = StudentFixtures.active();

        expect(student.isActive, true);
        expect(student.currentWorkoutName, isNotNull);
        expect(student.totalWorkouts, greaterThan(0));
      });

      test('inactive student should have expected values', () {
        final student = StudentFixtures.inactive();

        expect(student.isActive, false);
        expect(student.lastWorkoutAt, isNotNull);
      });

      test('new student should be identified as new', () {
        final student = StudentFixtures.newStudent();

        expect(student.isNew, true);
      });

      test('student without workouts should have zero counts', () {
        final student = StudentFixtures.withoutWorkouts();

        expect(student.totalWorkouts, 0);
        expect(student.completedWorkouts, 0);
        expect(student.adherencePercent, 0);
        expect(student.lastWorkoutAt, isNull);
      });
    });
  });

  group('TrainerStudentsState', () {
    test('should create with default values', () {
      const state = TrainerStudentsState();

      expect(state.students, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should create with provided values', () {
      final students = StudentFixtures.mixedList();
      final state = TrainerStudentsState(
        students: students,
        isLoading: true,
        error: 'Test error',
      );

      expect(state.students.length, 5);
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
    });

    group('activeCount', () {
      test('should return 0 for empty list', () {
        const state = TrainerStudentsState();
        expect(state.activeCount, 0);
      });

      test('should count active students correctly', () {
        final students = StudentFixtures.mixedList();
        final state = TrainerStudentsState(students: students);

        // From mixedList: active, inactive, new (active), without workouts (active), active
        // Active: student-1, student-3, student-4, student-5 = 4
        expect(state.activeCount, 4);
      });
    });

    group('inactiveCount', () {
      test('should return 0 for empty list', () {
        const state = TrainerStudentsState();
        expect(state.inactiveCount, 0);
      });

      test('should count inactive students correctly', () {
        final students = StudentFixtures.mixedList();
        final state = TrainerStudentsState(students: students);

        // From mixedList: only student-2 is inactive = 1
        expect(state.inactiveCount, 1);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = TrainerStudentsState(
          students: StudentFixtures.mixedList(),
          isLoading: false,
          error: null,
        );
        final copy = original.copyWith(
          isLoading: true,
          error: 'New error',
        );

        expect(copy.students, original.students);
        expect(copy.isLoading, true);
        expect(copy.error, 'New error');
      });

      test('should clear error when copying with null', () {
        const original = TrainerStudentsState(
          isLoading: false,
          error: 'Old error',
        );
        final copy = original.copyWith(error: null);

        expect(copy.error, isNull);
      });
    });
  });

  group('PendingInvite', () {
    test('should create with required fields', () {
      final invite = PendingInvite(
        id: 'invite-1',
        email: 'test@example.com',
        role: 'student',
        organizationId: 'org-1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );

      expect(invite.id, 'invite-1');
      expect(invite.email, 'test@example.com');
      expect(invite.role, 'student');
      expect(invite.organizationId, 'org-1');
    });

    group('expiresWithinDays', () {
      test('should return true when expires within specified days', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now(),
        );

        expect(invite.expiresWithinDays(3), true);
        expect(invite.expiresWithinDays(2), true);
      });

      test('should return false when expires after specified days', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
        );

        expect(invite.expiresWithinDays(3), false);
      });
    });

    group('timeSinceCreated', () {
      test('should return minutes for recent creation', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        expect(invite.timeSinceCreated, 'Há 30 min');
      });

      test('should return hours for same day', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );

        expect(invite.timeSinceCreated, 'Há 5h');
      });

      test('should return "1 dia" for yesterday', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        );

        expect(invite.timeSinceCreated, 'Há 1 dia');
      });

      test('should return days for older invites', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        expect(invite.timeSinceCreated, 'Há 3 dias');
      });
    });

    group('timeUntilExpiration', () {
      test('should return "Expirado" for past dates', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        );

        expect(invite.timeUntilExpiration, 'Expirado');
      });

      test('should return "Expira hoje" for today', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(hours: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        );

        expect(invite.timeUntilExpiration, 'Expira hoje');
      });

      test('should return "Expira amanhã" for tomorrow', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(hours: 30)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        expect(invite.timeUntilExpiration, 'Expira amanhã');
      });

      test('should return days for future dates', () {
        final invite = PendingInvite(
          id: 'invite-1',
          email: 'test@example.com',
          role: 'student',
          organizationId: 'org-1',
          expiresAt: DateTime.now().add(const Duration(days: 5, hours: 12)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        // Account for rounding - result should be 4 or 5 days
        expect(invite.timeUntilExpiration, matches(RegExp(r'Expira em [45] dias')));
      });
    });

    group('fromJson', () {
      test('should parse from JSON correctly', () {
        final json = StudentFixtures.pendingInviteApiResponse();
        final invite = PendingInvite.fromJson(json);

        expect(invite.id, 'invite-1');
        expect(invite.email, 'novo@example.com');
        expect(invite.role, 'student');
        expect(invite.organizationId, 'org-1');
        expect(invite.organizationName, 'Academia Fitness');
        expect(invite.invitedByName, 'Trainer João');
        expect(invite.isExpired, false);
        expect(invite.token, 'token-abc-123');
      });
    });

    group('fixture variations', () {
      test('pending invite should not be expired', () {
        final invite = StudentFixtures.pendingInvite();

        expect(invite.isExpired, false);
        expect(invite.expiresAt.isAfter(DateTime.now()), true);
      });

      test('expired invite should be marked as expired', () {
        final invite = StudentFixtures.expiredInvite();

        expect(invite.isExpired, true);
      });
    });
  });

  group('PendingInvitesState', () {
    test('should create with default values', () {
      const state = PendingInvitesState();

      expect(state.invites, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should create with provided values', () {
      final invites = [
        StudentFixtures.pendingInvite(id: 'invite-1'),
        StudentFixtures.pendingInvite(id: 'invite-2'),
      ];
      final state = PendingInvitesState(
        invites: invites,
        isLoading: true,
        error: 'Test error',
      );

      expect(state.invites.length, 2);
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final invites = [StudentFixtures.pendingInvite()];
        final original = PendingInvitesState(
          invites: invites,
          isLoading: false,
        );
        final copy = original.copyWith(
          isLoading: true,
        );

        expect(copy.invites, original.invites);
        expect(copy.isLoading, true);
      });
    });
  });
}
