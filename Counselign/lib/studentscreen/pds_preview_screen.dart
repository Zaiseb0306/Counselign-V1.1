import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/config.dart';
import '../utils/session.dart';

class PdsPreviewScreen extends StatefulWidget {
  final String previewUrl;
  final String baseUrl;

  const PdsPreviewScreen({
    super.key,
    required this.previewUrl,
    required this.baseUrl,
  });

  @override
  State<PdsPreviewScreen> createState() => _PdsPreviewScreenState();
}

class _PdsPreviewScreenState extends State<PdsPreviewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isControllerReady = false;
  String? _errorMessage;
  String? _sessionCookie;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller after first frame to ensure platform is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
    // Load preview content immediately
    _loadPreview();
  }

  void _initializeController() {
    try {
      // Desktop user agent to trigger desktop site rendering for highest quality
      const desktopUserAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setUserAgent(desktopUserAgent)
        ..addJavaScriptChannel(
          'FlutterDownload',
          onMessageReceived: (JavaScriptMessage message) {
            debugPrint(
              'PDS Preview - Received message from JavaScript: ${message.message}',
            );
            try {
              final data = jsonDecode(message.message) as Map<String, dynamic>;
              final filename = data['filename'] as String? ?? 'PDS.pdf';
              final base64Data = data['data'] as String?;
              if (base64Data != null) {
                _savePdfFromBase64(base64Data, filename);
              }
            } catch (e) {
              debugPrint('Error parsing JavaScript message: $e');
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              debugPrint('PDS Preview - Page started loading: $url');
            },
            onPageFinished: (url) {
              debugPrint('PDS Preview - Page finished loading: $url');
              if (mounted) {
                setState(() => _isLoading = false);
              }
              // Inject JavaScript to force desktop mode and intercept PDF downloads
              // Wait a bit for page to be fully loaded
              Future.delayed(const Duration(milliseconds: 500), () {
                _forceDesktopMode();
                _injectDownloadHandler();
              });
            },
            onWebResourceError: (error) {
              debugPrint('PDS Preview WebView error: ${error.description}');
              debugPrint('PDS Preview WebView error code: ${error.errorCode}');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Intercept custom download URL scheme
              if (request.url.startsWith('flutter://downloadpdf')) {
                debugPrint(
                  'PDS Preview - Intercepted PDF download: ${request.url}',
                );
                _handleDownload(request.url);
                return NavigationDecision.prevent;
              }
              // Intercept regular PDF downloads
              if (request.url.endsWith('.pdf') ||
                  (request.url.contains('download') &&
                      request.url.contains('pdf'))) {
                debugPrint(
                  'PDS Preview - Intercepted PDF download URL: ${request.url}',
                );
                _handleDownload(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        );

      if (mounted) {
        setState(() {
          _isControllerReady = true;
        });

        // If session cookie is ready, load the URL
        if (_sessionCookie != null) {
          _loadUrlIntoWebView();
        }
      }
    } catch (e) {
      debugPrint('Error initializing WebView controller: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Unable to initialize preview. Please try again in a moment.';
        });
      }
    }
  }

  Future<void> _forceDesktopMode() async {
    if (_controller == null) return;

    try {
      // Inject JavaScript to force desktop viewport and rendering
      await _controller!.runJavaScript('''
        (function() {
          console.log('PDS Preview - Forcing desktop mode');
          
          // Force desktop viewport
          const viewport = document.querySelector('meta[name="viewport"]');
          if (viewport) {
            viewport.setAttribute('content', 'width=1000, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes');
          } else {
            const meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=1000, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
            document.getElementsByTagName('head')[0].appendChild(meta);
          }
          
          // Force desktop width on body
          document.body.style.minWidth = '1000px';
          document.body.style.width = '100%';
          
          // Ensure container uses desktop layout
          const containers = document.querySelectorAll('.container, .pds-container, .page-container');
          containers.forEach(function(container) {
            container.style.minWidth = '1000px';
            container.style.maxWidth = 'none';
          });
          
          console.log('PDS Preview - Desktop mode forced');
        })();
      ''');
      debugPrint('PDS Preview - Desktop mode JavaScript injected');
    } catch (e) {
      debugPrint('PDS Preview - Error forcing desktop mode: $e');
    }
  }

  Future<void> _injectDownloadHandler() async {
    if (_controller == null) return;

    try {
      // Inject JavaScript to intercept PDF downloads and send to Flutter
      // This will override jsPDF's save method to capture PDF data
      await _controller!.runJavaScript('''
        (function() {
          console.log('PDS Preview - Download handler injection started');
          
          // Function to setup jsPDF override
          function setupJsPDFOverride() {
            if (window.jspdf && window.jspdf.jsPDF) {
              console.log('PDS Preview - jsPDF found, setting up override');
              const OriginalJsPDF = window.jspdf.jsPDF;
              
              // Override the jsPDF constructor
              window.jspdf.jsPDF = function(options) {
                const pdf = new OriginalJsPDF(options);
                const originalSave = pdf.save.bind(pdf);
                
                // Override the save method
                pdf.save = function(filename) {
                  try {
                    console.log('PDS Preview - PDF save intercepted, filename:', filename);
                    
                    // Get PDF as base64
                    const pdfBase64 = pdf.output('datauristring');
                    const base64Data = pdfBase64.split(',')[1];
                    
                    console.log('PDS Preview - PDF data extracted, length:', base64Data ? base64Data.length : 0);
                    
                    // Send to Flutter via JavaScript channel
                    if (window.FlutterDownload) {
                      const message = JSON.stringify({
                        filename: filename || 'PDS.pdf',
                        data: base64Data
                      });
                      console.log('PDS Preview - Sending PDF to Flutter, message length:', message.length);
                      window.FlutterDownload.postMessage(message);
                      console.log('PDS Preview - PDF data sent to Flutter successfully');
                    } else {
                      console.error('PDS Preview - FlutterDownload channel not available, using fallback');
                      // Fallback to original save
                      originalSave(filename);
                    }
                  } catch (e) {
                    console.error('PDS Preview - Error in save override:', e, e.stack);
                    // Fallback to original save on error
                    originalSave(filename);
                  }
                };
                
                return pdf;
              };
              console.log('PDS Preview - jsPDF override setup complete');
              return true;
            }
            return false;
          }
          
          // Try to setup immediately
          if (!setupJsPDFOverride()) {
            console.log('PDS Preview - jsPDF not ready, will retry');
            // Retry after a delay if jsPDF isn't ready yet
            setTimeout(function() {
              if (!setupJsPDFOverride()) {
                console.error('PDS Preview - Failed to setup jsPDF override after retry');
              }
            }, 1000);
          }
          
          // Also override the downloadPDF function if it exists
          if (typeof window.downloadPDF === 'function') {
            console.log('PDS Preview - downloadPDF function found, wrapping it');
            const originalDownloadPDF = window.downloadPDF;
            window.downloadPDF = async function() {
              try {
                console.log('PDS Preview - downloadPDF function called');
                // Call original function - it will use our overridden save method
                await originalDownloadPDF();
              } catch (e) {
                console.error('PDS Preview - Error in downloadPDF:', e, e.stack);
              }
            };
          } else {
            console.log('PDS Preview - downloadPDF function not found yet');
          }
        })();
      ''');
      debugPrint(
        'PDS Preview - Download handler JavaScript injected successfully',
      );
    } catch (e) {
      debugPrint('PDS Preview - Error injecting download handler: $e');
    }
  }

  Future<void> _handleDownload(String url) async {
    // Check if this is our custom download URL
    if (url.startsWith('flutter://downloadpdf')) {
      final uri = Uri.parse(url);
      final filename = uri.queryParameters['filename'] ?? 'PDS.pdf';
      final base64Data = uri.queryParameters['data'];

      if (base64Data != null) {
        await _savePdfFromBase64(base64Data, filename);
        return;
      }
    }

    // Handle regular URL downloads
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final session = Session();
      await session.initialize();

      final response = await session.get(url);

      if (response.statusCode == 200) {
        final filename = url.split('/').last;
        if (filename.isEmpty || !filename.endsWith('.pdf')) {
          await _savePdfFromBytes(
            response.bodyBytes,
            'PDS_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
        } else {
          await _savePdfFromBytes(response.bodyBytes, filename);
        }
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _savePdfFromBase64(String base64Data, String filename) async {
    try {
      final bytes = base64Decode(base64Data);
      await _savePdfFromBytes(bytes, filename);
    } catch (e) {
      debugPrint('Error decoding base64 PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePdfFromBytes(List<int> bytes, String filename) async {
    try {
      // Get Downloads directory
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        // Try Android Downloads directory
        try {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = Directory('/storage/emulated/0/Downloads');
          }
        } catch (e) {
          debugPrint('Could not access Android Downloads: $e');
        }

        // Fallback to external storage
        if (downloadsDir == null || !await downloadsDir.exists()) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            downloadsDir = Directory('${externalDir.parent.path}/Download');
            if (!await downloadsDir.exists()) {
              downloadsDir = Directory('${externalDir.parent.path}/Downloads');
            }
          }
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      // Final fallback
      if (downloadsDir == null || !await downloadsDir.exists()) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Save file
      final file = File('${downloadsDir.path}/$filename');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads: $filename'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () async {
                final result = await OpenFile.open(file.path);
                if (result.type != ResultType.done && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: ${result.message}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUrlIntoWebView() async {
    if (_controller == null || _sessionCookie == null) {
      return;
    }

    try {
      final cookieManager = WebViewCookieManager();
      final uri = Uri.parse(widget.previewUrl);

      // Set the session cookie for the domain
      await cookieManager.setCookie(
        WebViewCookie(
          name: 'ci_session',
          value: _sessionCookie!,
          domain: uri.host,
          path: '/',
        ),
      );

      debugPrint('PDS Preview - Cookie set, loading URL: ${uri.toString()}');

      await _controller!.loadRequest(uri);
    } catch (e) {
      debugPrint('Error loading URL into WebView: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load preview content. Please try again.';
        });
      }
    }
  }

  Future<void> _loadPreview() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final session = Session();
    await session.initialize();

    // Get the session cookie
    final sessionCookie = session.cookies['ci_session'];

    if (sessionCookie == null || sessionCookie.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
      }
      return;
    }

    // Store session cookie for WebView loading
    _sessionCookie = sessionCookie;

    // If controller is ready, load URL immediately
    // Otherwise, it will be loaded when controller is initialized
    if (_isControllerReady && _controller != null) {
      await _loadUrlIntoWebView();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDS Preview', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF060E57),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _sessionCookie = null;
                      });
                      _loadPreview();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_controller != null && _isControllerReady)
            WebViewWidget(controller: _controller!)
          else
            const Center(child: CircularProgressIndicator()),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
