import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/skeleton.dart';
import '../data/api_queue_repository.dart';
import '../domain/queue_entry.dart';
import '../../../core/network/api_exception.dart';

/// Queue screen with patient list
class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final ApiQueueRepository _repository = ApiQueueRepository();
  List<QueueEntry> _queue = [];
  bool _isLoading = true;
  int _queueCount = 0;
  String? _errorMessage;
  final Set<String> _updatingEntryIds = {};

  // Mock offline status - will be real in production
  final bool _isOffline = false;
  final int _pendingSync = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final queue = await _repository.getTodayQueue();
      final count = await _repository.getTodayQueueCount();
      if (!mounted) return;
      setState(() {
        _queue = queue;
        _queueCount = count;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException ? e.message : 'Une erreur inattendue est survenue.';
      });
    }
  }

  void _onPatientTap(QueueEntry entry) {
    context.push('/patient/${entry.patientId}');
  }

  Future<void> _updateStatus(QueueEntry entry, QueueStatus newStatus) async {
    final index = _queue.indexWhere((e) => e.id == entry.id);
    if (index == -1 || _updatingEntryIds.contains(entry.id)) return;
    final previousEntry = _queue[index];

    // Reflect the new status immediately — the network call happens after.
    setState(() {
      _updatingEntryIds.add(entry.id);
      _queue[index] = entry.copyWith(
        status: newStatus,
        startTime: newStatus == QueueStatus.inProgress ? DateTime.now() : entry.startTime,
        endTime: newStatus == QueueStatus.completed ? DateTime.now() : entry.endTime,
      );
    });

    try {
      final QueueEntry updated;
      switch (newStatus) {
        case QueueStatus.inProgress:
          updated = await _repository.startConsultation(entry.id);
          break;
        case QueueStatus.completed:
          updated = await _repository.completeConsultation(entry.id);
          break;
        case QueueStatus.cancelled:
          updated = await _repository.cancelEntry(entry.id);
          break;
        default:
          updated = await _repository.updateQueueEntry(entry.copyWith(status: newStatus));
      }
      if (!mounted) return;
      setState(() {
        final i = _queue.indexWhere((e) => e.id == entry.id);
        // The action endpoints don't know the list position; keep the one
        // already assigned when the queue was loaded.
        if (i != -1) _queue[i] = updated.copyWith(orderNumber: previousEntry.orderNumber);
        _updatingEntryIds.remove(entry.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final i = _queue.indexWhere((e) => e.id == entry.id);
        if (i != -1) _queue[i] = previousEntry; // rollback
        _updatingEntryIds.remove(entry.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠️ ${e is ApiException ? e.message : 'Échec de la mise à jour. Réessayez.'}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _confirmCancel(QueueEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler ce passage ?'),
        content: Text('${entry.patientName} sera retiré(e) de la file d\'attente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _updateStatus(entry, QueueStatus.cancelled);
    }
  }

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.inProgress:
        return AppColors.primary;
      case QueueStatus.next:
        return AppColors.accent;
      case QueueStatus.waiting:
        return AppColors.sandDark;
      case QueueStatus.completed:
        return AppColors.inkSoft;
      case QueueStatus.cancelled:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text(
          'File d\'attente',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingMd),
            child: StatusBadge(
              text: '$_queueCount patients',
              type: StatusType.neutral,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const SkeletonList()
          : _errorMessage != null
              ? ErrorState(message: _errorMessage!, onRetry: _loadQueue)
              : Column(
              children: [
                // Offline banner (if applicable)
                if (_isOffline) _buildOfflineBanner(),
                
                // Queue list
                Expanded(
                  child: _queue.isEmpty
                      ? const EmptyState(
                          icon: AppIcons.queue,
                          title: 'File d\'attente vide',
                          subtitle: 'Aucun patient en attente aujourd\'hui',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMd,
                            vertical: AppConstants.spacingSm,
                          ),
                          itemCount: _queue.length,
                          itemBuilder: (context, index) {
                            final entry = _queue[index];
                            return _buildQueueCard(entry);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: const BoxDecoration(
        color: AppColors.accentLight,
        border: Border(
          bottom: BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.offline,
            color: AppColors.accent,
            size: AppConstants.iconMd,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              'Hors-ligne · $_pendingSync en attente d\'envoi',
              style: AppTextStyles.secondary.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(QueueEntry entry) {
    final isUpdating = _updatingEntryIds.contains(entry.id);

    return AppCard(
      onTap: () => _onPatientTap(entry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Order number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.status),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Center(
                  child: Text(
                    '${entry.orderNumber}',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),

              // Patient info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingXxs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: AppConstants.iconSm,
                          color: AppColors.inkSoft,
                        ),
                        const SizedBox(width: AppConstants.spacingXxs),
                        Text(
                          entry.patientVillage,
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              StatusBadge(
                text: entry.status.label,
                type: _getStatusType(entry.status),
              ),
            ],
          ),
          if (entry.status == QueueStatus.waiting ||
              entry.status == QueueStatus.inProgress) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                if (entry.status == QueueStatus.waiting)
                  Expanded(
                    child: AppButton(
                      text: 'Démarrer',
                      icon: Icons.play_arrow,
                      fullWidth: false,
                      isLoading: isUpdating,
                      onPressed: () => _updateStatus(entry, QueueStatus.inProgress),
                    ),
                  ),
                if (entry.status == QueueStatus.inProgress)
                  Expanded(
                    child: AppButton(
                      text: 'Terminer',
                      icon: Icons.check,
                      fullWidth: false,
                      isLoading: isUpdating,
                      onPressed: () => _updateStatus(entry, QueueStatus.completed),
                    ),
                  ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: AppSecondaryButton(
                    text: 'Annuler',
                    fullWidth: false,
                    onPressed: isUpdating ? null : () => _confirmCancel(entry),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  StatusType _getStatusType(QueueStatus status) {
    switch (status) {
      case QueueStatus.inProgress:
        return StatusType.success;
      case QueueStatus.next:
        return StatusType.warning;
      case QueueStatus.waiting:
        return StatusType.neutral;
      case QueueStatus.completed:
        return StatusType.neutral;
      case QueueStatus.cancelled:
        return StatusType.error;
    }
  }
}
