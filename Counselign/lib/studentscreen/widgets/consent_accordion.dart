import 'package:flutter/material.dart';

class ConsentAccordion extends StatefulWidget {
  const ConsentAccordion({super.key});

  @override
  State<ConsentAccordion> createState() => _ConsentAccordionState();
}

class _ConsentAccordionState extends State<ConsentAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: isMobile ? 15 : 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isExpanded
              ? const Color(0xFF060E57).withValues(alpha: 0.3)
              : const Color(0xFFE4E6EB),
          width: _isExpanded ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? const Color(0xFF060E57).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: _isExpanded ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 20,
            vertical: isMobile ? 12 : 16,
          ),
          childrenPadding: EdgeInsets.all(isMobile ? 10 : 24),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Container(
            
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isExpanded
                    ? [const Color(0xFF0A1875), const Color(0xFF1e3799)]
                    : [const Color(0xFF060E57), const Color(0xFF0A1875)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description, color: Colors.white, size: 18),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counseling Informed Consent Form',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      if (!_isExpanded)
                        Text(
                          'Tap to view terms and conditions',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFD),
                border: Border(
                  top: BorderSide(color: Color(0xFFE4E6EB), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction
                  _buildConsentIntro(isMobile),
                  const SizedBox(height: 24),

                  // The Right of Informed Consent
                  _buildConsentSection(
                    icon: Icons.gavel,
                    title: 'THE RIGHT OF INFORMED CONSENT',
                    content:
                        'The clients have the right to decide whether to enter into a counseling relationship with the specific counselor and must be told what to expect (Villar, 2009).',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),

                  // Counseling
                  _buildConsentSection(
                    icon: Icons.handshake,
                    title: 'COUNSELING',
                    content:
                        'It is a collaborative effort between the counselor and client. Professional counselors help clients identify goals and potential solutions to problems which cause emotional turmoil; seek to improve communication and coping skills; strengthen self-esteem; and promote behavior change and optimal mental health (American Counseling Association, 2021).',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),

                  // Terms and Conditions
                  _buildTermsAndConditions(isMobile),
                  const SizedBox(height: 24),

                  // Dimensions of Confidentiality
                  _buildConfidentialitySection(isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentIntro(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE4E6EB), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This form intends to ask the consent of the client to undergo counseling session(s) with a Registered Guidance Counselor (RGC) from Guidance and Counseling Services. This also stipulates the nature and scope of counseling, key elements of confidentiality, and the rights and responsibilities of the client and counselor.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              height: 1.6,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF060E57).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFF060E57), width: 4),
              ),
            ),
            child: Text(
              'Please feel free to speak with the counselor for any clarifications regarding this form.',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF060E57),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentSection({
    required IconData icon,
    required String title,
    required String content,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF0A1875),
              size: isMobile ? 14 : 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          color: const Color(0xFFE4E6EB),
        ),
        Text(
          content,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, color: Color(0xFF0A1875), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'TERMS AND CONDITIONS:',
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          color: const Color(0xFFE4E6EB),
        ),
        _buildTermsList(isMobile),
      ],
    );
  }

  Widget _buildTermsList(bool isMobile) {
    final terms = [
      'The client will share information about his or her problems or issues to the counselor that may have affected certain areas of his or her life.',
      'The client may ask questions before, during, and after the counseling session (s) if there are things unclear to her or him.',
      'The counselor will guide the session and may ask probing questions to better understand the:',
      'Both the client and the counselor have the right not to continue the counseling sessions without any impediment unless required by specific authority.',
      'In case of termination, both client and counselor have the responsibility to notify each party on the reason for dismissing the sessions for record purposes.',
      'Virtual/electronic counseling sessions may experience privacy and other technical glitches.',
      'All information provided in this form and during counseling will be kept strictly confidential except for reasons cited in the dimensions of confidentiality.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: terms.asMap().entries.map((entry) {
        final index = entry.key;
        final term = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: const Color(0xFF060E57),
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        height: 1.6,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    if (index ==
                        2) // Special handling for the third term with sub-list
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '◦',
                                  style: TextStyle(
                                    color: const Color(0xFF0A1875),
                                    fontSize: isMobile ? 12 : 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'specific or various concerns of the client re: personal, academic, emotional, psychological, occupational, spiritual, etc.',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13,
                                      height: 1.5,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfidentialitySection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF0A1875), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'DIMENSIONS OF CONFIDENTIALITY',
                style: TextStyle(
                  color: const Color(0xFF060E57),
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          color: const Color(0xFFE4E6EB),
        ),
        Text(
          'The clients have a right to know that the counselor may be discussing certain details of the relationship with a supervisor or a colleague. Moreover, there are times when confidential information must be divulged and there are exemptions.',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Arthur and Swanson (1993) note exemptions cited by Bisell and Royce (1992) to the ethical principle of confidentiality:',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            height: 1.6,
            color: const Color(0xFF374151),
          ),
        ),
        _buildExemptionsList(isMobile),
      ],
    );
  }

  Widget _buildExemptionsList(bool isMobile) {
    final exemptions = [
      {
        'title': 'The client is a danger to self or others.',
        'description':
            'The law places physical safety above considerations of confidentiality or the right of privacy. Protection of the person takes precedence and includes the duty to warn.',
      },
      {
        'title': 'The client requests the release of information.',
        'description':
            'Privacy belongs to the client and may be waived. The counselor should release information as requested by the client.',
      },
      {
        'title': 'A court orders release of information.',
        'description':
            'The responsibility under the law for the counselor to maintain confidentiality is overridden when the court determines that the information is needed to serve the cause of justice.',
      },
      {
        'title': 'The counselor is receiving systematic clinical supervision.',
        'description':
            'The client gives up the right to confidentiality when it is known that session material will be used during supervision.',
      },
      {
        'title': 'Clients are below the age of 18.',
        'description':
            'Parents or guardians have the legal right to communication between the minor and the counselor.',
      },
      {
        'title': 'The counselor has reason to suspect child abuse.',
        'description':
            'All states now legally require the reporting of suspected abuse.',
      },
    ];

    return Column(
      children: exemptions.map((exemption) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF060E57).withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: const Border(
              left: BorderSide(color: Color(0xFF060E57), width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exemption['title']!,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF060E57),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exemption['description']!,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  height: 1.6,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
