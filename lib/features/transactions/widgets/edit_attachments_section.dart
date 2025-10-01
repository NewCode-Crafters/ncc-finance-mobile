import 'dart:io';
import 'dart:math' as math;
import 'package:bytebank/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attachment.dart';
import '../services/transaction_attachment_service.dart';
import 'package:bytebank/theme/theme.dart';

class EditAttachmentsController {
  _EditAttachmentsSectionState? _state;

  Future<void> commit(String userId) =>
      _state?.commitChanges(userId) ?? Future.value();

  bool get hasPendingChanges => _state?._hasPendingChanges() ?? false;
}

class EditAttachmentsSection extends StatefulWidget {
  final String transactionId;
  final EditAttachmentsController controller;

  const EditAttachmentsSection({
    super.key,
    required this.transactionId,
    required this.controller,
  });

  @override
  State<EditAttachmentsSection> createState() => _EditAttachmentsSectionState();
}

class _EditAttachmentsSectionState extends State<EditAttachmentsSection> {
  final _service = TransactionAttachmentService();

  // Staging lists/maps. No network operations happen until commitChanges().
  final List<File> _stagedAdds = [];
  final Set<String> _stagedRemovals = {};
  final Map<String, File> _stagedReplacements = {};

  // Cached snapshot from the attachments stream to resolve attachment objects at commit time.
  List<Attachment> _latestItems = [];

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    super.dispose();
  }

  bool _hasPendingChanges() {
    return _stagedAdds.isNotEmpty ||
        _stagedRemovals.isNotEmpty ||
        _stagedReplacements.isNotEmpty;
  }

  Future<void> _pickFileAndStage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
      withData: false,
    );
    if (res == null || res.files.isEmpty) return;

    final path = res.files.single.path;
    if (path == null) return;

    final f = File(path);

    final size = await f.length();
    if (size > 10 * 1024 * 1024) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          buildAppSnackBar('Arquivo excede 10MB.', AppMessageType.error),
        );
        return;
      }
    }
    setState(() => _stagedAdds.add(f));
  }

  Future<void> _stageReplace(BuildContext context, Attachment old) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
    );
    if (res == null || res.files.isEmpty) return;

    final path = res.files.single.path;
    if (path == null) return;

    final f = File(path);

    final size = await f.length();
    if (size > 10 * 1024 * 1024) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          buildAppSnackBar('Arquivo excede 10MB.', AppMessageType.error),
        );
        return;
      }
    }
    setState(() {
      _stagedReplacements[old.id] = f;
      _stagedRemovals.remove(old.id);
    });
  }

  void _toggleRemove(Attachment a) {
    setState(() {
      if (_stagedRemovals.contains(a.id)) {
        _stagedRemovals.remove(a.id);
      } else {
        _stagedRemovals.add(a.id);
        _stagedReplacements.remove(a.id);
      }
    });
  }

  Attachment? _findLatestById(String id) {
    for (final e in _latestItems) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> commitChanges(String userId) async {
    try {
      final replacements = Map<String, File>.from(_stagedReplacements);
      for (final entry in replacements.entries) {
        final oldId = entry.key;
        final file = entry.value;
        await _service.uploadSingle(
          userId: userId,
          transactionId: widget.transactionId,
          file: file,
        );
        final old = _findLatestById(oldId);
        if (old != null) {
          await _service.deleteAttachment(
            userId: userId,
            transactionId: widget.transactionId,
            attachment: old,
          );
        }
      }

      // Additions
      final adds = List<File>.from(_stagedAdds);
      for (final f in adds) {
        await _service.uploadSingle(
          userId: userId,
          transactionId: widget.transactionId,
          file: f,
        );
      }

      // Removals
      final removals = List<String>.from(_stagedRemovals);
      for (final id in removals) {
        final a = _findLatestById(id);
        if (a != null) {
          await _service.deleteAttachment(
            userId: userId,
            transactionId: widget.transactionId,
            attachment: a,
          );
        }
      }
    } finally {
      // Clear staging regardless of outcome to avoid accidental duplicates on retry.
      if (mounted) {
        setState(() {
          _stagedAdds.clear();
          _stagedRemovals.clear();
          _stagedReplacements.clear();
        });
      }
    }
  }

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
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final uri = Uri.parse(a.downloadUrl);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
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
          Row(
            children: [
              Text('Anexos', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _pickFileAndStage(context),
                icon: const Icon(Icons.attach_file),
                label: const Text('Adicionar arquivo'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Attachment>>(
            stream: _service.watchAttachments(
              userId: user.uid,
              transactionId: widget.transactionId,
            ),
            builder: (context, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final items = snap.data!;
              // cache for commit resolution
              _latestItems = items;

              if (items.isEmpty && _stagedAdds.isEmpty) {
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
                items.length * itemHeight + (_stagedAdds.length * 56),
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
                    final isRemoved = _stagedRemovals.contains(a.id);
                    final isReplaced = _stagedReplacements.containsKey(a.id);
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
                                if (isReplaced)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Chip(
                                      label: Text(
                                        'Será substituído',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                if (isRemoved)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Chip(
                                      label: Text(
                                        'Será removido',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
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
                        if (!isRemoved)
                          IconButton(
                            tooltip: 'Substituir',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _stageReplace(context, a),
                          ),
                        IconButton(
                          tooltip: isRemoved ? 'Desfazer remoção' : 'Remover',
                          icon: Icon(
                            isRemoved ? Icons.undo : Icons.delete_outline,
                          ),
                          onPressed: () => _toggleRemove(a),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          if (_stagedAdds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Arquivos a adicionar',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Column(
              children: _stagedAdds
                  .map(
                    (f) => Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColors.lightGreenColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _stagedAdds.remove(f)),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
