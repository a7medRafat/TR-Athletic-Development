import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../data/models/medical_models.dart';

// key = Firestore value (English), value = translation key
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

// key = Firestore value, value = translation key
const _sides = {
  'Right': 'side_right',
  'Left': 'side_left',
  'Both': 'side_both',
};
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

class RegisterMedicalStep extends StatefulWidget {
  const RegisterMedicalStep({super.key});

  @override
  State<RegisterMedicalStep> createState() => RegisterMedicalStepState();
}

class RegisterMedicalStepState extends State<RegisterMedicalStep> {
  bool _hasMuscleInjuries = false;
  final Map<String, MuscleInjuryEntry> _muscleEntries = {};

  bool _hasJointInjuries = false;
  final Map<String, JointInjuryEntry> _jointEntries = {};

  bool _hasSurgeries = false;
  final List<SurgeryEntry> _surgeries = [];

  bool _currentPain = false;
  bool _chronicInjury = false;
  bool _medications = false;

  MedicalHistory getMedicalHistory() => MedicalHistory(
        muscleInjuries:
            _hasMuscleInjuries ? _muscleEntries.values.toList() : [],
        jointInjuries: _hasJointInjuries ? _jointEntries.values.toList() : [],
        surgeries: _hasSurgeries ? _surgeries : [],
        currentPain: _currentPain,
        chronicInjury: _chronicInjury,
        medications: _medications,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AppStrings.medicalPrevMuscle,
          icon: Icons.fitness_center_rounded,
        ),
        _YesNoToggle(
          question: AppStrings.medicalQMuscle,
          value: _hasMuscleInjuries,
          onChanged: (v) => setState(() {
            _hasMuscleInjuries = v;
            if (!v) _muscleEntries.clear();
          }),
        ),
        if (_hasMuscleInjuries) ...[
          SizedBox(height: 12.h),
          ..._muscleGroups.entries.map((e) => _MuscleGroupRow(
                dataKey: e.key,
                displayLabel: e.value.tr(),
                entry: _muscleEntries[e.key],
                onToggle: (selected) => setState(() {
                  if (selected) {
                    _muscleEntries[e.key] =
                        MuscleInjuryEntry(muscleGroup: e.key);
                  } else {
                    _muscleEntries.remove(e.key);
                  }
                }),
                onChanged: () => setState(() {}),
              )),
        ],
        SizedBox(height: 24.h),
        _SectionHeader(
          title: AppStrings.medicalPrevJoint,
          icon: Icons.healing_rounded,
        ),
        _YesNoToggle(
          question: AppStrings.medicalQJoint,
          value: _hasJointInjuries,
          onChanged: (v) => setState(() {
            _hasJointInjuries = v;
            if (!v) _jointEntries.clear();
          }),
        ),
        if (_hasJointInjuries) ...[
          SizedBox(height: 12.h),
          ..._jointTypes.entries.map((e) => _JointTypeRow(
                dataKey: e.key,
                displayLabel: e.value.tr(),
                entry: _jointEntries[e.key],
                onToggle: (selected) => setState(() {
                  if (selected) {
                    _jointEntries[e.key] = JointInjuryEntry(injuryType: e.key);
                  } else {
                    _jointEntries.remove(e.key);
                  }
                }),
                onChanged: () => setState(() {}),
              )),
        ],
        SizedBox(height: 24.h),
        _SectionHeader(
          title: AppStrings.medicalSurgeryHist,
          icon: Icons.medical_services_rounded,
        ),
        _YesNoToggle(
          question: AppStrings.medicalQSurgery,
          value: _hasSurgeries,
          onChanged: (v) => setState(() {
            _hasSurgeries = v;
            if (!v) _surgeries.clear();
          }),
        ),
        if (_hasSurgeries) ...[
          SizedBox(height: 12.h),
          ..._surgeries.asMap().entries.map((e) => _SurgeryCard(
                index: e.key,
                entry: e.value,
                onRemove: () => setState(() => _surgeries.removeAt(e.key)),
                onChanged: () => setState(() {}),
              )),
          SizedBox(height: 8.h),
          _AddButton(
            label: AppStrings.medicalAddSurgery,
            onTap: () => setState(() => _surgeries.add(SurgeryEntry())),
          ),
        ],
        SizedBox(height: 24.h),
        _SectionHeader(
          title: AppStrings.medicalCurrentStatus,
          icon: Icons.monitor_heart_rounded,
        ),
        SizedBox(height: 8.h),
        _StatusToggle(
          label: AppStrings.medicalCurrentPain,
          value: _currentPain,
          onChanged: (v) => setState(() => _currentPain = v),
        ),
        _StatusToggle(
          label: AppStrings.medicalChronicInjury,
          value: _chronicInjury,
          onChanged: (v) => setState(() => _chronicInjury = v),
        ),
        _StatusToggle(
          label: AppStrings.medicalMedications,
          value: _medications,
          onChanged: (v) => setState(() => _medications = v),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _YesNoToggle extends StatelessWidget {
  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _YesNoToggle({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.2),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Muscle injury row ─────────────────────────────────────────────────────────

class _MuscleGroupRow extends StatelessWidget {
  final String dataKey;
  final String displayLabel;
  final MuscleInjuryEntry? entry;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChanged;

  const _MuscleGroupRow({
    required this.dataKey,
    required this.displayLabel,
    required this.entry,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = entry != null;
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
          title: Text(
            displayLabel,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
          value: isSelected,
          activeColor: AppColors.primary,
          onChanged: (v) => onToggle(v ?? false),
        ),
        if (isSelected) _MuscleDetailCard(entry: entry!, onChanged: onChanged),
      ],
    );
  }
}

class _MuscleDetailCard extends StatefulWidget {
  final MuscleInjuryEntry entry;
  final VoidCallback onChanged;

  const _MuscleDetailCard({required this.entry, required this.onChanged});

  @override
  State<_MuscleDetailCard> createState() => _MuscleDetailCardState();
}

class _MuscleDetailCardState extends State<_MuscleDetailCard> {
  late final TextEditingController _daysController;

  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController(
      text: widget.entry.daysLost?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 4.w, bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DropdownRow(
            label: AppStrings.medicalSide,
            value: e.side,
            items: _sides,
            onChanged: (v) => setState(() {
              e.side = v;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          _DropdownRow(
            label: AppStrings.medicalGrade,
            value: e.grade,
            items: _grades,
            onChanged: (v) => setState(() {
              e.grade = v;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          _DateRow(
            label: AppStrings.medicalDateInjury,
            date: e.date,
            onPicked: (d) => setState(() {
              e.date = d;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(AppStrings.medicalDaysLost),
                  onChanged: (v) {
                    e.daysLost = int.tryParse(v);
                    widget.onChanged();
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _CheckRow(
                  label: AppStrings.medicalReinjury,
                  value: e.reinjury,
                  onChanged: (v) => setState(() {
                    e.reinjury = v;
                    widget.onChanged();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Joint injury row ──────────────────────────────────────────────────────────

class _JointTypeRow extends StatelessWidget {
  final String dataKey;
  final String displayLabel;
  final JointInjuryEntry? entry;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChanged;

  const _JointTypeRow({
    required this.dataKey,
    required this.displayLabel,
    required this.entry,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = entry != null;
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
          title: Text(
            displayLabel,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
          value: isSelected,
          activeColor: AppColors.primary,
          onChanged: (v) => onToggle(v ?? false),
        ),
        if (isSelected) _JointDetailCard(entry: entry!, onChanged: onChanged),
      ],
    );
  }
}

class _JointDetailCard extends StatefulWidget {
  final JointInjuryEntry entry;
  final VoidCallback onChanged;

  const _JointDetailCard({required this.entry, required this.onChanged});

  @override
  State<_JointDetailCard> createState() => _JointDetailCardState();
}

class _JointDetailCardState extends State<_JointDetailCard> {
  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 4.w, bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DropdownRow(
            label: AppStrings.medicalSide,
            value: e.side,
            items: _sides,
            onChanged: (v) => setState(() {
              e.side = v;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          _DateRow(
            label: AppStrings.medicalDateInjury,
            date: e.date,
            onPicked: (d) => setState(() {
              e.date = d;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _CheckRow(
                  label: AppStrings.medicalSurgeryReq,
                  value: e.surgeryRequired,
                  onChanged: (v) => setState(() {
                    e.surgeryRequired = v;
                    widget.onChanged();
                  }),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _CheckRow(
                  label: AppStrings.medicalReinjury,
                  value: e.reinjury,
                  onChanged: (v) => setState(() {
                    e.reinjury = v;
                    widget.onChanged();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Surgery card ──────────────────────────────────────────────────────────────

class _SurgeryCard extends StatefulWidget {
  final int index;
  final SurgeryEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _SurgeryCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_SurgeryCard> createState() => _SurgeryCardState();
}

class _SurgeryCardState extends State<_SurgeryCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _surgeonCtrl;
  late final TextEditingController _rtpCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _nameCtrl = TextEditingController(text: e.surgeryName);
    _areaCtrl = TextEditingController(text: e.bodyArea ?? '');
    _surgeonCtrl = TextEditingController(text: e.surgeon ?? '');
    _rtpCtrl = TextEditingController(text: e.returnToPlayDuration ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    _surgeonCtrl.dispose();
    _rtpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.medicalSurgeryN(widget.index + 1),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDecoration(AppStrings.medicalSurgeryName),
            onChanged: (v) {
              e.surgeryName = v;
              widget.onChanged();
            },
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _areaCtrl,
            decoration: _inputDecoration(AppStrings.medicalBodyArea),
            onChanged: (v) {
              e.bodyArea = v.isEmpty ? null : v;
              widget.onChanged();
            },
          ),
          SizedBox(height: 8.h),
          _DateRow(
            label: AppStrings.medicalSurgeryDate,
            date: e.date,
            onPicked: (d) => setState(() {
              e.date = d;
              widget.onChanged();
            }),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _surgeonCtrl,
            decoration: _inputDecoration(AppStrings.medicalSurgeon),
            onChanged: (v) {
              e.surgeon = v.isEmpty ? null : v;
              widget.onChanged();
            },
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _rtpCtrl,
            decoration: _inputDecoration(AppStrings.medicalRtp),
            onChanged: (v) {
              e.returnToPlayDuration = v.isEmpty ? null : v;
              widget.onChanged();
            },
          ),
          SizedBox(height: 8.h),
          _DropdownRow(
            label: AppStrings.medicalStatusField,
            value: e.currentStatus,
            items: _surgeryStatuses,
            onChanged: (v) => setState(() {
              e.currentStatus = v;
              widget.onChanged();
            }),
          ),
        ],
      ),
    );
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class _DropdownRow extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> items; // dataKey → translationKey
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration(label),
      isExpanded: true,
      style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
      items: items.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value.tr(), style: TextStyle(fontSize: 12.sp)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPicked;

  const _DateRow({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime(2020),
          firstDate: DateTime(1970),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
                    : label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: date != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.primary,
          onChanged: (v) => onChanged(v ?? false),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.surface,
    );
