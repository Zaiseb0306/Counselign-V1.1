import 'package:flutter/material.dart';

class AcknowledgmentSection extends StatefulWidget {
  final bool consentRead;
  final bool consentAccept;
  final ValueChanged<bool> onConsentReadChanged;
  final ValueChanged<bool> onConsentAcceptChanged;
  final bool showError;

  const AcknowledgmentSection({
    super.key,
    required this.consentRead,
    required this.consentAccept,
    required this.onConsentReadChanged,
    required this.onConsentAcceptChanged,
    this.showError = false,
  });

  @override
  State<AcknowledgmentSection> createState() => _AcknowledgmentSectionState();
}

class _AcknowledgmentSectionState extends State<AcknowledgmentSection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: isMobile ? 15 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0A1875),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'ACKNOWLEDGEMENT',
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 2,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            color: const Color(0xFFE4E6EB),
          ),

          // Checkboxes Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              border: Border.all(color: const Color(0xFFE4E6EB), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // First Checkbox
                _buildCheckbox(
                  value: widget.consentRead,
                  onChanged: widget.onConsentReadChanged,
                  label:
                      'I have read and reviewed the content of this Counseling Informed Consent. I likewise understand the nature and scope of counseling, its terms and conditions, and the ethical principles of confidentiality including its limitation.',
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 12 : 16),

                // Second Checkbox
                _buildCheckbox(
                  value: widget.consentAccept,
                  onChanged: widget.onConsentAcceptChanged,
                  label: 'I accept this agreement and consent to counseling.',
                  isMobile: isMobile,
                ),
              ],
            ),
          ),

          // Error Message
          if (widget.showError)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                border: Border.all(color: const Color(0xFFFECACA), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please acknowledge both statements above to proceed with your appointment booking.',
                      style: TextStyle(
                        color: const Color(0xFFDC2626),
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: isMobile ? 1.0 : 1.1,
          child: Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            activeColor: const Color(0xFF060E57),
            checkColor: Colors.white,
            side: const BorderSide(color: Color(0xFF060E57), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                height: 1.6,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
