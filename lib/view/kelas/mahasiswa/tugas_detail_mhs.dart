import 'package:flutter/material.dart';
import 'package:project_volt/model/tugas_model.dart';

class TugasDetailMhs extends StatelessWidget {
  final TugasModel tugas;
  const TugasDetailMhs({super.key, required this.tugas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tugas.judul)),
      body: Center(child: Text("Detail untuk tugas ID: ${tugas.id}")),
    );
  }
}
