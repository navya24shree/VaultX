import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultx/features/vault/domain/vault_password_entry.dart';

class VaultPasswordsState {
  final List<VaultPasswordEntry> allEntries;
  final String searchQuery;
  final String selectedCategory;
  final List<String> customCategories;

  static const List<String> defaultCategories = [
    'Email',
    'Instagram',
    'Bank',
    'GitHub',
    'Entertainment',
    'Social',
  ];

  const VaultPasswordsState({
    this.allEntries = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.customCategories = const [],
  });

  List<String> get allCategories {
    final list = <String>[...customCategories];
    for (final c in defaultCategories) {
      if (!list.any((existing) => existing.toLowerCase() == c.toLowerCase())) {
        list.add(c);
      }
    }
    for (final entry in allEntries) {
      final c = entry.category.trim();
      if (c.isNotEmpty && !list.any((existing) => existing.toLowerCase() == c.toLowerCase())) {
        list.add(c);
      }
    }
    return list;
  }

  List<VaultPasswordEntry> get filteredEntries {
    return allEntries.where((entry) {
      final matchesCategory = selectedCategory == 'All' ||
          entry.category.toLowerCase() == selectedCategory.toLowerCase();
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.username.toLowerCase().contains(query) ||
          entry.email.toLowerCase().contains(query) ||
          entry.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  VaultPasswordsState copyWith({
    List<VaultPasswordEntry>? allEntries,
    String? searchQuery,
    String? selectedCategory,
    List<String>? customCategories,
  }) {
    return VaultPasswordsState(
      allEntries: allEntries ?? this.allEntries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      customCategories: customCategories ?? this.customCategories,
    );
  }
}

class VaultPasswordsNotifier extends StateNotifier<VaultPasswordsState> {
  VaultPasswordsNotifier() : super(const VaultPasswordsState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void addCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    if (!state.allCategories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      state = state.copyWith(
        customCategories: [...state.customCategories, trimmed],
      );
    }
  }

  void addPassword(VaultPasswordEntry entry) {
    final trimmedCat = entry.category.trim();
    final updatedCustom = [...state.customCategories];
    if (trimmedCat.isNotEmpty &&
        !state.allCategories.any((c) => c.toLowerCase() == trimmedCat.toLowerCase())) {
      updatedCustom.add(trimmedCat);
    }
    state = state.copyWith(
      allEntries: [entry, ...state.allEntries],
      customCategories: updatedCustom,
    );
  }

  void updatePassword(VaultPasswordEntry updated) {
    final updatedList = state.allEntries.map((e) {
      return e.id == updated.id ? updated : e;
    }).toList();
    state = state.copyWith(allEntries: updatedList);
  }

  void deletePassword(String id) {
    final updatedList = state.allEntries.where((e) => e.id != id).toList();
    state = state.copyWith(allEntries: updatedList);
  }

  void saveEntry(VaultPasswordEntry entry) {
    if (state.allEntries.any((e) => e.id == entry.id)) {
      updatePassword(entry);
    } else {
      addPassword(entry);
    }
  }
}

final vaultPasswordsProvider =
    StateNotifierProvider<VaultPasswordsNotifier, VaultPasswordsState>((ref) {
  return VaultPasswordsNotifier();
});
