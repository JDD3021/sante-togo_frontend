import 'queue_entry.dart';

/// Abstract repository interface for Queue data
/// 
/// This interface defines the contract for queue data operations.
/// Currently implemented by MockQueueRepository with in-memory data.
/// In future iterations, this will be replaced by ApiQueueRepository
/// that calls the real backend REST API.
/// 
/// NOTE: This is a MOCK implementation. Replace with real API calls
/// when the backend is ready.
abstract class QueueRepository {
  /// Get all queue entries for today
  Future<List<QueueEntry>> getTodayQueue();

  /// Get queue entry by ID
  Future<QueueEntry?> getQueueEntryById(String id);

  /// Add a patient to the queue
  Future<QueueEntry> addToQueue(QueueEntry entry);

  /// Update queue entry status
  Future<QueueEntry> updateQueueEntry(QueueEntry entry);

  /// Remove from queue
  Future<void> removeFromQueue(String id);

  /// Get current patient (in progress)
  Future<QueueEntry?> getCurrentPatient();

  /// Get next patient in queue
  Future<QueueEntry?> getNextPatient();

  /// Get queue count for today
  Future<int> getTodayQueueCount();
}
