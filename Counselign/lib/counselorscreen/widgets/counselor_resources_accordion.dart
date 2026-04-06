import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../studentscreen/models/resource.dart';
import '../services/counselor_resource_service.dart';
import '../../utils/download_helper.dart';

class CounselorResourcesAccordion extends StatefulWidget {
  const CounselorResourcesAccordion({super.key});

  @override
  State<CounselorResourcesAccordion> createState() =>
      _CounselorResourcesAccordionState();
}

class _CounselorResourcesAccordionState
    extends State<CounselorResourcesAccordion> {
  List<Resource> _resources = [];
  bool _isLoading = true;
  bool _isExpanded = false;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      debugPrint('CounselorResourcesAccordion: Starting to load resources');
      final resources = await CounselorResourceService.fetchResources();
      debugPrint(
        'CounselorResourcesAccordion: Received ${resources.length} resources',
      );

      if (mounted) {
        setState(() {
          _resources = resources;
          _isLoading = false;
        });

        if (_resources.isEmpty) {
          debugPrint('CounselorResourcesAccordion: No resources loaded');
        } else {
          debugPrint(
            'CounselorResourcesAccordion: Successfully loaded ${_resources.length} resources',
          );
          for (var i = 0; i < _resources.length && i < 3; i++) {
            debugPrint(
              'CounselorResourcesAccordion: Resource $i: ${_resources[i].title}',
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('CounselorResourcesAccordion: Error loading resources: $e');
      debugPrint('CounselorResourcesAccordion: Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getResourceIcon(Resource resource) {
    if (resource.isLink) return FontAwesomeIcons.link;
    if (resource.isPdf) return FontAwesomeIcons.filePdf;
    if (resource.isWord) return FontAwesomeIcons.fileWord;
    if (resource.isExcel) return FontAwesomeIcons.fileExcel;
    if (resource.isPowerPoint) return FontAwesomeIcons.filePowerpoint;
    if (resource.isImage) return FontAwesomeIcons.fileImage;
    if (resource.isVideo) return FontAwesomeIcons.fileVideo;
    return FontAwesomeIcons.file;
  }

  void _showPreview(Resource resource) {
    final fileUrl = CounselorResourceService.getFileUrl(resource.filePath);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resource.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: resource.isImage
                    ? InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.network(
                            fileUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Failed to load image'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : _buildFilePreview(resource),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(Resource resource) {
    IconData previewIcon;
    Color iconColor;
    String fileType;

    if (resource.isPdf) {
      previewIcon = FontAwesomeIcons.filePdf;
      iconColor = const Color(0xFFDC2626);
      fileType = 'PDF Document';
    } else if (resource.isWord) {
      previewIcon = FontAwesomeIcons.fileWord;
      iconColor = const Color(0xFF2563EB);
      fileType = 'Word Document';
    } else if (resource.isExcel) {
      previewIcon = FontAwesomeIcons.fileExcel;
      iconColor = const Color(0xFF16A34A);
      fileType = 'Excel Spreadsheet';
    } else if (resource.isPowerPoint) {
      previewIcon = FontAwesomeIcons.filePowerpoint;
      iconColor = const Color(0xFFEA580C);
      fileType = 'PowerPoint Presentation';
    } else if (resource.isVideo) {
      previewIcon = FontAwesomeIcons.fileVideo;
      iconColor = const Color(0xFFA855F7);
      fileType = 'Video File';
    } else {
      previewIcon = FontAwesomeIcons.file;
      iconColor = const Color(0xFF64748B);
      fileType = 'File';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(previewIcon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            fileType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              resource.fileName ?? 'Document',
              style: const TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndOpenFile(resource);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download & Open'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getResourceColor(Resource resource) {
    if (resource.isLink) return const Color(0xFF3B82F6);
    if (resource.isPdf) return const Color(0xFFDC2626);
    if (resource.isWord) return const Color(0xFF2563EB);
    if (resource.isExcel) return const Color(0xFF16A34A);
    if (resource.isPowerPoint) return const Color(0xFFEA580C);
    if (resource.isImage) return const Color(0xFF0891B2);
    if (resource.isVideo) return const Color(0xFFA855F7);
    return const Color(0xFF64748B);
  }

  Future<void> _handleResourceTap(Resource resource) async {
    try {
      if (resource.isLink && resource.externalUrl != null) {
        debugPrint('Opening link: ${resource.externalUrl}');
        final uri = Uri.parse(resource.externalUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Cannot launch URL: ${resource.externalUrl}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open this link')),
            );
          }
        }
      } else if (resource.isFile) {
        await _downloadAndOpenFile(resource);
      }
    } catch (e) {
      debugPrint('Error handling resource tap: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _downloadAndOpenFile(Resource resource) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Downloading ${resource.fileName ?? "file"}...'),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final downloadUrl = CounselorResourceService.getDownloadUrl(resource.id);
      final fileName = resource.fileName ?? 'downloaded_file';

      final success = await DownloadHelper.downloadAndOpenFile(
        url: downloadUrl,
        fileName: fileName,
      );

      if (mounted) {
        // Clear loading indicator
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully downloaded $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download file. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.folderOpen,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: _buildContent(isMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_resources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              FontAwesomeIcons.folderOpen,
              size: isMobile ? 48 : 56,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No resources available at this time.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_resources.length, (index) {
        final resource = _resources[index];
        final isExpanded = _expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Resource header
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Row(
                    children: [
                      FaIcon(
                        _getResourceIcon(resource),
                        color: _getResourceColor(resource),
                        size: isMobile ? 20 : 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (resource.category != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  resource.category!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),

              // Resource details (expanded)
              if (isExpanded)
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resource.description != null) ...[
                        Text(
                          resource.description!,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (resource.isFile) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                resource.fileName ?? 'File',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (resource.fileSizeFormatted != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                resource.fileSizeFormatted!,
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          if (resource.isFile) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showPreview(resource),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleResourceTap(resource),
                                icon: const Icon(Icons.download, size: 16),
                                label: Text(
                                  'Download',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (resource.isLink) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleResourceTap(resource),
                                icon: const Icon(
                                  FontAwesomeIcons.upRightFromSquare,
                                  size: 14,
                                ),
                                label: Text(
                                  'Open Link',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Uploader info
                      if (resource.uploaderName != null) ...[
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: isMobile ? 14 : 16,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Posted by: ${resource.uploaderName}',
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
