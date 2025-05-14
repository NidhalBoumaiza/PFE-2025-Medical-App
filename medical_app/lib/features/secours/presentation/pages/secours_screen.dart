import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecoursScreen extends StatefulWidget {
  const SecoursScreen({super.key});

  @override
  State<SecoursScreen> createState() => _SecoursScreenState();
}

class _SecoursScreenState extends State<SecoursScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Emergency', 'Common', 'Children', 'Elderly'];

  final List<Map<String, dynamic>> _firstAidItems = [
    {
      'title': 'CPR (Basic Life Support)',
      'description': 'Learn essential techniques for cardiopulmonary resuscitation in emergency situations.',
      'icon': FontAwesomeIcons.heartPulse,
      'category': 'Emergency',
      'color': Colors.red,
    },
    {
      'title': 'Bleeding & Wounds',
      'description': 'How to properly treat and manage different types of wounds and bleeding.',
      'icon': FontAwesomeIcons.droplet,
      'category': 'Common',
      'color': Colors.red[700],
    },
    {
      'title': 'Burns Treatment',
      'description': 'First aid for different degrees of burns including thermal, chemical, and electrical burns.',
      'icon': FontAwesomeIcons.fire,
      'category': 'Common', 
      'color': Colors.orange,
    },
    {
      'title': 'Choking',
      'description': 'Learn the Heimlich maneuver and what to do when someone is choking.',
      'icon': FontAwesomeIcons.lungs,
      'category': 'Emergency',
      'color': Colors.purple,
    },
    {
      'title': 'Fractures & Sprains',
      'description': 'How to identify and provide initial care for broken bones and sprains.',
      'icon': FontAwesomeIcons.bone,
      'category': 'Common',
      'color': Colors.blue[700],
    },
    {
      'title': 'Stroke Recognition',
      'description': 'Recognize the signs of stroke using the FAST method and how to respond quickly.',
      'icon': FontAwesomeIcons.brain,
      'category': 'Emergency',
      'color': Colors.deepPurple,
    },
    {
      'title': 'Heart Attack',
      'description': 'Identify symptoms of a heart attack and the immediate actions to take.',
      'icon': FontAwesomeIcons.heart,
      'category': 'Emergency',
      'color': Colors.red,
    },
    {
      'title': 'Allergic Reactions',
      'description': 'How to recognize and respond to severe allergic reactions, including anaphylaxis.',
      'icon': FontAwesomeIcons.viruses,
      'category': 'Common',
      'color': Colors.amber[700],
    },
    {
      'title': 'Poisoning',
      'description': 'First aid for ingested, inhaled, or contact poisoning and when to seek help.',
      'icon': FontAwesomeIcons.skullCrossbones,
      'category': 'Children',
      'color': Colors.green[800],
    },
    {
      'title': 'Seizures',
      'description': 'How to safely help someone experiencing seizures and prevent injury.',
      'icon': FontAwesomeIcons.bolt,
      'category': 'Common',
      'color': Colors.amber,
    },
    {
      'title': 'Heat Stroke',
      'description': 'Recognizing and treating heat-related illnesses, particularly in hot weather.',
      'icon': FontAwesomeIcons.temperatureHigh,
      'category': 'Common',
      'color': Colors.deepOrange,
    },
    {
      'title': 'Diabetes Emergency',
      'description': 'How to help someone experiencing hypoglycemia or hyperglycemia.',
      'icon': FontAwesomeIcons.fileWaveform,
      'category': 'Common',
      'color': Colors.blue,
    },
    {
      'title': 'Child CPR',
      'description': 'Special CPR techniques adjusted for infants and children.',
      'icon': FontAwesomeIcons.child,
      'category': 'Children',
      'color': Colors.lightBlue,
    },
    {
      'title': 'Elderly Falls',
      'description': 'How to safely help an elderly person who has fallen and assess for injuries.',
      'icon': FontAwesomeIcons.personWalking,
      'category': 'Elderly',
      'color': Colors.grey[700],
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    return _firstAidItems.where((item) {
      final matchesSearch = item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Premiers Secours",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _filteredItems.isEmpty 
                ? _buildNoResultsFound()
                : _buildFirstAidGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.raleway(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
          hintText: 'Rechercher une condition...',
          hintStyle: GoogleFonts.raleway(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: GoogleFonts.raleway(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFirstAidGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildFirstAidCard(item);
      },
    );
  }
  
  Widget _buildFirstAidCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to detailed first aid instructions
          _showFirstAidDetails(item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in colored circle
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 24,
                  color: item['color'] as Color,
                ),
              ),
              SizedBox(height: 12),
              
              // Category badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['category'],
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              // Title
              Text(
                item['title'],
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Description
              Expanded(
                child: Text(
                  item['description'],
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez une autre recherche',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFirstAidDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['title'],
                      style: GoogleFonts.raleway(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item['description'],
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    Text(
                      'Premiers soins recommandés',
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Placeholder content for first aid steps
                    _buildFirstAidStep(
                      1, 
                      'Évaluez la situation',
                      'Assurez-vous que la zone est sécurisée et évaluez l\'état de la personne avant de procéder.',
                    ),
                    _buildFirstAidStep(
                      2, 
                      'Appelez à l\'aide si nécessaire',
                      'En cas d\'urgence, appelez immédiatement le 15 (SAMU), 18 (Pompiers) ou 112 (numéro d\'urgence européen).',
                    ),
                    _buildFirstAidStep(
                      3, 
                      'Administrez les premiers soins',
                      'Suivez les procédures spécifiques pour cette condition médicale.',
                    ),
                    _buildFirstAidStep(
                      4, 
                      'Surveillez l\'état',
                      'Restez avec la personne et surveillez son état jusqu\'à l\'arrivée des secours.',
                    ),
                    
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Launch emergency call
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.phone, size: 20),
                        label: Text(
                          'Appel d\'urgence',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFirstAidStep(int stepNumber, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber.toString(),
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}