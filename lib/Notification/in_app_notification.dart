import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/Notification/Notifications.dart';

OverlayEntry? _overlayEntry;
Timer? _dismissTimer;

void showTopInAppNotification({
  required BuildContext context,
  required String title,
  required String body,
}) {
  // Remove existing notification
  _dismissTopInAppNotification();

  final overlay = Overlay.of(context);
  if (overlay == null) return;

  _overlayEntry = OverlayEntry(
    builder: (_) => _TopNotificationWidget(
      title: title,
      body: body,
      onTap: () {
        _dismissTopInAppNotification();
        Get.to(() => NotificationScreen());
      },
      onClose: _dismissTopInAppNotification,
    ),
  );

  overlay.insert(_overlayEntry!);

  // Auto dismiss after 4 seconds
  _dismissTimer = Timer(const Duration(seconds: 4), () {
    _dismissTopInAppNotification();
  });
}

void _dismissTopInAppNotification() {
  _dismissTimer?.cancel();
  _dismissTimer = null;
  _overlayEntry?.remove();
  _overlayEntry = null;
}
class _TopNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TopNotificationWidget({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_TopNotificationWidget> createState() =>
      _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: const Key("top_notification"),
          direction: DismissDirection.up,
          onDismissed: (_) => widget.onClose(),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            color: Colors.black87,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.body,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
