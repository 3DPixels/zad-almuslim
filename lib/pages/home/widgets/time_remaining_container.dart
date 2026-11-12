import 'dart:async';

import 'package:flutter/material.dart';

class TimeRemainingContainer extends StatefulWidget {
  final DateTime? targetTime;
  final bool isPostAdhan;
  final VoidCallback? onTimerComplete;

  const TimeRemainingContainer({
    super.key,
    this.targetTime,
    this.isPostAdhan = false,
    this.onTimerComplete,
  });

  @override
  State<TimeRemainingContainer> createState() => _TimeRemainingContainerState();
}

class _TimeRemainingContainerState extends State<TimeRemainingContainer> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    if (widget.targetTime != null) _startTimer();
  }

  @override
  void didUpdateWidget(TimeRemainingContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetTime != oldWidget.targetTime ||
        widget.isPostAdhan != oldWidget.isPostAdhan) {
      _updateDuration();
      if (widget.targetTime != null && _timer == null) _startTimer();
    }
  }

  void _updateDuration() {
    if (widget.targetTime == null) {
      _duration = Duration.zero;
      return;
    }

    final now = DateTime.now();

    if (widget.isPostAdhan) {
      if (now.isAfter(widget.targetTime!)) {
        _duration = now.difference(widget.targetTime!);
        if (_duration.inMinutes >= 25) {
          _timer?.cancel();
          _timer = null;
          widget.onTimerComplete?.call();
        }
      } else {
        _duration = Duration.zero;
      }
    } else {
      if (widget.targetTime!.isAfter(now)) {
        _duration = widget.targetTime!.difference(now);
      } else {
        _duration = Duration.zero;
        _timer?.cancel();
        _timer = null;
        widget.onTimerComplete?.call();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _updateDuration());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0 && !widget.isPostAdhan) return "00:00:00";

    // Standard numbers formatted to 2 digits
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    String formatted = "$hours:$minutes:$seconds";
    return widget.isPostAdhan ? "+ $formatted" : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .center,
        children: [
          Text(
            widget.isPostAdhan ? 'منذ الأذان' : 'باقي على الأذان',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          // Forced LTR direction so the time format doesn't flip in Arabic
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              widget.targetTime == null
                  ? "--:--:--"
                  : _formatDuration(_duration),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
