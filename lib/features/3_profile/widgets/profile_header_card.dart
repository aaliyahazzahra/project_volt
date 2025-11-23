import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/user_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final Color roleColor;
  final VoidCallback onEdit;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.roleColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDosen = user.role == UserRole.dosen.toString();
    final String roleText = isDosen ? "Dosen" : "Mahasiswa";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: AppColor.kBlackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Lengkap
                Text(
                  user.namaLengkap,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.kTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.kTextSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Badge Role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: roleColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avatar dan Tombol Edit
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 40, color: roleColor),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Material(
                  color: AppColor.kWhiteColor,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: onEdit,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.kDividerColor),
                      ),
                      child: Icon(Icons.edit, size: 16, color: roleColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
