// lib/features/5_simulasi/create_simulasi_firebase_page.dart

import 'dart:async'; // Diperlukan untuk Timer

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
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
    this.loadSimulasiId,
    this.isReadOnly = false,
  });

  @override
  State<CreateSimulasiFirebasePage> createState() =>
      _CreateSimulasiFirebasePageState();
}

class _CreateSimulasiFirebasePageState extends State<CreateSimulasiFirebasePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // FIREBASE SERVICE
  final SimulasiFirebaseService _simulasiService = SimulasiFirebaseService();
  final Uuid _uuid = Uuid();
  final GlobalKey _canvasKey = GlobalKey();

  // State untuk Metadata Simulasi
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // State Simulasi
  final List<SimulationProject> _projects = [];
  int _activeIndex = 0;

  late UserFirebaseModel _currentUser;
  late bool _isDosen; // True if the user role is 'dosen'

  /// Determines the scaffold background color based on user role.
  Color get _scaffoldBgColor =>
      _isDosen ? AppColor.kBackgroundColor : AppColor.kBackgroundColorMhs;

  /// Determines the appbar background color based on user role.
  Color get _appBarColor => _isDosen ? AppColor.kAppBar : AppColor.kAccentColor;

  /// Determines the appbar title color based on user role.
  Color get _appBarTitleColor =>
      _isDosen ? AppColor.kTextColor : AppColor.kWhiteColor;

  SimulationProject get _activeProject => _projects[_activeIndex];
  List<SimulationComponent> get _componentsOnCanvas =>
      _activeProject.components;
  List<WireConnection> get _wires => _activeProject.wires;

  String? _draggingFromComponentId;
  String? _draggingFromNodeId;
  Offset? _draggingOffset;

  bool _isSimulating = false;
  bool _isSaving = false;
  bool _isTemplateLoading = false;

  String? _currentSimulasiId;

  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _currentSimulasiId = widget.loadSimulasiId;
    _currentUser = widget.user;
    _isDosen = _currentUser.role == 'dosen';

    if (widget.loadSimulasiId != null) {
      _loadExistingProject(widget.loadSimulasiId!);
    } else {
      _initializeNewProject();
    }
  }

  Color get _roleColor =>
      _isDosen ? AppColor.kPrimaryColor : AppColor.kAccentColor;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _simulationTimer?.cancel(); // Pastikan timer dibatalkan
    super.dispose();
  }

  //   LOGIC DEBOUNCE 45ms
  void _triggerSimulation() {
    if (_isSimulating) return;

    _simulationTimer?.cancel();

    _simulationTimer = Timer(const Duration(milliseconds: 450), () {
      // 450ms Sesuai Permintaan
      _runSimulation();
    });
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
          _judulController.text = existingSimulasi.judul;
          _deskripsiController.text = existingSimulasi.deskripsi;

          _projects.add(existingSimulasi.projectData.copyWith(id: _uuid.v4()));

          if (widget.kelasId != null) {
            _currentSimulasiId = null;
            _judulController.text = 'Jawaban Tugas';
            _deskripsiController.text = 'Jawaban simulasi dari tugas...';
          } else {
            _currentSimulasiId = existingSimulasi.simulasiId;
          }
        });
        _runSimulation(); // Panggilan simulasi awal tanpa debounce
      } else {
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

  // --- LOGIC FIREBASE SAVE/UPDATE (Tidak Berubah) ---

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
              onPressed: () => _saveProject(dialogContext),
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

    if (widget.kelasId == null || widget.kelasId!.isEmpty) {
      if (mounted) {
        _showSnackbar(
          "Peringatan",
          "Simulasi tidak dapat disimpan karena tidak terkait dengan kelas manapun.",
          ContentType.warning,
        );
        Navigator.of(dialogContext).pop();
        if (mounted) setState(() => _isSaving = false);
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      final SimulasiFirebaseModel simulasiToSave = SimulasiFirebaseModel(
        simulasiId: _currentSimulasiId,
        kelasId: widget.kelasId!,
        dosenId: widget.user.uid,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        projectData: _activeProject,
      );

      String resultId;
      if (_currentSimulasiId != null) {
        await _simulasiService.updateSimulasi(simulasiToSave);
        resultId = _currentSimulasiId!;
      } else {
        resultId = await _simulasiService.createSimulasi(simulasiToSave);
        setState(() => _currentSimulasiId = resultId);
      }

      if (mounted) {
        _showSnackbar(
          "Sukses",
          "Simulasi berhasil disimpan!",
          ContentType.success,
        );
        Navigator.of(dialogContext).pop();
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

  // --- LOGIC ENGINE & HELPER UI ---

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

  // Menggunakan GateType di sini
  Offset getNodePosition(String componentId, String nodeId) {
    try {
      final component = _componentsOnCanvas.firstWhere(
        (c) => c.id == componentId,
      );
      final componentPosition = component.position;
      final type = component.type; // Mengambil GateType

      // Gunakan GateType untuk penentuan posisi
      double inputAY = (type == GateType.NOT || type == GateType.OUTPUT)
          ? 30
          : 18;
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
      if (component.type == GateType.INPUT) continue; // Menggunakan GateType

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

    // Menggunakan compute untuk menjalankan logika simulasi di Isolate lain
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
    _runSimulation(); // Panggilan simulasi langsung saat ganti tab (tidak perlu debounce)
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
    _runSimulation(); // Panggilan simulasi langsung saat hapus tab (tidak perlu debounce)
  }

  Widget _buildComponentInPlace(SimulationComponent component) {
    return _buildComponentWidget(component: component);
  }

  Widget _buildToolbox() {
    if (widget.isReadOnly) return const SizedBox.shrink();

    //   PERBAIKAN OVERFLOW: Menggunakan padding horizontal dan tinggi yang tetap
    return Container(
      height: 90, // Tinggi dikurangi sedikit untuk menghindari overflow
      width: double.infinity,
      color: AppColor.kWarningColor.withOpacity(0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            _buildDraggableComponent(GateType.INPUT),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.OUTPUT),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.AND),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.OR),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.NOT),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.NAND),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.NOR),
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.ExOR), // Menggunakan Enum
            const SizedBox(width: 16),
            _buildDraggableComponent(GateType.ExNOR), // Menggunakan Enum
          ],
        ),
      ),
    );
  }

  // GANTI: String type -> GateType type
  Widget _buildDraggableComponent(GateType type) {
    return Draggable<GateType>(
      // GANTI generic type
      data: type,
      feedback: _buildComponentVisual(type, isDragging: true, value: false),
      child: _buildComponentVisual(type, value: false),
      onDragStarted: () => _resetDragging(),
    );
  }

  Widget _buildComponentWidget({required SimulationComponent component}) {
    final bool isInputComponent =
        component.type == GateType.INPUT; // Menggunakan Enum
    Widget componentVisual = _buildComponentVisual(
      component.type,
      value: component.outputValue,
    );

    if (isInputComponent && !widget.isReadOnly) {
      componentVisual = GestureDetector(
        onTap: () {
          setState(() {
            component.outputValue = !component.outputValue;
          });
          _triggerSimulation(); // GANTI DENGAN DEBOUNCE
        },
        child: componentVisual,
      );
    }

    final type = component.type;
    final bool showInputA = type != GateType.INPUT;
    final bool showInputB =
        type == GateType.AND ||
        type == GateType.OR ||
        type == GateType.NAND ||
        type == GateType.NOR ||
        type == GateType.ExOR || // Menggunakan Enum
        type == GateType.ExNOR; // Menggunakan Enum
    final bool showOutput = type != GateType.OUTPUT;

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

  // GANTI: String type -> GateType type
  Widget _buildComponentVisual(
    GateType type, {
    bool isDragging = false,
    required bool value,
  }) {
    // Menggunakan GateType untuk identifikasi
    // file: CreateSimulasiFirebasePage.dart (Potongan kode _buildComponentVisual)

    // Menggunakan GateType untuk identifikasi
    if (type == GateType.INPUT) {
      return Container(
        height: 60,
        width: 80,
        decoration: BoxDecoration(
          color: AppColor.kWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.kPrimaryColor, width: 2),
        ),
        child: Column(
          // Menggunakan start alignment untuk memanfaatkan ruang lebih baik
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 2.0),
            //   child: const Text(
            //     "INPUT",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 8,
            //       color: AppColor.kTextColor,
            //     ),
            //   ),
            // ),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                value: value,
                onChanged: null,
                activeThumbColor: AppColor.kPrimaryColor,
                activeTrackColor: AppColor.kPrimaryColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Menggunakan GateType untuk identifikasi
    if (type == GateType.OUTPUT) {
      return Container(
        height: 70,
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
            // const Text(
            //   "OUTPUT",
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 12,
            //     color: Colors.black54,
            //   ),
            // ),
          ],
        ),
      );
    }
    return Container(
      height: 70,
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
              type.name, // Menggunakan type.name (ExOR, AND, dll)
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColor.kPrimaryColor,
              ),
            ),
          ),
        ],
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

              // Kabel hanya boleh ditarik dari output
              if (isInputNode && component.type != GateType.INPUT) {
                _showSnackbar(
                  "Peringatan",
                  "Kabel hanya boleh ditarik dari output gerbang atau INPUT switch.",
                  ContentType.warning,
                );
                return;
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
              if (_draggingFromComponentId == null || _draggingOffset == null) {
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
                  _triggerSimulation(); // GANTI DENGAN DEBOUNCE
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
    super.build(context);

    if (_isTemplateLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Memuat Simulasi...',
            style: TextStyle(
              color: AppColor.kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: _roleColor)),
      );
    }

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Editor: ${_judulController.text.isNotEmpty ? _judulController.text : _activeProject.name}",
          style: TextStyle(
            color: _appBarTitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _appBarColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColor.kDividerColor, width: 1.5),
        ),
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: Icon(Icons.save, color: _appBarTitleColor),
              tooltip: _currentSimulasiId != null
                  ? "Update Simulasi"
                  : "Simpan Simulasi Baru",
              onPressed: widget.isReadOnly ? null : _showSaveDialog,
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
              _runSimulation(); // Panggil langsung setelah reset
            },
          ),
        ],
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
                      onLongPress: !widget.isReadOnly && _projects.length > 1
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
                if (!widget.isReadOnly)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.add_box, color: _appBarTitleColor),
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
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.5,
              maxScale: 3.0,
              // GANTI DragTarget<String> menjadi DragTarget<GateType>
              child: DragTarget<GateType>(
                onAcceptWithDetails: widget.isReadOnly
                    ? null
                    : (details) {
                        final Offset localOffset = _convertGlobalToLocal(
                          details.offset,
                        );
                        // GANTI details.data (String) menjadi GateType
                        final GateType gateType = details.data;
                        final newComponent = SimulationComponent(
                          id: _uuid.v4(),
                          type: gateType,
                          position: Offset(
                            localOffset.dx - 40,
                            localOffset.dy - 30,
                          ),
                          inputs: getDefaultInputs(
                            gateType,
                          ), // Menggunakan GateType
                        );
                        setState(() {
                          _componentsOnCanvas.add(newComponent);
                        });
                        _triggerSimulation(); // GANTI DENGAN DEBOUNCE
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

                      // 3. Gambar komponen
                      ..._componentsOnCanvas.map((component) {
                        return Positioned(
                          left: component.position.dx,
                          top: component.position.dy,
                          child: _buildComponentInPlace(component),
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
