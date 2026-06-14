import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/search_provider.dart';
import '../../data/house_repository.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/house_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Use addPostFrameCallback to access provider after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Data Warga/Rumah'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) {
                    return CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Masukkan nama warga atau nomor rumah...',
                      onChanged: (query) {
                        final allHouses = Provider.of<HouseRepository>(context, listen: false).houses;
                        searchProvider.search(query, allHouses);
                      },
                      onClear: () {
                        _searchController.clear();
                        searchProvider.clearSearch();
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) {
                    if (searchProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (searchProvider.errorMessage != null) {
                      return Center(
                        child: Text(
                          searchProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (searchProvider.currentQuery.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Ketik nama atau nomor rumah untuk mulai mencari',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    if (searchProvider.searchResults.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data yang cocok dengan pencarian Anda.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: searchProvider.searchResults.length,
                      itemBuilder: (context, index) {
                        final house = searchProvider.searchResults[index];
                        return HouseCard(
                          house: house,
                          searchQuery: searchProvider.currentQuery,
                          onTap: () {
                            context.push('/detail-house', extra: house);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
