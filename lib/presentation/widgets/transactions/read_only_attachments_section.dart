import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/transactions/models/attachment.dart';
import '../../../features/transactions/services/transaction_attachment_service.dart';
import 'package:bytebank/theme/theme.dart';

class ReadOnlyAttachmentsSection extends StatefulWidget {
  final String transactionId;

  const ReadOnlyAttachmentsSection({super.key, required this.transactionId});

  @override
  State<ReadOnlyAttachmentsSection> createState() => _ReadOnlyAttachmentsSectionState();
}

class _ReadOnlyAttachmentsSectionState extends State<ReadOnlyAttachmentsSection> {
  final _service = TransactionAttachmentService();

  Future<void> _showPreview(BuildContext context, Attachment a) async {
    if (a.contentType.startsWith('image/')) {
      await showDialog(
        context: context,
        builder: (ctx) => Dialog(
          child: InteractiveViewer(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(a.downloadUrl),
            ),
          ),
        ),
      );
    } else {
      final uri = Uri.parse(a.downloadUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o arquivo.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightGreenColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Anexos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<Attachment>>(
            stream: _service.watchAttachments(
              userId: user.uid,
              transactionId: widget.transactionId,
            ),
            builder: (context, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final items = snap.data!;

              if (items.isEmpty) {
                return Text(
                  'Nenhum anexo',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }

              final itemHeight = 64.0;
              final maxListHeight = math.min(
                220.0,
                MediaQuery.of(context).size.height * 0.35,
              );
              final listHeight = math.min(
                items.length * itemHeight,
                maxListHeight,
              );

              return SizedBox(
                height: listHeight,
                child: ListView.separated(
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return Row(
                      children: [
                        Icon(
                          a.contentType.startsWith('image/')
                              ? Icons.image_outlined
                              : Icons.picture_as_pdf_outlined,
                          color: AppColors.lightGreenColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showPreview(context, a),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    a.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Abrir',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _showPreview(context, a),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
