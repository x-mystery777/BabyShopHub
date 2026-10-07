import 'package:flutter/material.dart';

import '../../../services/shop_api.dart';

/// UI model for the category fields described in the SRS/schema.
class StoreCategory {
  const StoreCategory({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.active = true,
  });

  final int categoryId;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool active;
}

class CategoryTab extends StatefulWidget {
  const CategoryTab({required this.onCategorySelected, super.key});

  final ValueChanged<String> onCategorySelected;

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  /// Live categories from the backend (no placeholder data).
  List<StoreCategory> _categories = const [];
  bool _loading = true;
  String? _error;

  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await ShopApi.categories();
      if (!mounted) return;
      setState(() {
        _categories = categories
            .map((c) => StoreCategory(
                  categoryId: c.id,
                  name: c.name,
                  description: c.description ?? '',
                  icon: Icons.category_outlined,
                  color: const Color(0xFF55AFFF),
                ))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final categories = _categories.where((category) {
      return category.active &&
          (query.isEmpty ||
              category.name.toLowerCase().contains(query) ||
              category.description.toLowerCase().contains(query));
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: Color(0xFF183B67),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: _searching
                      ? 'Close category search'
                      : 'Search categories',
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) _searchController.clear();
                  }),
                  icon: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 19),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF3F6FA),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF218CF2)))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          TextButton(
                              onPressed: _load,
                              child: const Text('Try again')),
                        ],
                      ),
                    )
                  : categories.isEmpty
                      ? const Center(child: Text('No categories found.'))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CategoryCard(
                              category: category,
                              onTap: () =>
                                  widget.onCategorySelected(category.name),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final StoreCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE9F0F6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.color.withValues(alpha: 0.17),
                ),
                child: Icon(category.icon, size: 29, color: category.color),
              ),
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF31577E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
