// lib/screens/paciente_list_screen.dart
import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/fhir_service.dart';
import '../services/ehr_service.dart';
import '../widgets/paciente_card.dart';
import 'paciente_form_screen.dart';
import 'composition_form/composition_form_wizard.dart';
import 'composition_list.dart'; // *Ver nota abajo*

class PacienteListScreen extends StatefulWidget {
  const PacienteListScreen({Key? key}) : super(key: key);

  @override
  _PacienteListScreenState createState() => _PacienteListScreenState();
}

class _PacienteListScreenState extends State<PacienteListScreen> {
  List<Paciente> pacientes = [];
  List<Paciente> pacientesFiltrados = [];
  bool loading = true;
  final TextEditingController _buscarController = TextEditingController();

  String? _assigningPatientId;

  @override
  void initState() {
    super.initState();
    cargarPacientes();
    _buscarController.addListener(_filtrarPacientes);
  }

  @override
  void dispose() {
    _buscarController.removeListener(_filtrarPacientes);
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarPacientes() async {
    setState(() => loading = true);
    try {
      pacientes = await FhirService().obtenerPacientes();
      pacientesFiltrados = pacientes;
    } catch (e) {
      pacientes = [];
      pacientesFiltrados = [];
      debugPrint('Error cargando pacientes: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _filtrarPacientes() {
    String query = _buscarController.text.toLowerCase();
    setState(() {
      pacientesFiltrados = pacientes.where((p) {
        return p.nombre.toLowerCase().contains(query) ||
            p.curp.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _agregarPaciente() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PacienteFormScreen(onSaved: cargarPacientes),
      ),
    );
  }

  void _editarPaciente(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) =>
            PacienteFormScreen(paciente: paciente, onSaved: cargarPacientes),
      ),
    );
  }

  // Reemplaza la implementación de _eliminarPaciente con esta:
  Future<void> _eliminarPaciente(Paciente paciente) async {
    if (paciente.idFhir == null) return;

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text(
          "¿Desea eliminar al paciente seleccionado?\nUna vez borrado no es posible recuperarlo de nuevo.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Borrar"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Ejecutar borrado asincrónico
    final ok = await FhirService().eliminarPaciente(paciente.idFhir!);

    // Evitar usar context si el widget fue desmontado mientras esperábamos
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Paciente eliminado")));
      await cargarPacientes(); // recargar listado
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar paciente")),
      );
    }
  }

  // Reemplaza la implementación de _assignEhrToPaciente con esta:
  Future<void> _assignEhrToPaciente(Paciente paciente) async {
    if (paciente.idFhir == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paciente sin id FHIR')));
      return;
    }

    setState(() => _assigningPatientId = paciente.idFhir);

    try {
      final ehrId = await EhrService().createEhr(paciente.nombre);
      final added = await FhirService().addEhrExtension(
        paciente.idFhir!,
        ehrId,
      );

      // Comprobación de mounted antes de usar context o setState
      if (!mounted) return;

      if (added) {
        await cargarPacientes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EHR asignado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No fue posible asignar EHR (PATCH falló)'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al asignar EHR: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _assigningPatientId = null);
    }
  }

  void _openCompositionList(Paciente paciente) {
    if (paciente.ehrId == null || paciente.ehrId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente no tiene EHR asignado')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CompositionList(ehrId: paciente.ehrId!, paciente: paciente),
      ),
    );
  }

  void _openCompositionWizard(Paciente paciente) {
    if (paciente.ehrId == null || paciente.ehrId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente no tiene EHR asignado')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CompositionFormWizard(ehrId: paciente.ehrId!, paciente: paciente),
      ),
    );
  }

  Widget _buildPacienteActions(Paciente paciente) {
    final hasEhr = paciente.ehrId != null && paciente.ehrId!.isNotEmpty;
    final isAssigning =
        _assigningPatientId != null && _assigningPatientId == paciente.idFhir;

    if (isAssigning) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasEhr) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Historial clínico'),
            onPressed: () => _openCompositionList(paciente),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Crear historia',
            onPressed: () => _openCompositionWizard(paciente),
          ),
        ] else ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.link_off, size: 18),
            label: const Text('Asignar EHR'),
            onPressed: () => _assignEhrToPaciente(paciente),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pacientes FHIR")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _buscarController,
              decoration: InputDecoration(
                labelText: "Buscar por nombre o CURP",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pacientesFiltrados.isEmpty
                ? const Center(child: Text("No hay pacientes registrados"))
                : ListView.builder(
                    itemCount: pacientesFiltrados.length,
                    itemBuilder: (context, idx) {
                      final paciente = pacientesFiltrados[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PacienteCard(
                                paciente: paciente,
                                onEdit: () => _editarPaciente(paciente),
                                onDelete: () => _eliminarPaciente(paciente),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child:
                                        paciente.ehrId != null &&
                                            paciente.ehrId!.isNotEmpty
                                        ? Text(
                                            'EHR: ${paciente.ehrId}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : const Text(
                                            'Sin EHR asignado',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  _buildPacienteActions(paciente),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _agregarPaciente,
      ),
    );
  }
}
