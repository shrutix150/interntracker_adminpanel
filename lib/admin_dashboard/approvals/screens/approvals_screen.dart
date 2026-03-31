import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/approval_model.dart';
import '../widgets/approval_detail_panel.dart';
import '../widgets/approval_filter_bar.dart';
import '../widgets/approvals_table.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ApprovalRole? _selectedRole;
  String? _selectedDepartment;
  ApprovalStatus? _selectedStatus;
  String _searchQuery = '';
  ApprovalRequest? _selectedRequest;
  String? _busyRequestId;

  Stream<List<ApprovalRequest>> get _pendingApprovalsStream {
    return _firestore
        .collection('user')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ApprovalRequest.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ApprovalRequest>>(
      stream: _pendingApprovalsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _ApprovalsStateCard(
            message: 'Unable to load pending approvals right now.',
            icon: Icons.error_outline_rounded,
          );
        }

        if (!snapshot.hasData) {
          return const _ApprovalsStateCard(
            message: 'Loading pending approval requests...',
            icon: Icons.hourglass_top_rounded,
            showLoader: true,
          );
        }

        final List<ApprovalRequest> requests = snapshot.data!;
        final List<String> departmentOptions = requests
            .map((request) => request.department)
            .where((department) => department.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final List<ApprovalRequest> filteredRequests = _applyFilters(requests);

        _syncSelection(filteredRequests);

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool showSidePanel =
                _selectedRequest != null && constraints.maxWidth >= 1180;
            final double contentMaxWidth = showSidePanel ? 920 : 1180;

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
                                _PageHeader(pendingCount: requests.length),
                                const SizedBox(height: 18),
                                ApprovalFilterBar(
                                  selectedRole: _selectedRole,
                                  selectedDepartment: _selectedDepartment,
                                  selectedStatus: _selectedStatus,
                                  searchQuery: _searchQuery,
                                  departmentOptions: departmentOptions,
                                  onRoleChanged: (role) {
                                    setState(() => _selectedRole = role);
                                  },
                                  onDepartmentChanged: (department) {
                                    setState(
                                      () => _selectedDepartment = department,
                                    );
                                  },
                                  onStatusChanged: (status) {
                                    setState(() => _selectedStatus = status);
                                  },
                                  onSearchChanged: (query) {
                                    setState(() => _searchQuery = query);
                                  },
                                  onReset: _resetFilters,
                                ),
                                const SizedBox(height: 18),
                                ApprovalsTable(
                                  requests: filteredRequests,
                                  busyRequestId: _busyRequestId,
                                  onView: _handleView,
                                  onApprove: _handleApprove,
                                  onReject: _handleReject,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showSidePanel) ...<Widget>[
                      const SizedBox(width: 20),
                      _PanelEntrance(
                        child: SizedBox(
                          width: 380,
                          child: ApprovalDetailPanel(
                            request: _selectedRequest!,
                            isBusy: _busyRequestId == _selectedRequest!.id,
                            onClose: () =>
                                setState(() => _selectedRequest = null),
                            onApprove: _handleApprove,
                            onReject: _handleReject,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_selectedRequest != null && !showSidePanel)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.overlay,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedRequest = null),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          _PanelEntrance(
                            child: SizedBox(
                              width: constraints.maxWidth.clamp(320.0, 440.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ApprovalDetailPanel(
                                  request: _selectedRequest!,
                                  isBusy:
                                      _busyRequestId == _selectedRequest!.id,
                                  onClose: () => setState(
                                    () => _selectedRequest = null,
                                  ),
                                  onApprove: _handleApprove,
                                  onReject: _handleReject,
                                ),
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

  List<ApprovalRequest> _applyFilters(List<ApprovalRequest> requests) {
    return requests.where((request) {
      final bool roleMatches =
          _selectedRole == null || request.role == _selectedRole;
      final bool departmentMatches =
          _selectedDepartment == null ||
          request.department == _selectedDepartment;
      final bool statusMatches =
          _selectedStatus == null || request.status == _selectedStatus;
      final String query = _searchQuery.trim().toLowerCase();
      final bool searchMatches =
          query.isEmpty ||
          request.name.toLowerCase().contains(query) ||
          request.email.toLowerCase().contains(query) ||
          request.requestType.toLowerCase().contains(query);

      return roleMatches &&
          departmentMatches &&
          statusMatches &&
          searchMatches;
    }).toList(growable: false);
  }

  void _syncSelection(List<ApprovalRequest> requests) {
    if (_selectedRequest == null) {
      return;
    }

    ApprovalRequest? refreshedSelection;
    for (final ApprovalRequest request in requests) {
      if (request.id == _selectedRequest!.id) {
        refreshedSelection = request;
        break;
      }
    }

    if (refreshedSelection == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedRequest = null);
        }
      });
      return;
    }

    if (refreshedSelection != _selectedRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedRequest = refreshedSelection);
        }
      });
    }
  }

  void _handleView(ApprovalRequest request) {
    setState(() {
      _selectedRequest = request;
    });
  }

  Future<void> _handleApprove(ApprovalRequest request) async {
    await _updateRequest(
      request: request,
      payload: <String, dynamic>{
        'isApproved': true,
        'status': 'Approved',
      },
      successMessage: '${request.name} approved successfully.',
    );
  }

  Future<void> _handleReject(ApprovalRequest request) async {
    await _updateRequest(
      request: request,
      payload: <String, dynamic>{
        'isApproved': false,
        'status': 'Rejected',
      },
      successMessage: '${request.name} marked as rejected.',
    );
  }

  Future<void> _updateRequest({
    required ApprovalRequest request,
    required Map<String, dynamic> payload,
    required String successMessage,
  }) async {
    setState(() => _busyRequestId = request.id);

    try {
      await _firestore.collection('user').doc(request.id).update(payload);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while updating the request.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyRequestId = null);
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedRole = null;
      _selectedDepartment = null;
      _selectedStatus = null;
      _searchQuery = '';
    });
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 24,
        vertical: compact ? 20 : 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withOpacity(0.18),
            AppColors.coolSky.withOpacity(0.12),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surface.withOpacity(0.94)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Approvals',
                  style: AppTextStyles.display.copyWith(
                    fontSize: compact ? 26 : 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review and approve pending users from the live Firebase queue.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.84),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Pending queue',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount requests',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelEntrance extends StatelessWidget {
  const _PanelEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 28, 0),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _ApprovalsStateCard extends StatelessWidget {
  const _ApprovalsStateCard({
    required this.message,
    required this.icon,
    this.showLoader = false,
  });

  final String message;
  final IconData icon;
  final bool showLoader;

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
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 6,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 18),
            if (showLoader) ...<Widget>[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(width: 14),
            ] else ...<Widget>[
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
