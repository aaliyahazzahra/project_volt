// lib/features/5_simulasi/create_simulasi_firebase_page.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
//  Import Model dan Service yang dibutuhkan
import 'package:project_volt/data/firebase/models/simulasi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/simulasi_firebase_service.dart';
import 'package:project_volt/data/simulation_models.dart';
import 'package:project_volt/features/5_simulasi/simulation_logic.dart';
import 'package:project_volt/features/5_simulasi/simulation_painters.dart';
import 'package:uuid/uuid.dart';

// ----------------------------------------------------------------------
// --- HALAMAN EDITOR SIMULASI (Dosen Mode: Create/Update/Template Load) ---
// ----------------------------------------------------------------------

class CreateSimulasiFirebasePage extends StatefulWidget {
  final String? kelasId;
  final UserFirebaseModel user;
  final String? loadSimulasiId;
  final bool isReadOnly;

  const CreateSimulasiFirebasePage({
    super.key,
    this.kelasId,
    required this.user,
    this.loadSimulasiId, // Optional ID
    this.isReadOnly = false,
  });

  @override
  State<CreateSimulasiFirebasePage> createState() =>
      _CreateSimulasiFirebasePageState();
}

class _CreateSimulasiFirebasePageState
    extends State<CreateSimulasiFirebasePage> {
  //  FIREBASE SERVICE
  final SimulasiFirebaseService _simulasiService = SimulasiFirebaseService();
  final Uuid _uuid = Uuid();
  final GlobalKey _canvasKey = GlobalKey();

  // State untuk Metadata Simulasi
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // State Simulasi
  final List<SimulationProject> _projects = [];
  int _activeIndex = 0;

  SimulationProject get _activeProject => _projects[_activeIndex];
  List<SimulationComponent> get _componentsOnCanvas =>
      _activeProject.components;
  List<WireConnection> get _wires => _activeProject.wires;

  String? _draggingFromComponentId;
  String? _draggingFromNodeId;
  Offset? _draggingOffset;

  bool _isSimulating = false;
  bool _isSaving = false;
  bool _isTemplateLoading = false; //   STATE BARU: Loading template
  bool _isDraggingComponentForDelete = false;

  // ID dari simulasi yang sedang diedit (null jika baru)
  String? _currentSimulasiId;

  @override
  void initState() {
    super.initState();
    _currentSimulasiId = widget.loadSimulasiId;

    // Muat data jika loadSimulasiId ada
    if (widget.loadSimulasiId != null) {
      _loadExistingProject(widget.loadSimulasiId!);
    } else {
      _initializeNewProject();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- LOGIC TEMPLATE LOADING ---

  void _initializeNewProject() {
    if (_projects.isEmpty) {
      _projects.add(
        SimulationProject(
          id: _uuid.v4(),
          name: "Sirkuit 1",
          components: [],
          wires: [],
        ),
      );
    }
  }

  Future<void> _loadExistingProject(String simulasiId) async {
    setState(() => _isTemplateLoading = true);

    try {
      final SimulasiFirebaseModel? existingSimulasi = await _simulasiService
          .getSimulasiById(simulasiId);

      if (existingSimulasi != null && mounted) {
        setState(() {
          // Isi metadata
          _judulController.text = existingSimulasi.judul;
          _deskripsiController.text = existingSimulasi.deskripsi;

          // Isi Project Data (Clone project untuk editor)
          // Menggunakan clone agar data Dosen asli tidak langsung terpengaruh
          _projects.add(existingSimulasi.projectData.copyWith(id: _uuid.v4()));

          _currentSimulasiId = existingSimulasi.simulasiId;
        });
        _runSimulation();
      } else {
        // Jika gagal muat, kembali ke mode buat baru
        _initializeNewProject();
        _showSnackbar(
          "Gagal",
          "Gagal memuat template simulasi. Memulai proyek kosong.",
          ContentType.warning,
        );
      }
    } catch (e) {
      _initializeNewProject();
      _showSnackbar(
        "Error",
        "Error saat memuat data: ${e.toString()}",
        ContentType.failure,
      );
    } finally {
      if (mounted) setState(() => _isTemplateLoading = false);
    }
  }

  // --- LOGIC FIREBASE SAVE/UPDATE ---

  void _showSnackbar(String title, String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: snackBarContent,
      ),
    );
  }

  Future<void> _showSaveDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            _currentSimulasiId != null
                ? 'Update Simulasi'
                : 'Simpan Simulasi Baru',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Simulasi *',
                    hintText: 'Misal: Gerbang Kombinasi Dasar',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    hintText: 'Penjelasan tujuan simulasi ini',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              onPressed: _judulController.text.isEmpty
                  ? null
                  : () => _saveProject(dialogContext),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProject(BuildContext dialogContext) async {
    if (_judulController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final SimulasiFirebaseModel simulasiToSave = SimulasiFirebaseModel(
        simulasiId: _currentSimulasiId,
        kelasId: widget.kelasId,
        dosenId: widget.user.uid,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        projectData: _activeProject,
      );

      if (widget.kelasId == null || widget.kelasId!.isEmpty) {
        // Tampilkan peringatan, tapi jangan lanjutkan proses simpan ke Firebase.
        if (mounted) {
          _showSnackbar(
            "Peringatan",
            "Simulasi tidak dapat disimpan tanpa ID Kelas yang jelas.",
            ContentType.warning,
          );
          Navigator.of(dialogContext).pop();
          if (mounted) setState(() => _isSaving = false);
        }
        return;
      }

      String resultId;
      if (_currentSimulasiId != null) {
        // UPDATE yang sudah ada
        await _simulasiService.updateSimulasi(simulasiToSave);
        resultId = _currentSimulasiId!;
      } else {
        // CREATE baru
        resultId = await _simulasiService.createSimulasi(simulasiToSave);
        // Simpan ID yang baru didapat
        setState(() => _currentSimulasiId = resultId);
      }

      // Notifikasi Sukses dan Keluar
      if (mounted) {
        _showSnackbar(
          "Sukses",
          "Simulasi berhasil disimpan!",
          ContentType.success,
        );
        Navigator.of(dialogContext).pop(); // Tutup dialog
        //   KEMBALIKAN ID SIMULASI untuk dilampirkan ke Tugas/Submisi
        Navigator.of(context).pop(resultId);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          "Gagal",
          'Gagal menyimpan: ${e.toString()}',
          ContentType.failure,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- LOGIC ENGINE & HELPER UI (Sama seperti kode sebelumnya) ---

  void _resetDragging() {
    setState(() {
      _draggingFromComponentId = null;
      _draggingFromNodeId = null;
      _draggingOffset = null;
    });
  }

  Offset _convertGlobalToLocal(Offset globalPosition) {
    final RenderBox? canvasBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null) return Offset.zero;
    return canvasBox.globalToLocal(globalPosition);
  }

  Offset getNodePosition(String componentId, String nodeId) {
    try {
      final component = _componentsOnCanvas.firstWhere(
        (c) => c.id == componentId,
      );
      final componentPosition = component.position;
      final type = component.type;

      double inputAY = (type == 'NOT' || type == 'OUTPUT') ? 30 : 18;
      double inputBY = 42;

      if (nodeId == 'input_a') {
        return Offset(componentPosition.dx, componentPosition.dy + inputAY);
      }
      if (nodeId == 'input_b') {
        return Offset(componentPosition.dx, componentPosition.dy + inputBY);
      }
      if (nodeId == 'output') {
        return Offset(componentPosition.dx + 80, componentPosition.dy + 30);
      }
      return Offset(componentPosition.dx + 80, componentPosition.dy + 30);
    } catch (e) {
      return Offset.zero;
    }
  }

  ({String componentId, String nodeId})? _findNodeAt(Offset localPosition) {
    for (final component in _componentsOnCanvas) {
      if (component.type == 'INPUT') continue;

      if (component.inputs.containsKey('input_a')) {
        final nodePos = getNodePosition(component.id, 'input_a');
        if ((localPosition - nodePos).distance < 15) {
          return (componentId: component.id, nodeId: 'input_a');
        }
      }
      if (component.inputs.containsKey('input_b')) {
        final nodePos = getNodePosition(component.id, 'input_b');
        if ((localPosition - nodePos).distance < 15) {
          return (componentId: component.id, nodeId: 'input_b');
        }
      }
    }
    return null;
  }

  void _runSimulation() async {
    if (_isSimulating) return;

    setState(() {
      _isSimulating = true;
    });

    final payload = SimulationPayload(_activeProject.copyWith());

    final SimulationProject updatedProject = await compute(
      runSimulationInBackground,
      payload,
    );

    if (!mounted) return;

    setState(() {
      _projects[_activeIndex] = updatedProject;
      _isSimulating = false;
    });
  }

  void _deleteComponent(String componentId) {
    setState(() {
      _componentsOnCanvas.removeWhere((c) => c.id == componentId);
      _wires.removeWhere(
        (wire) =>
            wire.fromComponentId == componentId ||
            wire.toComponentId == componentId,
      );
    });
    _runSimulation();
  }

  void _addCanvas() {
    setState(() {
      final newProject = SimulationProject(
        id: _uuid.v4(),
        name: "Sirkuit ${_projects.length + 1}",
        components: [],
        wires: [],
      );
      _projects.add(newProject);
      _activeIndex = _projects.length - 1;
    });
  }

  void _switchCanvas(int index) {
    if (_activeIndex == index) return;
    setState(() {
      _activeIndex = index;
      _resetDragging();
    });
    _runSimulation();
  }

  void _deleteCanvas(int index) {
    if (_projects.length <= 1) {
      return;
    }
    setState(() {
      _projects.removeAt(index);
      if (_activeIndex >= _projects.length) {
        _activeIndex = _projects.length - 1;
      }
      _resetDragging();
    });
    _runSimulation();
  }

  Widget _buildTrashArea() {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) {
        if (data is String) {
          setState(() => _isDraggingComponentForDelete = true);
          return true;
        }
        return false;
      },
      onLeave: (data) {
        setState(() => _isDraggingComponentForDelete = false);
      },
      onAcceptWithDetails: (details) {
        final componentId = details.data;
        _deleteComponent(componentId);
        setState(() => _isDraggingComponentForDelete = false);
      },
      builder: (context, candidateData, rejectedData) {
        final bool isCandidate = candidateData.isNotEmpty;
        return Container(
          height: 50,
          width: double.infinity,
          color: isCandidate
              ? AppColor.kErrorColor.withOpacity(0.8)
              : AppColor.kErrorColor.withOpacity(0.3),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_forever, color: AppColor.kWhiteColor, size: 24),
              const SizedBox(width: 8),
              Text(
                isCandidate
                    ? "LEPAS UNTUK MENGHAPUS"
                    : "Tarik Komponen Ke Sini Untuk Menghapus",
                style: TextStyle(
                  color: AppColor.kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComponentWithGesture(SimulationComponent component) {
    return Draggable<String>(
      data: component.id,
      feedback: Opacity(
        opacity: 0.7,
        child: _buildComponentWidget(component: component),
      ),
      childWhenDragging: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.kDividerColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onDragUpdate: (details) {
        setState(() {
          component.position += details.delta;
        });
      },
      onDragEnd: (details) => _runSimulation(),
      child: _buildComponentWidget(component: component),
    );
  }

  Widget _buildToolbox() {
    return Container(
      height: 100,
      width: double.infinity,
      color: AppColor.kWarningColor.withOpacity(0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildDraggableComponent("INPUT"),
            const SizedBox(width: 16),
            _buildDraggableComponent("OUTPUT"),
            const SizedBox(width: 16),
            _buildDraggableComponent("AND"),
            const SizedBox(width: 16),
            _buildDraggableComponent("OR"),
            const SizedBox(width: 16),
            _buildDraggableComponent("NOT"),
            const SizedBox(width: 16),
            _buildDraggableComponent("NAND"),
            const SizedBox(width: 16),
            _buildDraggableComponent("NOR"),
            const SizedBox(width: 16),
            _buildDraggableComponent("Ex-OR"),
            const SizedBox(width: 16),
            _buildDraggableComponent("Ex-NOR"),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableComponent(String type) {
    return Draggable<String>(
      data: type,
      feedback: _buildComponentVisual(type, isDragging: true, value: false),
      child: _buildComponentVisual(type, value: false),
      onDragStarted: () => _resetDragging(),
    );
  }

  Widget _buildComponentWidget({required SimulationComponent component}) {
    final bool isInputComponent = component.type == 'INPUT';
    Widget componentVisual = _buildComponentVisual(
      component.type,
      value: component.outputValue,
    );

    if (isInputComponent) {
      componentVisual = GestureDetector(
        onTap: () {
          setState(() {
            component.outputValue = !component.outputValue;
          });
          _runSimulation();
        },
        child: componentVisual,
      );
    }

    final type = component.type;
    final bool showInputA = type != 'INPUT';
    final bool showInputB =
        type == 'AND' ||
        type == 'OR' ||
        type == 'NAND' ||
        type == 'NOR' ||
        type == 'Ex-OR' ||
        type == 'Ex-NOR';
    final bool showOutput = type != 'OUTPUT';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        componentVisual,
        if (showInputA)
          Positioned(
            left: -8,
            top: (showInputB) ? 10 : (60 / 2) - 8,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'input_a',
              isInputNode: true,
            ),
          ),
        if (showInputB)
          Positioned(
            left: -8,
            bottom: 10,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'input_b',
              isInputNode: true,
            ),
          ),
        if (showOutput)
          Positioned(
            right: -8,
            top: (60 / 2) - 8,
            child: _buildDraggableConnectionNode(
              componentId: component.id,
              nodeId: 'output',
              isInputNode: false,
            ),
          ),
      ],
    );
  }

  Widget _buildComponentVisual(
    String type, {
    bool isDragging = false,
    required bool value,
  }) {
    if (type == 'INPUT') {
      return Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: AppColor.kWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "INPUT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColor.kPrimaryColor,
              ),
            ),
            Switch(
              value: value,
              onChanged: null,
              activeThumbColor: AppColor.kPrimaryColor,
            ),
          ],
        ),
      );
    }
    if (type == 'OUTPUT') {
      return Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: AppColor.kWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black54, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 30,
              color: value ? Colors.yellow[600] : Colors.grey,
            ),
            const SizedBox(height: 4),
            const Text(
              "OUTPUT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: isDragging
              ? Colors.blueAccent.withOpacity(0.5)
              : AppColor.kWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColor.kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableConnectionNode({
    required String componentId,
    required String nodeId,
    required bool isInputNode,
  }) {
    bool nodeValue = false;
    try {
      final component = _componentsOnCanvas.firstWhere(
        (c) => c.id == componentId,
      );
      if (isInputNode) {
        nodeValue = component.inputs[nodeId] ?? false;
      } else {
        nodeValue = component.outputValue;
      }
    } catch (e) {}

    return GestureDetector(
      onPanStart: widget.isReadOnly
          ? null
          : (details) {
              final component = _componentsOnCanvas.firstWhere(
                (c) => c.id == componentId,
              );

              if (isInputNode) {
                if (component.type != 'INPUT') return;
              }

              final Offset localPosition = _convertGlobalToLocal(
                details.globalPosition,
              );
              setState(() {
                _draggingFromComponentId = componentId;
                _draggingFromNodeId = nodeId;
                _draggingOffset = localPosition;
              });
            },
      onPanUpdate: widget.isReadOnly
          ? null
          : (details) {
              if (_draggingFromComponentId == null) return;
              final Offset localPosition = _convertGlobalToLocal(
                details.globalPosition,
              );
              setState(() {
                _draggingOffset = localPosition;
              });
            },
      onPanEnd: widget.isReadOnly
          ? null
          : (details) {
              if (_draggingFromComponentId == null) {
                _resetDragging();
                return;
              }

              final targetNode = _findNodeAt(_draggingOffset!);
              if (targetNode != null) {
                if (targetNode.componentId != _draggingFromComponentId) {
                  setState(() {
                    _wires.removeWhere(
                      (wire) =>
                          wire.toComponentId == targetNode.componentId &&
                          wire.toNodeId == targetNode.nodeId,
                    );

                    _wires.add(
                      WireConnection(
                        fromComponentId: _draggingFromComponentId!,
                        fromNodeId: _draggingFromNodeId!,
                        toComponentId: targetNode.componentId,
                        toNodeId: targetNode.nodeId,
                      ),
                    );
                  });
                  _runSimulation();
                }
              }
              _resetDragging();
            },
      child: _buildConnectionNode(isInput: isInputNode, value: nodeValue),
    );
  }

  Widget _buildConnectionNode({required bool isInput, required bool value}) {
    Color color;
    if (isInput) {
      color = value ? Colors.cyan[200]! : Colors.blue;
    } else {
      color = value ? Colors.orange : Colors.red;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.kWhiteColor, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isTemplateLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memuat Simulasi...')),
        body: Center(
          child: CircularProgressIndicator(color: AppColor.kPrimaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Editor: ${_judulController.text.isNotEmpty ? _judulController.text : _activeProject.name}",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColor.kDividerColor, width: 1.5),
        ),
        actions: [
          //   TOMBOL SIMPAN
          if (!widget.isReadOnly) //   Hanya tampilkan jika TIDAK read-only
            IconButton(
              icon: Icon(Icons.save, color: AppColor.kPrimaryColor),
              tooltip: _currentSimulasiId != null
                  ? "Update Simulasi"
                  : "Simpan Simulasi Baru",
              onPressed: widget.isReadOnly
                  ? null
                  : _showSaveDialog, //   Nonaktifkan tombol
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColor.kTextColor),
            tooltip: "Reset Canvas",
            onPressed: () {
              setState(() {
                _activeProject.components.clear();
                _activeProject.wires.clear();
                _resetDragging();
              });
            },
          ),
        ],
        // TAB BAR untuk SWITCH CANVAS
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._projects.asMap().entries.map((entry) {
                  int index = entry.key;
                  SimulationProject project = entry.value;
                  bool isSelected = index == _activeIndex;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: GestureDetector(
                      onTap: () => _switchCanvas(index),
                      onLongPress: _projects.length > 1
                          ? () => _deleteCanvas(index)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.kPrimaryColor
                              : AppColor.kDividerColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: AppColor.kTextColor, width: 1)
                              : null,
                        ),
                        child: Text(
                          project.name,
                          style: TextStyle(
                            color: isSelected
                                ? AppColor.kWhiteColor
                                : AppColor.kTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Tombol Add Canvas
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.add_box, color: AppColor.kPrimaryColor),
                    onPressed: _addCanvas,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // AREA SAMPAH (Drag Target untuk Hapus)
          if (!widget.isReadOnly) _buildTrashArea(),

          Expanded(
            // InteractiveViewer untuk ZOOM/PAN
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.5,
              maxScale: 3.0,
              // DragTarget untuk menjatuhkan komponen dari toolbox
              child: DragTarget<String>(
                onAcceptWithDetails: widget.isReadOnly
                    ? null
                    : (details) {
                        final Offset localOffset = _convertGlobalToLocal(
                          details.offset,
                        );
                        final newComponent = SimulationComponent(
                          id: _uuid.v4(),
                          type: details.data,
                          position: Offset(
                            localOffset.dx - 40,
                            localOffset.dy - 30,
                          ),
                          inputs: getDefaultInputs(details.data),
                        );
                        setState(() {
                          _componentsOnCanvas.add(newComponent);
                        });
                        _runSimulation();
                      },
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    key: _canvasKey,
                    children: [
                      // 1. Gambar kabel
                      CustomPaint(
                        painter: WirePainter(
                          components: _componentsOnCanvas,
                          wires: _wires,
                          getNodePosition: getNodePosition,
                        ),
                        size: Size.infinite,
                      ),

                      // 2. Gambar kabel sementara
                      if (_draggingFromComponentId != null &&
                          _draggingOffset != null)
                        CustomPaint(
                          painter: TemporaryWirePainter(
                            startOffset: getNodePosition(
                              _draggingFromComponentId!,
                              _draggingFromNodeId!,
                            ),
                            endOffset: _draggingOffset!,
                          ),
                          size: Size.infinite,
                        ),

                      // 3. Gambar komponen (dengan logika drag untuk geser/hapus)
                      ..._componentsOnCanvas.map((component) {
                        return Positioned(
                          left: component.position.dx,
                          top: component.position.dy,
                          child: _buildComponentWithGesture(component),
                        );
                      }),

                      // (Opsional) Tampilkan loading saat simulasi berjalan
                      if (_isSimulating)
                        Center(
                          child: CircularProgressIndicator(
                            color: AppColor.kPrimaryColor,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (!widget.isReadOnly) _buildToolbox(),
        ],
      ),
    );
  }
}
