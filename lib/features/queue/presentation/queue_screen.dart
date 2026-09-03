import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/api_queue_repository.dart';
import '../domain/queue_entry.dart';

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

  // Mock offline status - will be real in production
  final bool _isOffline = false;
  final int _pendingSync = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    final queue = await _repository.getTodayQueue();
    final count = await _repository.getTodayQueueCount();
    setState(() {
      _queue = queue;
      _queueCount = count;
      _isLoading = false;
    });
  }

  void _onPatientTap(QueueEntry entry) {
    context.push('/patient/${entry.patientId}');
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
          ? const LoadingIndicator(message: 'Chargement de la file...')
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
    return AppCard(
      onTap: () => _onPatientTap(entry),
      child: Row(
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
