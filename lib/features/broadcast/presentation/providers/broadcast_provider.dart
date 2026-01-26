import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/context_provider.dart';
import '../../data/services/broadcast_service.dart';

/// Recipient type for broadcast
enum BroadcastRecipientType {
  all,
  active,
  inactive,
  selected,
}

extension BroadcastRecipientTypeExtension on BroadcastRecipientType {
  String get displayName {
    switch (this) {
      case BroadcastRecipientType.all:
        return 'Todos os Alunos';
      case BroadcastRecipientType.active:
        return 'Alunos Ativos';
      case BroadcastRecipientType.inactive:
        return 'Alunos Inativos';
      case BroadcastRecipientType.selected:
        return 'Selecionar Alunos';
    }
  }

  String get apiValue {
    switch (this) {
      case BroadcastRecipientType.all:
        return 'all';
      case BroadcastRecipientType.active:
        return 'active';
      case BroadcastRecipientType.inactive:
        return 'inactive';
      case BroadcastRecipientType.selected:
        return 'selected';
    }
  }
}

/// State for broadcast form
class BroadcastFormState {
  final String title;
  final String message;
  final BroadcastRecipientType recipientType;
  final List<String> selectedRecipientIds;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final bool isLoading;
  final String? error;
  final bool success;

  const BroadcastFormState({
    this.title = '',
    this.message = '',
    this.recipientType = BroadcastRecipientType.all,
    this.selectedRecipientIds = const [],
    this.isScheduled = false,
    this.scheduledAt,
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  BroadcastFormState copyWith({
    String? title,
    String? message,
    BroadcastRecipientType? recipientType,
    List<String>? selectedRecipientIds,
    bool? isScheduled,
    DateTime? scheduledAt,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return BroadcastFormState(
      title: title ?? this.title,
      message: message ?? this.message,
      recipientType: recipientType ?? this.recipientType,
      selectedRecipientIds: selectedRecipientIds ?? this.selectedRecipientIds,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }

  bool get isValid =>
      title.trim().isNotEmpty &&
      message.trim().isNotEmpty &&
      (recipientType != BroadcastRecipientType.selected ||
          selectedRecipientIds.isNotEmpty);
}

/// Notifier for broadcast form
class BroadcastFormNotifier extends StateNotifier<BroadcastFormState> {
  final Ref _ref;
  final BroadcastService _service;

  BroadcastFormNotifier(this._ref, {BroadcastService? service})
      : _service = service ?? BroadcastService(),
        super(const BroadcastFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title, error: null);
  }

  void setMessage(String message) {
    state = state.copyWith(message: message, error: null);
  }

  void setRecipientType(BroadcastRecipientType type) {
    state = state.copyWith(
      recipientType: type,
      selectedRecipientIds: type == BroadcastRecipientType.selected
          ? state.selectedRecipientIds
          : [],
      error: null,
    );
  }

  void toggleRecipient(String recipientId) {
    final currentIds = List<String>.from(state.selectedRecipientIds);
    if (currentIds.contains(recipientId)) {
      currentIds.remove(recipientId);
    } else {
      currentIds.add(recipientId);
    }
    state = state.copyWith(selectedRecipientIds: currentIds, error: null);
  }

  void setScheduled(bool isScheduled) {
    state = state.copyWith(
      isScheduled: isScheduled,
      scheduledAt: isScheduled ? DateTime.now().add(const Duration(hours: 1)) : null,
      error: null,
    );
  }

  void setScheduledAt(DateTime? dateTime) {
    state = state.copyWith(scheduledAt: dateTime, error: null);
  }

  Future<bool> sendBroadcast() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Preencha todos os campos obrigatorios');
      return false;
    }

    final orgId = _ref.read(activeContextProvider)?.organization.id;
    if (orgId == null) {
      state = state.copyWith(error: 'Organizacao nao encontrada');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.sendBroadcast(
        orgId,
        title: state.title.trim(),
        message: state.message.trim(),
        recipientType: state.recipientType.apiValue,
        recipientIds: state.recipientType == BroadcastRecipientType.selected
            ? state.selectedRecipientIds
            : null,
        scheduledAt: state.isScheduled ? state.scheduledAt : null,
      );

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const BroadcastFormState();
  }
}

/// Provider for broadcast form
final broadcastFormProvider =
    StateNotifierProvider.autoDispose<BroadcastFormNotifier, BroadcastFormState>(
  (ref) => BroadcastFormNotifier(ref),
);
