import 'queue_entry.dart';

/// Abstract repository interface for Queue data
/// 
/// This interface defines the contract for queue data operations.
/// Implemented by ApiQueueRepository, which calls the backend REST API.
abstract class QueueRepository {
  /// Get all queue entries for today
  Future<List<QueueEntry>> getTodayQueue();

  /// Get queue entry by ID
  Future<QueueEntry?> getQueueEntryById(String id);

  /// Add a patient to the queue
  Future<QueueEntry> addToQueue(QueueEntry entry);

  /// Update queue entry status
  Future<QueueEntry> updateQueueEntry(QueueEntry entry);

  /// Start the consultation for this entry (backend records `start_time`)
  Future<QueueEntry> startConsultation(String id);

  /// Mark the consultation as completed (backend records `completion_time`)
  Future<QueueEntry> completeConsultation(String id);

  /// Cancel this queue entry
  Future<QueueEntry> cancelEntry(String id);

  /// Remove from queue
  Future<void> removeFromQueue(String id);

  /// Get current patient (in progress)
  Future<QueueEntry?> getCurrentPatient();

  /// Get next patient in queue
  Future<QueueEntry?> getNextPatient();

  /// Get queue count for today
  Future<int> getTodayQueueCount();
}
