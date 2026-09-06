import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/router/app_router.dart';
import '../data/api_patient_repository.dart';
import '../domain/patient.dart';
import '../../../core/network/api_exception.dart';

/// Patient search screen with QR code and text search
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiPatientRepository _repository = ApiPatientRepository();
  List<Patient> _searchResults = [];
  List<Patient> _recentPatients = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounce;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final recent = await _repository.getRecentlyViewed(5);
      if (!mounted) return;
      setState(() {
        _recentPatients = recent;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException ? e.message : 'Une erreur inattendue est survenue.';
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      _searchRequestId++; // invalidate any in-flight search
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    // Wait for a pause in typing before hitting the API, instead of firing
    // a request on every keystroke.
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    final requestId = ++_searchRequestId;
    setState(() => _errorMessage = null);
    try {
      final results = await _repository.searchPatients(query);
      // A newer keystroke may have started another search while this one
      // was in flight; ignore this response if it's no longer the latest.
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _isSearching = false;
        _errorMessage = e is ApiException ? e.message : 'Une erreur inattendue est survenue.';
      });
    }
  }

  void _onScanQR() {
    // Mock QR scan - will use mobile_scanner in production
    // For MVP, simulate a successful scan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Simulation: QR scanné - Patient PAT001 trouvé')),
    );
    // Navigate to patient record
    context.push('/patient/PAT001');
  }

  void _onPatientSelected(Patient patient) {
    context.push('/patient/${patient.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text(
          'Chercher un patient',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // QR Scan button
          _buildQRScanButton(),

          // Divider
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
            child: Row(
              children: [
                const Expanded(child: Divider(color: AppColors.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm),
                  child: Text('ou', style: AppTextStyles.secondary),
                ),
                const Expanded(child: Divider(color: AppColors.line)),
              ],
            ),
          ),

          // Search field
          _buildSearchField(),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanButton() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: AppCard(
        onTap: _onScanQR,
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: const Icon(
                AppIcons.qrCode,
                size: AppConstants.iconLg,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Text(
              'Scanner un QR code',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom ou village',
          prefixIcon: const Icon(AppIcons.search, color: AppColors.inkSoft),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const SkeletonList();
    }

    if (_isSearching) {
      return const SkeletonList(count: 3);
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _searchController.text.trim().isEmpty
            ? _loadRecentPatients
            : () => _performSearch(_searchController.text.trim()),
      );
    }

    if (_searchController.text.isNotEmpty) {
      // Show search results
      if (_searchResults.isEmpty) {
        return const EmptyState(
          icon: AppIcons.search,
          title: 'Aucun résultat',
          subtitle: 'Essayez une autre recherche',
        );
      }
      return _buildPatientList(_searchResults);
    }

    // Show recently viewed
    if (_recentPatients.isEmpty) {
      return const EmptyState(
        icon: AppIcons.person,
        title: 'Aucun patient récent',
        subtitle: 'Les patients consultés apparaîtront ici',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          child: Text(
            'Récemment vus',
            style: AppTextStyles.label,
          ),
        ),
        Expanded(child: _buildPatientList(_recentPatients)),
      ],
    );
  }

  Widget _buildPatientList(List<Patient> patients) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return PatientCard(
          name: patient.fullName,
          village: patient.village,
          initials: patient.initials,
          onTap: () => _onPatientSelected(patient),
        );
      },
    );
  }
}
