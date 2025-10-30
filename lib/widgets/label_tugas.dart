import 'package:flutter/material.dart';

class LabelTugas extends StatelessWidget {
  const LabelTugas({
    super.key,
    required this.judulTugas,
    required this.namaMataPelajaran,
  });

  final String judulTugas;
  final String namaMataPelajaran;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.abc_outlined),

            SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judulTugas,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                Text(
                  namaMataPelajaran,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
