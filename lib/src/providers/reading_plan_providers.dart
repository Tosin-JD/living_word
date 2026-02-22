import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/reading_plan.dart';
import '../repositories/reading_plan_repository.dart';
import '../services/reading_plan_service.dart';

final readingPlanRepositoryProvider = Provider<ReadingPlanRepository>((ref) {
  return ReadingPlanRepository();
});

final readingPlanServiceProvider = Provider<ReadingPlanService>((ref) {
  return ReadingPlanService();
});

class ReadingPlanState {
  final bool isLoading;
  final List<ReadingPlan> activePlans;
  final Set<String> readChapterKeys;
  final Map<String, String> readChapterDates;

  const ReadingPlanState({
    required this.isLoading,
    required this.activePlans,
    required this.readChapterKeys,
    required this.readChapterDates,
  });

  ReadingPlanState copyWith({
    bool? isLoading,
    List<ReadingPlan>? activePlans,
    Set<String>? readChapterKeys,
    Map<String, String>? readChapterDates,
  }) {
    return ReadingPlanState(
      isLoading: isLoading ?? this.isLoading,
      activePlans: activePlans ?? this.activePlans,
      readChapterKeys: readChapterKeys ?? this.readChapterKeys,
      readChapterDates: readChapterDates ?? this.readChapterDates,
    );
  }

  static const empty = ReadingPlanState(
    isLoading: true,
    activePlans: [],
    readChapterKeys: {},
    readChapterDates: {},
  );
}

class ReadingPlanController extends StateNotifier<ReadingPlanState> {
  final ReadingPlanRepository _repository;
  final ReadingPlanService _service;

  ReadingPlanController(this._repository, this._service)
    : super(ReadingPlanState.empty) {
    Future.microtask(load);
  }

  Future<void> load() async {
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true);
    }

    final plans = await _repository.getActivePlans();
    final readKeys = await _repository.getReadChapterKeys();
    final readDates = await _repository.getReadChapterDates();

    state = state.copyWith(
      isLoading: false,
      activePlans: plans,
      readChapterKeys: readKeys,
      readChapterDates: readDates,
    );
  }

  Future<void> startPlan(ReadingPlan plan) async {
    await _repository.addPlan(plan);
    await load();
  }

  Future<void> removePlan(String planId) async {
    await _repository.removePlan(planId);
    await load();
  }

  Future<void> markChapterRead(String book, int chapter) async {
    await _repository.markChapterRead(book: book, chapter: chapter);
    await load();
  }

  Future<void> markChapterUnread(String book, int chapter) async {
    await _repository.markChapterUnread(book: book, chapter: chapter);
    await load();
  }

  Future<void> markDayRead(ReadingPlanDay day) async {
    await _repository.markDayRead(day);
    await load();
  }

  Future<void> applyCatchUp({
    required ReadingPlan plan,
    required int remainingDays,
  }) async {
    final updated = _service.recalculatePlanPace(
      plan: plan,
      readChapterKeys: state.readChapterKeys,
      remainingDays: remainingDays,
    );
    await _repository.removePlan(plan.id);
    await _repository.addPlan(updated);
    await load();
  }
}

final readingPlanControllerProvider =
    StateNotifierProvider<ReadingPlanController, ReadingPlanState>((ref) {
      final repository = ref.watch(readingPlanRepositoryProvider);
      final service = ref.watch(readingPlanServiceProvider);
      return ReadingPlanController(repository, service);
    });
