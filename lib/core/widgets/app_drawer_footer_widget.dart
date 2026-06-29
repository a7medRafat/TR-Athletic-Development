import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_colors.dart';
import '../utils/app_strings.dart';

class AppDrawerFooterWidget extends StatelessWidget {
  const AppDrawerFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
          ),
          SizedBox(height: 2.h),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              if (info == null) return const SizedBox.shrink();
              return Text(
                AppStrings.appVersion('${info.version}+${info.buildNumber}'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: AppColors.textHint),
              );
            },
          ),
        ],
      ),
    );
  }
}
