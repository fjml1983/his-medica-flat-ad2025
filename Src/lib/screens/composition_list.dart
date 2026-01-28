import 'package:flutter/material.dart';
import 'package:hismedica/models/patient_model.dart';
import '../models/paciente.dart';
import '../services/ehr_service.dart';
import 'composition_form/composition_form_wizard.dart';
import 'composition_detail.dart';

class CompositionList extends StatefulWidget {
  final String ehrId;
  final Paciente? paciente;

  const CompositionList({Key? key, required this.ehrId, this.paciente})
    : super(key: key);

  @override
  State<CompositionList> createState() => _CompositionListState();
}

class _CompositionListState extends State<CompositionList> {
  final _ehrService = EhrService();
  List<Map<String, dynamic>> _compositions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompositions();
  }

  Future<void> _loadCompositions() async {
    setState(() => _isLoading = true);

    try {
      final compositions = await _ehrService.getCompositions(widget.ehrId);
      setState(() {
        _compositions = compositions ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar expedientes clínicos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paciente?.nombre ?? widget.ehrId),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompositions,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _compositions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay expedientes clínicos',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea el primer Expediente clínico',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _compositions.length,
              itemBuilder: (context, index) {
                final comp = _compositions[index];
                final reason = comp['reason'] ?? comp['title'] ?? 'Sin motivo';
                final composer =
                    comp['composer_name'] ?? comp['composer'] ?? 'Desconocido';
                final start = comp['start_time'] ?? comp['time'] ?? '';

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.description)),
                    title: Text(reason),
                    subtitle: Text(
                      'Médico: $composer\nFecha: $start',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final uid =
                          comp['uid'] as String? ??
                          comp['compositionUid'] as String? ??
                          '';
                      if (uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('UID de composición no disponible'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompositionDetail(
                            ehrId: widget.ehrId,
                            compositionUid: uid,
                            compositionTitle: reason,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewComposition(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Registro Clínico'),
      ),
    );
  }

  Future<void> _createNewComposition() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompositionFormWizard(
          ehrId: widget.ehrId,
          paciente: widget.paciente,
        ),
      ),
    );

    if (result == true) {
      _loadCompositions();
    }
  }
}
