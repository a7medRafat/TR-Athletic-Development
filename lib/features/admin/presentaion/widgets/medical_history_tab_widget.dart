import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../features/register/data/models/medical_models.dart';
import 'session_card_widget.dart';

// data key (English, as stored in Firestore) → translation key — mirrors the
// lookup maps in register_medical_step.dart so stored values display localized.
const _muscleGroups = {
  'Quadriceps': 'mg_quadriceps',
  'Quadriceps Origin': 'mg_quadriceps_origin',
  'Hamstring': 'mg_hamstring',
  'Adductor': 'mg_adductor',
  'Calf': 'mg_calf',
  'Lower Back': 'mg_lower_back',
  'Lower Abdominal': 'mg_lower_abdominal',
};

const _jointTypes = {
  'ACL': 'jt_acl',
  'PCL': 'jt_pcl',
  'MCL': 'jt_mcl',
  'LCL': 'jt_lcl',
  'Meniscus': 'jt_meniscus',
  'Ankle Sprain': 'jt_ankle_sprain',
  'Shoulder Dislocation': 'jt_shoulder',
  'Other': 'jt_other',
};

const _sides = {'Right': 'side_right', 'Left': 'side_left', 'Both': 'side_both'};

const _grades = {
  'Grade 1': 'grade_1',
  'Grade 2': 'grade_2',
  'Grade 3': 'grade_3',
};

const _surgeryStatuses = {
  'Fully Recovered': 'status_fully_recovered',
  'Ongoing Rehab': 'status_ongoing_rehab',
  'Limited Activity': 'status_limited',
  'Unknown': 'status_unknown',
};

const _monthAbbr = [
  'Jan','Feb','Mar','Apr','May','Jun',
  'Jul','Aug','Sep','Oct','Nov','Dec',
];

String _fmtDate(DateTime? d) =>
    d == null ? '—' : '${_monthAbbr[d.month - 1]} ${d.day}, ${d.year}';

String _label(Map<String, String> table, String? key) =>
    key == null ? '—' : (table[key] ?? key).tr();

// ── Entry point ───────────────────────────────────────────────────────────────

class MedicalHistoryTabWidget extends StatelessWidget {
  final MedicalHistory? medicalHistory;

  const MedicalHistoryTabWidget({super.key, required this.medicalHistory});

  @override
  Widget build(BuildContext context) {
    final history = medicalHistory;
    if (history == null || !history.hasData) {
      return AppEmptyState(
        message: AppStrings.noMedicalHistory,
        icon: Icons.health_and_safety_outlined,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RiskBanner(risk: history.riskProfile),
          SizedBox(height: 14.h),
          _CurrentStatusRow(history: history),
          SizedBox(height: 20.h),
          _Section(
            title: AppStrings.medicalPrevMuscle,
            count: history.muscleInjuries.length,
            child: history.muscleInjuries.isEmpty
                ? const _NoneRow()
                : Column(
                    children: history.muscleInjuries
                        .map((e) => _MuscleInjuryCard(entry: e))
                        .toList(),
                  ),
          ),
          SizedBox(height: 20.h),
          _Section(
            title: AppStrings.medicalPrevJoint,
            count: history.jointInjuries.length,
            child: history.jointInjuries.isEmpty
                ? const _NoneRow()
                : Column(
                    children: history.jointInjuries
                        .map((e) => _JointInjuryCard(entry: e))
                        .toList(),
                  ),
          ),
          SizedBox(height: 20.h),
          _Section(
            title: AppStrings.medicalSurgeryHist,
            count: history.surgeries.length,
            child: history.surgeries.isEmpty
                ? const _NoneRow()
                : Column(
                    children:
                        history.surgeries.map((e) => _SurgeryCard(entry: e)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Risk profile banner ────────────────────────────────────────────────────────

class _RiskBanner extends StatelessWidget {
  final String risk; // 'Low' | 'Moderate' | 'High'

  const _RiskBanner({required this.risk});

  Color get _color {
    switch (risk) {
      case 'High':
        return AppColors.error;
      case 'Moderate':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String get _text {
    switch (risk) {
      case 'High':
        return AppStrings.riskHigh;
      case 'Moderate':
        return AppStrings.riskModerate;
      default:
        return AppStrings.riskLow;
    }
  }

  IconData get _icon {
    switch (risk) {
      case 'High':
        return Icons.dangerous_rounded;
      case 'Moderate':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.riskProfile,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  _text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
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

// ── Current status flags ──────────────────────────────────────────────────────

class _CurrentStatusRow extends StatelessWidget {
  final MedicalHistory history;

  const _CurrentStatusRow({required this.history});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusFlag(
            label: AppStrings.medicalCurrentPain,
            active: history.currentPain,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatusFlag(
            label: AppStrings.medicalChronicInjury,
            active: history.chronicInjury,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _StatusFlag(
            label: AppStrings.medicalMedications,
            active: history.medications,
          ),
        ),
      ],
    );
  }
}

class _StatusFlag extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusFlag({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.error : AppColors.success;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            active ? Icons.error_rounded : Icons.check_circle_rounded,
            size: 18.sp,
            color: color,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            active ? AppStrings.yes : AppStrings.no,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final int count;
  final Widget child;

  const _Section({required this.title, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 10.h),
        child,
      ],
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.noneReported,
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColors.textHint,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

// ── Entry cards ────────────────────────────────────────────────────────────────

Color _muscleSeverityColor(MuscleInjuryEntry e) {
  if (e.grade == 'Grade 3' || e.reinjury) return AppColors.error;
  if (e.grade == 'Grade 2') return AppColors.warning;
  return AppColors.primary;
}

class _MuscleInjuryCard extends StatelessWidget {
  final MuscleInjuryEntry entry;

  const _MuscleInjuryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _muscleSeverityColor(entry);
    return SessionCardWidget(
      date: _fmtDate(entry.date),
      accentColor: color,
      rows: [
        SessionRowData(
          icon: Icons.fitness_center_rounded,
          label: _label(_muscleGroups, entry.muscleGroup),
          value: _label(_grades, entry.grade),
          valueColor: color,
          bold: true,
        ),
        SessionRowData(
          icon: Icons.swap_horiz_rounded,
          label: AppStrings.medicalSide,
          value: _label(_sides, entry.side),
        ),
        SessionRowData(
          icon: Icons.event_busy_rounded,
          label: AppStrings.medicalDaysLost,
          value: entry.daysLost != null ? '${entry.daysLost}' : '—',
        ),
        SessionRowData(
          icon: Icons.replay_rounded,
          label: AppStrings.medicalReinjury,
          value: entry.reinjury ? AppStrings.yes : AppStrings.no,
          valueColor: entry.reinjury ? AppColors.error : null,
        ),
      ],
    );
  }
}

Color _jointSeverityColor(JointInjuryEntry e) {
  if (e.surgeryRequired || e.reinjury) return AppColors.error;
  if (e.injuryType == 'ACL' || e.injuryType == 'PCL') return AppColors.warning;
  return AppColors.primary;
}

class _JointInjuryCard extends StatelessWidget {
  final JointInjuryEntry entry;

  const _JointInjuryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _jointSeverityColor(entry);
    return SessionCardWidget(
      date: _fmtDate(entry.date),
      accentColor: color,
      rows: [
        SessionRowData(
          icon: Icons.accessibility_new_rounded,
          label: _label(_jointTypes, entry.injuryType),
          value: _label(_sides, entry.side),
          valueColor: color,
          bold: true,
        ),
        SessionRowData(
          icon: Icons.medical_services_rounded,
          label: AppStrings.medicalSurgeryReq,
          value: entry.surgeryRequired ? AppStrings.yes : AppStrings.no,
          valueColor: entry.surgeryRequired ? AppColors.error : null,
        ),
        SessionRowData(
          icon: Icons.replay_rounded,
          label: AppStrings.medicalReinjury,
          value: entry.reinjury ? AppStrings.yes : AppStrings.no,
          valueColor: entry.reinjury ? AppColors.error : null,
        ),
      ],
    );
  }
}

Color _surgeryStatusColor(String? status) {
  switch (status) {
    case 'Fully Recovered':
      return AppColors.success;
    case 'Ongoing Rehab':
    case 'Limited Activity':
      return AppColors.warning;
    default:
      return AppColors.textSecondary;
  }
}

class _SurgeryCard extends StatelessWidget {
  final SurgeryEntry entry;

  const _SurgeryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return SessionCardWidget(
      date: _fmtDate(entry.date),
      accentColor: AppColors.accent,
      rows: [
        SessionRowData(
          icon: Icons.local_hospital_rounded,
          label: entry.surgeryName.isNotEmpty ? entry.surgeryName : '—',
          value: entry.bodyArea ?? '—',
          valueColor: AppColors.accent,
          bold: true,
        ),
        SessionRowData(
          icon: Icons.person_rounded,
          label: AppStrings.medicalSurgeon,
          value: entry.surgeon ?? '—',
        ),
        SessionRowData(
          icon: Icons.timer_rounded,
          label: AppStrings.medicalRtp,
          value: entry.returnToPlayDuration ?? '—',
        ),
        SessionRowData(
          icon: Icons.assignment_turned_in_rounded,
          label: AppStrings.medicalStatusField,
          value: _label(_surgeryStatuses, entry.currentStatus),
          valueColor: _surgeryStatusColor(entry.currentStatus),
        ),
      ],
    );
  }
}
