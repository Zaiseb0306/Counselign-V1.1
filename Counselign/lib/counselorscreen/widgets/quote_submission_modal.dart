import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../state/quote_viewmodel.dart';

class FloatingQuoteSubmissionModal extends StatefulWidget {
  final Quote? quoteToEdit;
  final VoidCallback? onSuccess;
  final VoidCallback? onClose;
  final VoidCallback? onOpenMyQuotes; // Add this new callback

  const FloatingQuoteSubmissionModal({
    super.key,
    this.quoteToEdit,
    this.onSuccess,
    this.onClose,
    this.onOpenMyQuotes, // Add this parameter
  });

  @override
  State<FloatingQuoteSubmissionModal> createState() =>
      _FloatingQuoteSubmissionModalState();
}

class _FloatingQuoteSubmissionModalState
    extends State<FloatingQuoteSubmissionModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quoteTextController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _sourceController = TextEditingController();
  String _selectedCategory = '';
  int _charCount = 0;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'Inspirational',
    'Motivational',
    'Wisdom',
    'Life',
    'Success',
    'Education',
    'Perseverance',
    'Courage',
    'Hope',
    'Kindness',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    if (widget.quoteToEdit != null) {
      _quoteTextController.text = widget.quoteToEdit!.quoteText;
      _authorNameController.text = widget.quoteToEdit!.authorName;
      _sourceController.text = widget.quoteToEdit!.source ?? '';
      _selectedCategory = widget.quoteToEdit!.category;
      _charCount = widget.quoteToEdit!.quoteText.length;
    }
    _quoteTextController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _quoteTextController.text.length;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quoteTextController.removeListener(_updateCharCount);
    _quoteTextController.dispose();
    _authorNameController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _closeModal() async {
    await _animationController.reverse();
    if (!mounted) return; // Guard mounted check

    if (widget.onClose != null) {
      widget.onClose!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Color _getCharCountColor() {
    if (_charCount > 450) return Colors.red;
    if (_charCount > 400) return Colors.orange;
    return const Color(0xFF060E57);
  }

  String _getCategoryIcon(String category) {
    const icons = {
      'Inspirational': '✨',
      'Motivational': '💪',
      'Wisdom': '🦉',
      'Life': '🌱',
      'Success': '🎯',
      'Education': '📚',
      'Perseverance': '🏔️',
      'Courage': '🦁',
      'Hope': '🌟',
      'Kindness': '💙',
    };
    return icons[category] ?? '📝';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      if (!mounted) return; // Guard mounted check
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSubmitting = true);

    if (!mounted) return; // Guard mounted check
    final viewModel = Provider.of<QuoteViewModel>(context, listen: false);
    final quote = Quote(
      id: widget.quoteToEdit?.id ?? 0,
      quoteText: _quoteTextController.text.trim(),
      authorName: _authorNameController.text.trim(),
      category: _selectedCategory,
      source: _sourceController.text.trim().isEmpty
          ? null
          : _sourceController.text.trim(),
      status: widget.quoteToEdit?.status ?? 'pending',
    );

    bool success;
    if (widget.quoteToEdit != null) {
      success = await viewModel.updateQuote(widget.quoteToEdit!.id, quote);
    } else {
      success = await viewModel.submitQuote(quote);
    }

    if (!mounted) return; // Guard mounted check
    setState(() => _isSubmitting = false);

    if (!mounted) return; // Guard mounted check

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.quoteToEdit != null
                ? 'Quote updated successfully!'
                : 'Quote submitted successfully!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      await _animationController.reverse();
      if (!mounted) return; // Guard mounted check

      if (widget.onClose != null) {
        widget.onClose!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                (widget.quoteToEdit != null
                    ? 'Failed to update quote'
                    : 'Failed to submit quote'),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isMobile = screenWidth < 600;

    // Calculate modal dimensions - adjust height based on keyboard
    final modalWidth = isMobile
        ? screenWidth * 0.95
        : (screenWidth > 800 ? 600.0 : screenWidth * 0.85);

    // Dynamic height calculation that responds to keyboard
    // Use more aggressive height reduction when keyboard is open
    final availableHeight =
        screenHeight - keyboardHeight - (keyboardHeight > 0 ? 20 : 0);
    final modalHeight = keyboardHeight > 0
        ? availableHeight *
              0.95 // Use more space when keyboard is open
        : availableHeight * 0.85; // Normal size when keyboard is closed

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withValues(
          alpha: 0.5,
        ), // Fixed: withOpacity -> withValues
        child: GestureDetector(
          onTap: _closeModal,
          child: Align(
            alignment: keyboardHeight > 0
                ? Alignment.topCenter
                : Alignment.center,
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside modal
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: modalWidth,
                  height: modalHeight,
                  margin: EdgeInsets.only(top: keyboardHeight > 0 ? 20 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.3,
                        ), // Fixed: withOpacity -> withValues
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF060E57), Color(0xFF0A1875)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.quoteToEdit != null
                                    ? 'Edit Quote'
                                    : 'Share a Daily Quote',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _closeModal,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content - with proper keyboard handling
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 20 : 24),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Inspire students by submitting motivational quotes. Your submissions will be reviewed by admins before being displayed.',
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 14,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Quote Text
                                Text(
                                  'Quote *',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _quoteTextController,
                                  maxLines: 4,
                                  maxLength: 500,
                                  decoration: InputDecoration(
                                    hintText: 'Enter an inspirational quote...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF060E57),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Quote text is required';
                                    }
                                    if (value.trim().length < 10) {
                                      return 'Quote must be at least 10 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Share wisdom that inspires and motivates',
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '$_charCount/500',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getCharCountColor(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Author Name
                                Text(
                                  'Author *',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _authorNameController,
                                  maxLength: 255,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Maya Angelou',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF060E57),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Author name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Category
                                Text(
                                  'Category *',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: _selectedCategory.isEmpty
                                      ? null
                                      : _selectedCategory,
                                  decoration: InputDecoration(
                                    hintText: 'Select a category',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF060E57),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: _categories.map((category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(
                                        '${_getCategoryIcon(category)} $category',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value ?? '';
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Category is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Source (Optional)
                                Text(
                                  'Source (Optional)',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _sourceController,
                                  maxLength: 255,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Book title, Speech, Movie',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF060E57),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Where this quote is from (optional)',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                // Add extra space at bottom for better scrolling with keyboard
                                SizedBox(height: keyboardHeight > 0 ? 200 : 24),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Footer
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // My Submissions button on the left
                            OutlinedButton.icon(
                              onPressed: () async {
                                // Store the callback before async operations
                                final onOpenMyQuotesCallback =
                                    widget.onOpenMyQuotes;

                                // Close current modal with animation
                                await _animationController.reverse();
                                if (!context.mounted) {
                                  return; // Guard mounted check
                                }

                                // Store context before async gap
                                final navigator = Navigator.of(context);

                                // Pop the current modal
                                if (navigator.canPop()) {
                                  navigator.pop();
                                }

                                // Call the callback immediately without Future.delayed
                                // The delay was minimal anyway and not critical
                                if (onOpenMyQuotesCallback != null) {
                                  onOpenMyQuotesCallback();
                                }
                              },
                              icon: const Icon(Icons.history, size: 16),
                              label: const Text('My Submissions'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            // Submit button on the right
                            ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      widget.quoteToEdit != null
                                          ? Icons.save
                                          : Icons.send,
                                      size: 16,
                                    ),
                              label: Text(
                                _isSubmitting
                                    ? (widget.quoteToEdit != null
                                          ? 'Updating...'
                                          : 'Submitting...')
                                    : (widget.quoteToEdit != null
                                          ? 'Update Quote'
                                          : 'Submit Quote'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF060E57),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
