import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth/admin_auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class HodManagementScreen extends StatefulWidget {
  const HodManagementScreen({super.key});

  @override
  State<HodManagementScreen> createState() => _HodManagementScreenState();
}

class _HodManagementScreenState extends State<HodManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('HOD Management', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            'Review department HOD assignments and update head-of-department roles safely.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showRoleCreationDialog('hod'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create HOD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore.collection('user').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Unable to load HOD records. Please try again.',
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }

              final List<_UserRecord> users =
                  snapshot.data?.docs
                      .map(_UserRecord.fromFirestore)
                      .toList(growable: false) ??
                  <_UserRecord>[];

              final Set<String> departmentNames = <String>{};
              final Map<String, _UserRecord> hodByDept =
                  <String, _UserRecord>{};

              // Debug: Log raw user data
              debugPrint('[HOD] Total users fetched: ${users.length}');

              for (final _UserRecord user in users) {
                // Normalize and validate department
                final String deptRaw = user.dept.trim();
                
                // Skip users with invalid/empty departments
                if (deptRaw.isEmpty) {
                  debugPrint('[HOD] Skipping user ${user.id} - empty department');
                  continue;
                }

                debugPrint('[HOD] Processing user ${user.id}: dept="$deptRaw", isHod=${user.isHod}');
                departmentNames.add(deptRaw);

                if (user.isHod) {
                  hodByDept[deptRaw] = user;
                }
              }

              debugPrint('[HOD] Final departments collected: ${departmentNames.toList()..sort()}');

              final List<String> sortedDepartments = departmentNames.toList()
                ..sort((a, b) => a.compareTo(b));

              final List<_UserRecord> assignableUsers = users
                  .where((user) => !user.isHod)
                  .where((user) => user.name.isNotEmpty)
                  .where((user) => _isEligibleForHod(user.role))
                  .toList(growable: false);

              if (sortedDepartments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'No department data is available. HOD assignments will appear here once users have department values.',
                    style: AppTextStyles.bodySmall,
                  ),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 24,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool compact = constraints.maxWidth < 1080;

                    if (compact) {
                      return Column(
                        children: sortedDepartments
                            .map(
                              (dept) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HodCard(
                                  department: dept,
                                  hod: hodByDept[dept],
                                  assignableUsers: assignableUsers,
                                  onRemove: _removeHod,
                                  onAssign: _showAssignDialog,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    }

                    return Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: const <Widget>[
                              _HeaderCell(label: 'Department', flex: 2),
                              SizedBox(width: 16),
                              _HeaderCell(label: 'HOD Name', flex: 3),
                              SizedBox(width: 16),
                              _HeaderCell(label: 'Email', flex: 3),
                              SizedBox(width: 16),
                              _HeaderCell(label: 'Status', flex: 1),
                              SizedBox(width: 16),
                              _HeaderCell(label: 'Actions', flex: 3),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sortedDepartments.map(
                          (dept) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HodRow(
                              department: dept,
                              hod: hodByDept[dept],
                              assignableUsers: assignableUsers,
                              onRemove: _removeHod,
                              onAssign: _showAssignDialog,
                            ),
                          ),
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

  Future<void> _removeHod(_UserRecord hod) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Remove HOD'),
              content: Text(
                'Remove ${hod.name} as HOD for ${hod.dept}? This will keep the user account but change role to faculty.',
                style: AppTextStyles.bodySmall,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await _firestore.collection('user').doc(hod.id).update(<String, dynamic>{
        'role': 'faculty',
      });

      await _updateStudentsFacultyMentor(hod.dept, 'Not Assigned');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HOD removed successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to remove HOD. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _updateStudentsFacultyMentor(
    String department,
    String newMentorName,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> studentsSnapshot =
          await _firestore
              .collection('user')
              .where('dept', isEqualTo: department)
              .where('role', isEqualTo: 'student')
              .get();

      if (studentsSnapshot.docs.isEmpty) {
        return;
      }

      final WriteBatch batch = _firestore.batch();
      for (final DocumentSnapshot<Map<String, dynamic>> doc
          in studentsSnapshot.docs) {
        batch.update(doc.reference, <String, dynamic>{
          'facultyMentor': newMentorName,
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  Future<void> _showAssignDialog(
    String department,
    _UserRecord? currentHod,
    List<_UserRecord> candidates,
  ) async {
    if (candidates.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('No eligible users'),
            content: const Text(
              'There are no faculty users available to assign as HOD. Please add faculty users or ensure existing faculty are not already HOD.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String selectedId = candidates.first.id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign / Change HOD for $department'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (currentHod != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'Current HOD: ${currentHod.name} (${currentHod.email})',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final _UserRecord candidate = candidates[index];
                          return RadioListTile<String>(
                            title: Text(candidate.name),
                            subtitle: Text(
                              '${candidate.email} • ${candidate.roleLabel}',
                            ),
                            value: candidate.id,
                            groupValue: selectedId,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedId = value;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final _UserRecord selectedUser = candidates.firstWhere(
                      (user) => user.id == selectedId,
                      orElse: () => candidates.first,
                    );
                    Navigator.of(dialogContext).pop();
                    await _assignHod(department, currentHod, selectedUser);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _assignHod(
    String department,
    _UserRecord? currentHod,
    _UserRecord selectedUser,
  ) async {
    final WriteBatch batch = _firestore.batch();

    if (currentHod != null) {
      batch.update(
        _firestore.collection('user').doc(currentHod.id),
        <String, dynamic>{'role': 'faculty'},
      );
    }

    batch.update(
      _firestore.collection('user').doc(selectedUser.id),
      <String, dynamic>{'role': 'HOD', 'dept': department},
    );

    try {
      await batch.commit();

      await _updateStudentsFacultyMentor(department, selectedUser.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HOD assignment updated successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {}
    }
  }

  Future<void> _showRoleCreationDialog(String role) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController departmentController = TextEditingController();
    final TextEditingController employeeIdController = TextEditingController();
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Create HOD', style: AppTextStyles.sectionTitle),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _AdminInputField(
                          controller: nameController,
                          label: 'Full Name',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: emailController,
                          label: 'Email',
                          required: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: passwordController,
                          label: 'Password',
                          required: true,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: phoneController,
                          label: 'Phone Number',
                          required: true,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: departmentController,
                          label: 'Department',
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _AdminInputField(
                          controller: employeeIdController,
                          label: 'Employee ID',
                          required: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            await AdminAuthController.instance
                                .createManagedUser(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  role: role,
                                  phoneNumber: phoneController.text.trim(),
                                  department: departmentController.text.trim(),
                                  employeeId: employeeIdController.text.trim(),
                                );

                            if (!mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'HOD account created successfully.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } on AdminAuthException catch (error) {
                            setDialogState(() => saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.message),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Normalize department value. Returns empty string for null/empty input.
  /// NO FALLBACK to 'Unassigned' - invalid departments must be excluded.
  static String _normalizeDept(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized; // Return empty string for invalid departments
  }

  static bool _isEligibleForHod(String role) {
    if (role.isEmpty) return false;
    final String normalized = role.toLowerCase();
    return normalized == 'faculty' || normalized == 'hod';
  }
}

class _UserRecord {
  const _UserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dept,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String dept;

  bool get isHod => role.toLowerCase() == 'hod';
  String get roleLabel => role.isEmpty ? 'Unknown' : role;

  factory _UserRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return _UserRecord(
      id: doc.id,
      name: (data['name'] ?? data['fullName'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? '') as String,
      dept: (data['dept'] ?? data['department'] ?? '') as String,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.tableHeader.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? AppColors.coolSky : AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        side: primary
            ? null
            : BorderSide(color: AppColors.textSecondary.withOpacity(0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HodRow extends StatefulWidget {
  const _HodRow({
    required this.department,
    required this.hod,
    required this.assignableUsers,
    required this.onRemove,
    required this.onAssign,
  });

  final String department;
  final _UserRecord? hod;
  final List<_UserRecord> assignableUsers;
  final ValueChanged<_UserRecord> onRemove;
  final Future<void> Function(
    String department,
    _UserRecord? currentHod,
    List<_UserRecord> candidates,
  )
  onAssign;

  @override
  State<_HodRow> createState() => _HodRowState();
}

class _HodRowState extends State<_HodRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool hasHod = widget.hod != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.hover : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? AppColors.coolSky.withOpacity(0.18)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(flex: 2, child: _BodyText(widget.department)),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _BodyText(hasHod ? widget.hod!.name : 'Vacant'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _BodyText(hasHod ? widget.hod!.email : '—'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _StatusChip(
                label: hasHod ? 'Active' : 'Vacant',
                color: hasHod ? AppColors.aquamarine : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  if (hasHod) ...<Widget>[
                    _ActionButton(
                      label: 'Remove',
                      primary: false,
                      onPressed: () => widget.onRemove(widget.hod!),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _ActionButton(
                      label: 'Assign / Change',
                      primary: true,
                      onPressed: () => widget.onAssign(
                        widget.department,
                        widget.hod,
                        widget.assignableUsers,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HodCard extends StatelessWidget {
  const _HodCard({
    required this.department,
    required this.hod,
    required this.assignableUsers,
    required this.onRemove,
    required this.onAssign,
  });

  final String department;
  final _UserRecord? hod;
  final List<_UserRecord> assignableUsers;
  final ValueChanged<_UserRecord> onRemove;
  final Future<void> Function(
    String department,
    _UserRecord? currentHod,
    List<_UserRecord> candidates,
  )
  onAssign;

  @override
  Widget build(BuildContext context) {
    final bool hasHod = hod != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            department,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: _BodyText(hasHod ? hod!.name : 'Vacant')),
              const SizedBox(width: 12),
              Expanded(child: _BodyText(hasHod ? hod!.email : '—')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _StatusChip(
                label: hasHod ? 'Active' : 'Vacant',
                color: hasHod ? AppColors.aquamarine : AppColors.textSecondary,
              ),
              const Spacer(),
              if (hasHod) ...<Widget>[
                _ActionButton(
                  label: 'Remove',
                  primary: false,
                  onPressed: () => onRemove(hod!),
                ),
                const SizedBox(width: 10),
              ],
              _ActionButton(
                label: 'Assign / Change',
                primary: true,
                onPressed: () => onAssign(department, hod, assignableUsers),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminInputField extends StatelessWidget {
  const _AdminInputField({
    required this.controller,
    required this.label,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: required
          ? (value) =>
                (value ?? '').trim().isEmpty ? 'This field is required.' : null
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}
