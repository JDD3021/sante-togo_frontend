import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Compact play/pause control to preview a heart-sound clip.
///
/// Works from either in-memory [bytes] (a capture not yet submitted) or a
/// [url] (an already-analyzed clip, e.g. from history) — pass whichever is
/// available. If both are null the button renders disabled.
class AudioPlayButton extends StatefulWidget {
  final Uint8List? bytes;
  final String? url;
  final Color? color;

  const AudioPlayButton({super.key, this.bytes, this.url, this.color});

  @override
  State<AudioPlayButton> createState() => _AudioPlayButtonState();
}

class _AudioPlayButtonState extends State<AudioPlayButton> {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _state = PlayerState.stopped;
  bool _isLoading = false;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _state = PlayerState.stopped);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  bool get _hasSource => widget.bytes != null || widget.url != null;

  Future<void> _toggle() async {
    if (!_hasSource || _isLoading) return;

    if (_state == PlayerState.playing) {
      await _player.pause();
      return;
    }
    if (_state == PlayerState.paused) {
      await _player.resume();
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.bytes != null) {
        await _player.play(BytesSource(widget.bytes!));
      } else {
        await _player.play(UrlSource(widget.url!));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Lecture impossible pour cet enregistrement.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primaryDark;
    final isPlaying = _state == PlayerState.playing;

    if (_isLoading) {
      return SizedBox(
        width: AppConstants.iconLg,
        height: AppConstants.iconLg,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      );
    }

    return IconButton(
      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
      iconSize: AppConstants.iconLg,
      color: _hasSource ? color : AppColors.inkSoft,
      onPressed: _hasSource ? _toggle : null,
      tooltip: isPlaying ? 'Mettre en pause' : 'Écouter',
    );
  }
}
