import 'package:flutter/material.dart';
import 'package:project_volt/widgets/label_tugas.dart';

class TugasKelas extends StatefulWidget {
  const TugasKelas({super.key});

  @override
  State<TugasKelas> createState() => _TugasKelasState();
}

class _TugasKelasState extends State<TugasKelas> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabelTugas(judulTugas: "Tugas1", namaMataPelajaran: "judul"),
        LabelTugas(judulTugas: "Tugas1", namaMataPelajaran: "judul"),
        LabelTugas(judulTugas: "Tugas1", namaMataPelajaran: "judul"),
      ],
    );
  }
}
