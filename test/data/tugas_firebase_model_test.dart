import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';

void main() {
  group('TugasFirebaseModel.fromMap', () {
    test('parses required and optional fields', () {
      final model = TugasFirebaseModel.fromMap({
        'kelasId': 'k1',
        'dosenId': 'd1',
        'judul': 'Tugas Gerbang Logika',
        'deskripsi': 'Buat rangkaian AND',
        'tglDibuat': '2025-01-10T08:00:00.000',
        'tglTenggat': '2025-01-20T23:59:00.000',
        'simulasiId': 's1',
      }, id: 't1');

      expect(model.tugasId, 't1');
      expect(model.kelasId, 'k1');
      expect(model.dosenId, 'd1');
      expect(model.judul, 'Tugas Gerbang Logika');
      expect(model.deskripsi, 'Buat rangkaian AND');
      expect(model.tglDibuat, DateTime(2025, 1, 10, 8));
      expect(model.tglTenggat, DateTime(2025, 1, 20, 23, 59));
      expect(model.simulasiId, 's1');
    });

    test('leaves optional fields null when absent', () {
      final model = TugasFirebaseModel.fromMap({
        'kelasId': 'k1',
        'dosenId': 'd1',
        'judul': 'Tanpa tenggat',
      });

      expect(model.tugasId, isNull);
      expect(model.deskripsi, isNull);
      expect(model.tglDibuat, isNull);
      expect(model.tglTenggat, isNull);
      expect(model.simulasiId, isNull);
    });

    test('treats an unparsable date string as null', () {
      final model = TugasFirebaseModel.fromMap({
        'kelasId': 'k1',
        'dosenId': 'd1',
        'judul': 'Tanggal rusak',
        'tglTenggat': 'bukan-tanggal',
      });

      expect(model.tglTenggat, isNull);
    });
  });
}
