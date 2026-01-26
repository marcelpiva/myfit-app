import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/plan_draft_service.dart';
import 'plan_wizard_provider.dart';

/// Provider for plan drafts list
final planDraftsProvider = StateNotifierProvider<PlanDraftsNotifier, AsyncValue<List<PlanDraft>>>((ref) {
  return PlanDraftsNotifier();
});

/// Provider for current draft ID (if editing a draft)
final currentDraftIdProvider = StateProvider<String?>((ref) => null);

/// Auto-save controller provider
final planAutoSaveProvider = Provider<PlanAutoSaveController>((ref) {
  return PlanAutoSaveController(ref);
});

/// Notifier for managing drafts list
class PlanDraftsNotifier extends StateNotifier<AsyncValue<List<PlanDraft>>> {
  PlanDraftsNotifier() : super(const AsyncValue.loading()) {
    loadDrafts();
  }

  final _draftService = PlanDraftService.instance;

  Future<void> loadDrafts() async {
    state = const AsyncValue.loading();
    try {
      final drafts = await _draftService.getDrafts();
      state = AsyncValue.data(drafts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> saveDraft(PlanWizardState wizardState, {String? existingDraftId}) async {
    final draftId = await _draftService.saveDraft(wizardState, existingDraftId: existingDraftId);
    await loadDrafts();
    return draftId;
  }

  Future<void> deleteDraft(String draftId) async {
    await _draftService.deleteDraft(draftId);
    await loadDrafts();
  }

  PlanWizardState? restoreFromDraft(PlanDraft draft) {
    return _draftService.restoreFromDraft(draft);
  }

  Future<PlanDraft?> getDraft(String draftId) async {
    return await _draftService.getDraft(draftId);
  }
}

/// Controller for auto-saving wizard state
class PlanAutoSaveController {
  final Ref _ref;
  Timer? _debounceTimer;
  String? _currentDraftId;

  static const Duration _autoSaveDelay = Duration(seconds: 30);

  PlanAutoSaveController(this._ref);

  /// Start auto-saving with debounce
  void scheduleAutoSave(PlanWizardState state) {
    _debounceTimer?.cancel();

    // Only auto-save if we have meaningful data
    if (state.planName.isEmpty && state.workouts.isEmpty) {
      return;
    }

    _debounceTimer = Timer(_autoSaveDelay, () async {
      await _performAutoSave(state);
    });
  }

  /// Force immediate save
  Future<String?> saveNow(PlanWizardState state) async {
    _debounceTimer?.cancel();
    return await _performAutoSave(state);
  }

  /// Perform the actual save
  Future<String?> _performAutoSave(PlanWizardState state) async {
    // Don't save if in edit mode (editing existing plan)
    if (state.editingPlanId != null) {
      return null;
    }

    try {
      final draftsNotifier = _ref.read(planDraftsProvider.notifier);
      _currentDraftId = await draftsNotifier.saveDraft(
        state,
        existingDraftId: _currentDraftId ?? _ref.read(currentDraftIdProvider),
      );
      _ref.read(currentDraftIdProvider.notifier).state = _currentDraftId;
      return _currentDraftId;
    } catch (_) {
      return null;
    }
  }

  /// Load a draft into the wizard
  Future<bool> loadDraft(String draftId, PlanWizardNotifier notifier) async {
    final draftsNotifier = _ref.read(planDraftsProvider.notifier);
    final draft = await draftsNotifier.getDraft(draftId);

    if (draft == null) return false;

    final state = draftsNotifier.restoreFromDraft(draft);
    if (state == null) return false;

    notifier.restoreState(state);
    _currentDraftId = draftId;
    _ref.read(currentDraftIdProvider.notifier).state = draftId;
    return true;
  }

  /// Clear current draft after successful save
  Future<void> clearDraftAfterSave() async {
    if (_currentDraftId != null) {
      final draftsNotifier = _ref.read(planDraftsProvider.notifier);
      await draftsNotifier.deleteDraft(_currentDraftId!);
      _currentDraftId = null;
      _ref.read(currentDraftIdProvider.notifier).state = null;
    }
    _debounceTimer?.cancel();
  }

  /// Set current draft ID (when loading existing draft)
  void setCurrentDraftId(String? draftId) {
    _currentDraftId = draftId;
  }

  /// Cancel pending auto-save
  void cancel() {
    _debounceTimer?.cancel();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
