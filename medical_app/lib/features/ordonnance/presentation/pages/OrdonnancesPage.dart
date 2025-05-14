import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';

class Ordonnance {
  final String patientName;
  final String medication;
  final String dosage;
  final String instructions;
  final DateTime date;

  Ordonnance({
    required this.patientName,
    required this.medication,
    required this.dosage,
    required this.instructions,
    required this.date,
  });
}

class OrdonnancesPage extends StatefulWidget {
  const OrdonnancesPage({super.key});

  @override
  _OrdonnancesPageState createState() => _OrdonnancesPageState();
}

class _OrdonnancesPageState extends State<OrdonnancesPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<Ordonnance> _ordonnances = [];

  void _addOrdonnance() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _ordonnances.insert(
          0,
          Ordonnance(
            patientName: _patientNameController.text,
            medication: _medicationController.text,
            dosage: _dosageController.text,
            instructions: _instructionsController.text,
            date: DateTime.now(),
          ),
        );
        _patientNameController.clear();
        _medicationController.clear();
        _dosageController.clear();
        _instructionsController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ordonnance ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Ordonnances'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Formulaire pour ajouter une ordonnance
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _patientNameController,
                          decoration: InputDecoration(
                            labelText: 'Nom du patient',
                            prefixIcon: const Icon(Icons.person, color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du patient';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _medicationController,
                          decoration: InputDecoration(
                            labelText: 'Médicament',
                            prefixIcon: const Icon(Icons.medical_services, color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du médicament';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dosageController,
                          decoration: InputDecoration(
                            labelText: 'Dosage',
                            prefixIcon: const Icon(Icons.medication, color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _instructionsController,
                          decoration: InputDecoration(
                            labelText: 'Instructions',
                            prefixIcon: const Icon(Icons.description, color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer les instructions';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Liste des ordonnances
              Expanded(
                child: _ordonnances.isEmpty
                    ? const Center(
                  child: Text(
                    'Aucune ordonnance pour le moment',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: _ordonnances.length,
                  itemBuilder: (context, index) {
                    final ordonnance = _ordonnances[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.receipt, color: AppColors.primaryColor),
                          ),
                          title: Text(
                            'Patient: ${ordonnance.patientName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Médicament: ${ordonnance.medication}'),
                              Text('Dosage: ${ordonnance.dosage}'),
                              Text('Instructions: ${ordonnance.instructions}'),
                              Text(
                                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(ordonnance.date)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrdonnance,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}