import '../domain/queue_entry.dart';
import '../domain/queue_repository.dart';

/// Mock implementation of QueueRepository
/// 
/// This repository uses in-memory data to simulate a real backend.
/// It contains realistic queue data for demonstration.
/// 
/// NOTE: This is a MOCK implementation. Replace with ApiQueueRepository
/// when the backend REST API is ready. The interface (QueueRepository)
/// ensures the rest of the code doesn't need to change.
class MockQueueRepository implements QueueRepository {
  final List<QueueEntry> _queue;

  MockQueueRepository() : _queue = _generateMockQueue();

  @override
  Future<List<QueueEntry>> getTodayQueue() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_queue);
  }

  @override
  Future<QueueEntry?> getQueueEntryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _queue.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<QueueEntry> addToQueue(QueueEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newEntry = entry.copyWith(
      id: 'QUE${DateTime.now().millisecondsSinceEpoch}',
    );
    _queue.add(newEntry);
    return newEntry;
  }

  @override
  Future<QueueEntry> updateQueueEntry(QueueEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _queue.indexWhere((q) => q.id == entry.id);
    if (index != -1) {
      _queue[index] = entry;
      return _queue[index];
    }
    throw Exception('Queue entry not found');
  }

  @override
  Future<void> removeFromQueue(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _queue.removeWhere((q) => q.id == id);
  }

  @override
  Future<QueueEntry?> getCurrentPatient() async {
    try {
      return _queue.firstWhere((q) => q.status == QueueStatus.inProgress);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<QueueEntry?> getNextPatient() async {
    try {
      return _queue.firstWhere((q) => q.status == QueueStatus.next);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getTodayQueueCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _queue.length;
  }

  /// Generate realistic mock queue data for today
  static List<QueueEntry> _generateMockQueue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      QueueEntry(
        id: 'QUE001',
        patientId: 'PAT003',
        patientName: 'Yao Agbéyomé',
        patientVillage: 'Sokodé',
        orderNumber: 1,
        status: QueueStatus.inProgress,
        arrivalTime: today.add(const Duration(hours: 8, minutes: 15)),
        startTime: today.add(const Duration(hours: 8, minutes: 30)),
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE002',
        patientId: 'PAT004',
        patientName: 'Mawunyo Tchassim',
        patientVillage: 'Atakpamé',
        orderNumber: 2,
        status: QueueStatus.next,
        arrivalTime: today.add(const Duration(hours: 8, minutes: 45)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE003',
        patientId: 'PAT006',
        patientName: 'Sélom Kpotou',
        patientVillage: 'Kpalimé',
        orderNumber: 3,
        status: QueueStatus.waiting,
        arrivalTime: today.add(const Duration(hours: 9, minutes: 10)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE004',
        patientId: 'PAT008',
        patientName: 'Akossiwa Mawulé',
        patientVillage: 'Notsé',
        orderNumber: 4,
        status: QueueStatus.waiting,
        arrivalTime: today.add(const Duration(hours: 9, minutes: 30)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE005',
        patientId: 'PAT010',
        patientName: 'Mélané Kougan',
        patientVillage: 'Aného',
        orderNumber: 5,
        status: QueueStatus.waiting,
        arrivalTime: today.add(const Duration(hours: 9, minutes: 45)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE006',
        patientId: 'PAT001',
        patientName: 'Kofi Kokou',
        patientVillage: 'Lomé',
        orderNumber: 6,
        status: QueueStatus.waiting,
        arrivalTime: today.add(const Duration(hours: 10, minutes: 0)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
      QueueEntry(
        id: 'QUE007',
        patientId: 'PAT007',
        patientName: 'Edem Kodjo',
        patientVillage: 'Bassar',
        orderNumber: 7,
        status: QueueStatus.waiting,
        arrivalTime: today.add(const Duration(hours: 10, minutes: 15)),
        startTime: null,
        endTime: null,
        notes: null,
      ),
    ];
  }
}
