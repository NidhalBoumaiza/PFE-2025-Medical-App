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
        const SnackBar(
          content: Text('Ordonnance ajoutée avec succès'),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gestion des Ordonnances'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Formulaire d'ajout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouvelle Ordonnance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _patientNameController,
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          labelText: 'Nom du patient',
                          labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                          prefixIcon: const Icon(Icons.person, color: AppColors.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primaryColor),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? theme.inputDecorationTheme.fillColor : Colors.white,
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
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          labelText: 'Médicament',
                          labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                          prefixIcon: const Icon(Icons.medication, color: AppColors.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primaryColor),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? theme.inputDecorationTheme.fillColor : Colors.white,
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
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          labelText: 'Dosage',
                          labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                          prefixIcon: const Icon(Icons.straighten, color: AppColors.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primaryColor),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? theme.inputDecorationTheme.fillColor : Colors.white,
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
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          labelText: 'Instructions',
                          labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                          prefixIcon: const Icon(Icons.description, color: AppColors.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primaryColor),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? theme.inputDecorationTheme.fillColor : Colors.white,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer les instructions';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addOrdonnance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ajouter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Liste des ordonnances
          Expanded(
            child: _ordonnances.isEmpty
                ? Center(
                    child: Text(
                      'Aucune ordonnance pour le moment',
                      style: TextStyle(fontSize: 16, color: theme.textTheme.bodySmall?.color),
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
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: theme.cardColor,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                              child: const Icon(Icons.receipt, color: AppColors.primaryColor),
                            ),
                            title: Text(
                              'Patient: ${ordonnance.patientName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Médicament: ${ordonnance.medication}',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                ),
                                Text(
                                  'Dosage: ${ordonnance.dosage}',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                ),
                                Text(
                                  'Instructions: ${ordonnance.instructions}',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                ),
                                Text(
                                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(ordonnance.date)}',
                                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrdonnance,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}