import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../models/theme_model.dart';

class BackupDialog extends StatefulWidget {
  final ThemeModel theme;
  final VoidCallback onDataChanged;

  const BackupDialog({
    super.key,
    required this.theme,
    required this.onDataChanged,
  });

  @override
  State<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  bool _isExporting = false;
  bool _isImporting = false;
  final TextEditingController _importController = TextEditingController();
  String _statusMessage = '';

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting your WordDex...';
    });

    try {
      final exportData = await StorageService.exportWordDex();
      if (exportData != null) {
        await Clipboard.setData(ClipboardData(text: exportData));
        setState(() {
          _statusMessage = 'WordDex data copied to clipboard! Save this in a safe place.';
        });
      } else {
        setState(() {
          _statusMessage = 'No WordDex data to export.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _importData() async {
    final importText = _importController.text.trim();
    if (importText.isEmpty) {
      setState(() {
        _statusMessage = 'Please paste your backup data first.';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _statusMessage = 'Importing your WordDex...';
    });

    try {
      final success = await StorageService.importWordDex(importText);
      if (success) {
        setState(() {
          _statusMessage = 'Successfully imported WordDex data!';
          _importController.clear();
        });
        widget.onDataChanged();
      } else {
        setState(() {
          _statusMessage = 'Invalid backup data format.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error importing data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        _importController.text = clipboardData!.text!;
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error accessing clipboard.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.theme.backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'WordDex Backup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.theme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Keep your word collection safe by creating backups.',
              style: TextStyle(
                fontSize: 16,
                color: widget.theme.textColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Export Section
            Text(
              'Export Your Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.theme.textColor,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportData,
              icon: _isExporting 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
              label: Text(_isExporting ? 'Exporting...' : 'Copy Backup to Clipboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Import Section
            Text(
              'Restore Your Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.theme.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: widget.theme.textColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _importController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Paste your backup data here...',
                  hintStyle: TextStyle(color: widget.theme.textColor.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: TextStyle(
                  color: widget.theme.textColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.paste, size: 18),
                    label: const Text('Paste', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importData,
                    icon: _isImporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload, size: 18),
                    label: Text(
                      _isImporting ? 'Importing...' : 'Import',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.theme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: widget.theme.textColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: widget.theme.textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}