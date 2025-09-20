import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/search_models.dart';
import '../../../data/services/search_api_service.dart';

final searchApiServiceProvider = Provider((ref) => SearchApiService());

class GlobalSearchWidget extends ConsumerStatefulWidget {
  final Function(SearchResultItem)? onItemTap;
  final SearchType? initialSearchType;
  final String? initialQuery;

  const GlobalSearchWidget({
    super.key,
    this.onItemTap,
    this.initialSearchType,
    this.initialQuery,
  });

  @override
  ConsumerState<GlobalSearchWidget> createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends ConsumerState<GlobalSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  SearchType _selectedType = SearchType.global;
  List<SearchResultItem> _results = [];
  List<SearchSuggestion> _suggestions = [];
  List<String> _recentSearches = [];
  List<SavedSearch> _savedSearches = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSearchType ?? SearchType.global;
    _searchController.text = widget.initialQuery ?? '';
    _searchFocusNode.addListener(_onFocusChanged);
    _loadInitialData();
    
    if (widget.initialQuery?.isNotEmpty ?? false) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showSuggestions = true;
      });
    } else if (!_searchFocusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final service = ref.read(searchApiServiceProvider);
      final results = await Future.wait([
        service.getRecentSearches(),
        service.getSavedSearches(),
      ]);

      if (mounted) {
        setState(() {
          _recentSearches = results[0] as List<String>;
          _savedSearches = results[1] as List<SavedSearch>;
        });
      }
    } catch (e) {
      // Handle error silently for initial data
      print('Failed to load initial search data: $e');
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _showSuggestions = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
      _currentQuery = query;
    });

    try {
      final service = ref.read(searchApiServiceProvider);
      final searchQuery = SearchQuery(
        query: query,
        type: _selectedType,
      );

      final result = await service.search(searchQuery);

      if (mounted) {
        setState(() {
          _results = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      final service = ref.read(searchApiServiceProvider);
      final suggestions = await service.getSuggestions(query, _selectedType);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }
    } catch (e) {
      // Handle suggestion errors silently
      print('Failed to get suggestions: $e');
    }
  }

  void _onResultTap(SearchResultItem item, int position) {
    // Track click analytics
    ref.read(searchApiServiceProvider).trackSearchClick(
      query: _currentQuery,
      itemId: item.id,
      itemType: item.type,
      position: position,
    );

    if (widget.onItemTap != null) {
      widget.onItemTap!(item);
    } else {
      _navigateToItem(item);
    }
  }

  void _navigateToItem(SearchResultItem item) {
    // Default navigation logic based on item type
    switch (item.type) {
      case SearchItemType.user:
        // Navigate to user profile
        break;
      case SearchItemType.document:
        // Navigate to document viewer
        break;
      case SearchItemType.logEntry:
        // Navigate to log details
        break;
      case SearchItemType.setting:
        // Navigate to settings page
        break;
      case SearchItemType.report:
        // Navigate to report
        break;
      case SearchItemType.webhook:
        // Navigate to webhook details
        break;
      case SearchItemType.apiKey:
        // Navigate to API key details
        break;
      case SearchItemType.session:
        // Navigate to session details
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchHeader(),
        if (_showSuggestions) _buildSuggestionsPanel() else _buildResultsList(),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search ${_selectedType.displayName.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results = [];
                                _showSuggestions = true;
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isNotEmpty) {
                      _getSuggestions(value);
                    }
                  },
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SearchType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type.displayName),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch();
                      }
                    }
                  },
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsPanel() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_suggestions.isNotEmpty) ...[
              _buildSectionHeader('Suggestions'),
              ..._suggestions.map((suggestion) => ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(suggestion.text),
                    onTap: () {
                      _searchController.text = suggestion.text;
                      _performSearch();
                    },
                  )),
            ],
            if (_recentSearches.isNotEmpty) ...[
              _buildSectionHeader('Recent Searches'),
              ..._recentSearches.map((query) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        // Remove from recent searches
                        setState(() {
                          _recentSearches.remove(query);
                        });
                      },
                    ),
                    onTap: () {
                      _searchController.text = query;
                      _performSearch();
                    },
                  )),
              if (_recentSearches.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('Clear search history'),
                  onTap: () async {
                    try {
                      await ref.read(searchApiServiceProvider).clearSearchHistory();
                      setState(() {
                        _recentSearches.clear();
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to clear history: $e')),
                        );
                      }
                    }
                  },
                ),
            ],
            if (_savedSearches.isNotEmpty) ...[
              _buildSectionHeader('Saved Searches'),
              ..._savedSearches.map((saved) => ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(saved.name),
                    subtitle: Text(saved.query),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) => _handleSavedSearchAction(action, saved),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _searchController.text = saved.query;
                      _selectedType = saved.type;
                      _performSearch();
                    },
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_results.isEmpty && _searchController.text.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No results found for "${_searchController.text}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('Try different keywords or search type'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showSaveSearchDialog(),
                child: const Text('Save this search'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];
          return _buildResultItem(item, index);
        },
      ),
    );
  }

  Widget _buildResultItem(SearchResultItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            _getItemIcon(item.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    item.type.displayName,
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  'Score: ${item.score.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: item.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.thumbnailUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              )
            : null,
        onTap: () => _onResultTap(item, index),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  IconData _getItemIcon(SearchItemType type) {
    switch (type) {
      case SearchItemType.user:
        return Icons.person;
      case SearchItemType.document:
        return Icons.description;
      case SearchItemType.logEntry:
        return Icons.list_alt;
      case SearchItemType.setting:
        return Icons.settings;
      case SearchItemType.report:
        return Icons.assessment;
      case SearchItemType.webhook:
        return Icons.webhook;
      case SearchItemType.apiKey:
        return Icons.vpn_key;
      case SearchItemType.session:
        return Icons.schedule;
    }
  }

  void _handleSavedSearchAction(String action, SavedSearch saved) async {
    if (action == 'delete') {
      try {
        await ref.read(searchApiServiceProvider).deleteSavedSearch(saved.id);
        setState(() {
          _savedSearches.removeWhere((s) => s.id == saved.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved search deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _showSaveSearchDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Save Search'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Search Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Make public'),
                value: isPublic,
                onChanged: (value) => setState(() => isPublic = value ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: nameController.text.isEmpty
                  ? null
                  : () => _savePermanentSearch(
                        nameController.text,
                        descriptionController.text,
                        isPublic,
                      ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePermanentSearch(String name, String description, bool isPublic) async {
    try {
      final savedSearch = await ref.read(searchApiServiceProvider).saveSearch(
            name: name,
            query: _searchController.text,
            filters: [], // Add filters if implemented
            type: _selectedType,
            description: description.isEmpty ? null : description,
            isPublic: isPublic,
          );

      setState(() {
        _savedSearches.add(savedSearch);
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save search: $e')),
        );
      }
    }
  }
}