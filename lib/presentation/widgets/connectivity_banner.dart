import 'package:flutter/material.dart';
import 'package:bytebank/core/services/i_connectivity_service.dart';

/// Banner that displays when the device is offline.
///
/// Shows a yellow banner at the top of the screen with message:
/// "Modo offline, mostrando dados salvos".
class ConnectivityBanner extends StatelessWidget {
  final IConnectivityService connectivityService;
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.connectivityService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: connectivityService.isConnected,
      initialData: connectivityService.currentStatus ?? true,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Column(
          children: [
            // Show banner only when offline
            if (!isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                color: Colors.amber,
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo offline, mostrando dados salvos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
