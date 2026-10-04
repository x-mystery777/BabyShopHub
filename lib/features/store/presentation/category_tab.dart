import 'package:flutter/material.dart';

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
  static const _categories = <StoreCategory>[
    StoreCategory(
      categoryId: 1,
      name: 'Diapers',
      description: 'Soft, comfortable diapers and changing essentials.',
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF7BD5E6),
    ),
    StoreCategory(
      categoryId: 2,
      name: 'Baby Food',
      description: 'Food, snacks, and nutrition for little ones.',
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFFFB86B),
    ),
    StoreCategory(
      categoryId: 3,
      name: 'Clothing',
      description: 'Everyday outfits and soft baby clothing.',
      icon: Icons.checkroom_rounded,
      color: Color(0xFF55AFFF),
    ),
    StoreCategory(
      categoryId: 4,
      name: 'Toys',
      description: 'Playtime toys for growing minds.',
      icon: Icons.toys_rounded,
      color: Color(0xFFFF91A9),
    ),
    StoreCategory(
      categoryId: 5,
      name: 'Feeding',
      description: 'Bottles, cups, and feeding accessories.',
      icon: Icons.local_drink_rounded,
      color: Color(0xFFFFAA62),
    ),
    StoreCategory(
      categoryId: 6,
      name: 'Skincare',
      description: 'Gentle bath and skincare products.',
      icon: Icons.spa_rounded,
      color: Color(0xFF57AFFF),
    ),
    StoreCategory(
      categoryId: 7,
      name: 'Accessories',
      description: 'Useful finishing touches for baby and parent.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFAA89EE),
    ),
    StoreCategory(
      categoryId: 8,
      name: 'Strollers',
      description: 'Strollers and on-the-go travel essentials.',
      icon: Icons.stroller_rounded,
      color: Color(0xFF5DC5C6),
    ),
    StoreCategory(
      categoryId: 9,
      name: 'Others',
      description: 'More helpful essentials for your family.',
      icon: Icons.backpack_outlined,
      color: Color(0xFFAA89EE),
    ),
  ];

  final _searchController = TextEditingController();
  bool _searching = false;

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
          child: categories.isEmpty
              ? const Center(child: Text('No categories found.'))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () => widget.onCategorySelected(category.name),
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
