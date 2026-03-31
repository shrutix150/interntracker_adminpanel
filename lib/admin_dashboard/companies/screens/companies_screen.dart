import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../widgets/companies_table.dart';
import '../widgets/company_detail_panel.dart';
import '../widgets/company_filter_bar.dart';
import '../widgets/company_stat_card.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CompanyStatus? _selectedStatus;
  String? _selectedIndustry;
  String? _selectedLocation;
  String _searchQuery = '';
  CompanyRecord? _selectedCompany;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CompanyRecord>>(
      stream: _firestore
          .collection('company')
          .snapshots()
          .map((snapshot) => snapshot.docs.map(CompanyRecord.fromFirestore).toList(growable: false)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StateCard(message: 'Unable to load companies. ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const _StateCard(message: 'Loading companies from Firebase...', loading: true);
        }

        final List<CompanyRecord> companies = snapshot.data!;
        final List<CompanyRecord> filteredCompanies = _filterCompanies(companies);
        final List<String> industryOptions = companies.map((e) => e.industry).where((e) => e.trim().isNotEmpty).toSet().toList()..sort();
        final List<String> locationOptions = companies.map((e) => e.experience).where((e) => e.trim().isNotEmpty).toSet().toList()..sort();

        _syncSelection(companies);

        final int totalCompanies = companies.length;
        final int activePartners = companies.where((e) => e.status == CompanyStatus.active || e.status == CompanyStatus.verified).length;
        final int studentsAssigned = companies.fold<int>(0, (sum, e) => sum + e.assignedStudents);
        final int pendingVerifications = companies.where((e) => e.status == CompanyStatus.pending).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showSidePanel = _selectedCompany != null && constraints.maxWidth >= 1240;
            final double contentMaxWidth = showSidePanel ? 860 : 1180;

            return Stack(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _Hero(
                                  activeCompanies: activePartners,
                                  onAddCompany: () => _openCompanyDialog(),
                                ),
                                const SizedBox(height: 22),
                                LayoutBuilder(
                                  builder: (context, statsConstraints) {
                                    final int columns = _resolveColumns(statsConstraints.maxWidth);
                                    final double spacing = 16;
                                    final double cardWidth = (statsConstraints.maxWidth - ((columns - 1) * spacing)) / columns;

                                    return Wrap(
                                      spacing: spacing,
                                      runSpacing: spacing,
                                      children: <Widget>[
                                        SizedBox(
                                          width: cardWidth,
                                          child: CompanyStatCard(
                                            title: 'Total Companies',
                                            value: '$totalCompanies',
                                            subtitle: 'Stored in Firebase',
                                            icon: Icons.business_rounded,
                                            accentColor: AppColors.coolSky,
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: CompanyStatCard(
                                            title: 'Active Partners',
                                            value: '$activePartners',
                                            subtitle: 'Active and verified',
                                            icon: Icons.handshake_rounded,
                                            accentColor: AppColors.aquamarine,
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: CompanyStatCard(
                                            title: 'Students Assigned',
                                            value: '$studentsAssigned',
                                            subtitle: 'Across all companies',
                                            icon: Icons.groups_rounded,
                                            accentColor: AppColors.jasmine,
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: CompanyStatCard(
                                            title: 'Pending Verifications',
                                            value: '$pendingVerifications',
                                            subtitle: 'Need admin review',
                                            icon: Icons.pending_actions_rounded,
                                            accentColor: AppColors.strawberryRed,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                CompanyFilterBar(
                                  selectedStatus: _selectedStatus,
                                  selectedIndustry: _selectedIndustry,
                                  selectedLocation: _selectedLocation,
                                  searchQuery: _searchQuery,
                                  industryOptions: industryOptions,
                                  locationOptions: locationOptions,
                                  onStatusChanged: (value) => setState(() => _selectedStatus = value),
                                  onIndustryChanged: (value) => setState(() => _selectedIndustry = value),
                                  onLocationChanged: (value) => setState(() => _selectedLocation = value),
                                  onSearchChanged: (value) => setState(() => _searchQuery = value),
                                  onReset: _resetFilters,
                                ),
                                const SizedBox(height: 22),
                                if (filteredCompanies.isEmpty)
                                  const _EmptyCard()
                                else
                                  CompaniesTable(
                                    companies: filteredCompanies,
                                    onView: _handleView,
                                    onEdit: _handleEdit,
                                    onVerify: _handleVerify,
                                    onDelete: _handleDelete,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showSidePanel) ...<Widget>[
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 390,
                        child: CompanyDetailPanel(
                          company: _selectedCompany!,
                          onClose: () => setState(() => _selectedCompany = null),
                          onEdit: _handleEdit,
                          onVerify: _handleVerify,
                        ),
                      ),
                    ],
                  ],
                ),
                if (_selectedCompany != null && !showSidePanel)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.overlay,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCompany = null),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth.clamp(320.0, 440.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CompanyDetailPanel(
                                company: _selectedCompany!,
                                onClose: () => setState(() => _selectedCompany = null),
                                onEdit: _handleEdit,
                                onVerify: _handleVerify,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  List<CompanyRecord> _filterCompanies(List<CompanyRecord> companies) {
    final String query = _searchQuery.trim().toLowerCase();
    return companies.where((company) {
      final bool statusMatches = _selectedStatus == null || company.status == _selectedStatus;
      final bool industryMatches = _selectedIndustry == null || company.industry == _selectedIndustry;
      final bool locationMatches = _selectedLocation == null || company.experience == _selectedLocation;
      final bool searchMatches = query.isEmpty ||
          company.name.toLowerCase().contains(query) ||
          company.contactEmail.toLowerCase().contains(query) ||
          company.phone.toLowerCase().contains(query) ||
          company.website.toLowerCase().contains(query) ||
          company.about.toLowerCase().contains(query);
      return statusMatches && industryMatches && locationMatches && searchMatches;
    }).toList(growable: false);
  }

  void _syncSelection(List<CompanyRecord> companies) {
    if (_selectedCompany == null) return;
    CompanyRecord? refreshedSelection;
    for (final CompanyRecord company in companies) {
      if (company.id == _selectedCompany!.id) {
        refreshedSelection = company;
        break;
      }
    }
    if (refreshedSelection == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedCompany = null);
        }
      });
      return;
    }
    if (refreshedSelection != _selectedCompany) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedCompany = refreshedSelection);
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedIndustry = null;
      _selectedLocation = null;
      _searchQuery = '';
    });
  }

  void _handleView(CompanyRecord company) {
    setState(() => _selectedCompany = company);
  }

  Future<void> _handleEdit(CompanyRecord company) async {
    await _openCompanyDialog(existingCompany: company);
  }

  Future<void> _handleVerify(CompanyRecord company) async {
    try {
      await _firestore.collection('company').doc(company.id).update(<String, dynamic>{
        'status': CompanyStatus.verified.label,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showMessage('Verified ${company.name}');
    } catch (error) {
      _showMessage('Unable to verify company. $error');
    }
  }

  void _handleDelete(CompanyRecord company) {
    // Delete action placeholder - UI only for now
  }

  Future<void> _openCompanyDialog({CompanyRecord? existingCompany}) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController name = TextEditingController(text: existingCompany?.name ?? '');
    final TextEditingController website = TextEditingController(text: existingCompany?.website ?? '');
    final TextEditingController email = TextEditingController(text: existingCompany?.contactEmail ?? '');
    final TextEditingController phone = TextEditingController(text: existingCompany?.phone ?? '');
    final TextEditingController industry = TextEditingController(text: existingCompany?.industry ?? '');
    final TextEditingController experience = TextEditingController(text: existingCompany?.experience ?? '');
    final TextEditingController internCount = TextEditingController(text: (existingCompany?.assignedStudents ?? 0).toString());
    final TextEditingController about = TextEditingController(text: existingCompany?.about ?? '');
    final TextEditingController courses = TextEditingController(text: existingCompany?.courses.join(', ') ?? '');
    final TextEditingController notes = TextEditingController(text: existingCompany?.notes ?? '');
    final TextEditingController preview = TextEditingController(text: existingCompany?.studentPreview.join(', ') ?? '');
    CompanyStatus selectedStatus = existingCompany?.status ?? CompanyStatus.pending;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingCompany == null ? 'Add Company' : 'Edit Company'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _Input(controller: name, label: 'Company Name', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: website, label: 'Website', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: email, label: 'Email', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: phone, label: 'Phone', required: true, number: true),
                        const SizedBox(height: 12),
                        _Input(controller: industry, label: 'Industry', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: experience, label: 'Experience', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: internCount, label: 'Intern Count', number: true, required: true),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CompanyStatus>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: CompanyStatus.values.map((status) => DropdownMenuItem<CompanyStatus>(value: status, child: Text(status.label))).toList(growable: false),
                          onChanged: saving ? null : (value) {
                            if (value != null) setDialogState(() => selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _Input(controller: courses, label: 'Courses (comma separated)', required: true),
                        const SizedBox(height: 12),
                        _Input(controller: about, label: 'About', maxLines: 3, required: true),
                        const SizedBox(height: 12),
                        _Input(controller: preview, label: 'Student Preview (comma separated)'),
                        const SizedBox(height: 12),
                        _Input(controller: notes, label: 'Notes', maxLines: 4),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    setDialogState(() => saving = true);
                    final Map<String, dynamic> payload = <String, dynamic>{
                      'name': name.text.trim(),
                      'about': about.text.trim(),
                      'courses': courses.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false),
                      'email': email.text.trim(),
                      'experience': experience.text.trim(),
                      'industry': industry.text.trim(),
                      'internCount': _toInt(internCount.text),
                      'phone': phone.text.trim(),
                      'website': website.text.trim(),
                      'contactEmail': email.text.trim(),
                      'assignedStudents': _toInt(internCount.text),
                      'activeInternships': _toInt(internCount.text),
                      'status': selectedStatus.label,
                      'studentPreview': preview.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false),
                      'notes': notes.text.trim(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    };
                    try {
                      if (existingCompany == null) {
                        payload['createdAt'] = FieldValue.serverTimestamp();
                        await _firestore.collection('company').add(payload);
                      } else {
                        await _firestore.collection('company').doc(existingCompany.id).update(payload);
                      }
                      if (!mounted) return;
                      Navigator.of(dialogContext).pop();
                      _showMessage(existingCompany == null ? 'Company added successfully' : 'Company updated successfully');
                    } catch (error) {
                      setDialogState(() => saving = false);
                      _showMessage('Unable to save company. $error');
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(existingCompany == null ? 'Add Company' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static int _resolveColumns(double width) {
    if (width >= 960) return 4;
    if (width >= 720) return 3;
    if (width >= 460) return 2;
    return 1;
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.activeCompanies, required this.onAddCompany});

  final int activeCompanies;
  final VoidCallback onAddCompany;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.coolSky.withOpacity(0.14),
            AppColors.jasmine.withOpacity(0.12),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surface.withOpacity(0.94)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.shadow, blurRadius: 28, offset: Offset(0, 16)),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Companies', style: AppTextStyles.display.copyWith(fontSize: 28, height: 1.1)),
                const SizedBox(height: 6),
                Text(
                  'Manage internship partners and add new companies directly to Firebase.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withOpacity(0.72), height: 1.45),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.84),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('$activeCompanies active partners', style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onAddCompany,
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Add Company'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message, this.loading = false});

  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 16)),
          ],
        ),
        child: Row(
          children: <Widget>[
            if (loading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4))
            else
              const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(message, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('No companies found. Add a company or adjust your filters.', style: AppTextStyles.body),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.label,
    this.required = false,
    this.number = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final bool number;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: number ? TextInputType.number : null,
      maxLines: maxLines,
      validator: required
          ? (value) => (value ?? '').trim().isEmpty ? 'This field is required.' : null
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}
