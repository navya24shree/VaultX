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
  VaultPasswordsNotifier() : super(VaultPasswordsState(allEntries: _initialEntries));

  static final List<VaultPasswordEntry> _initialEntries = [
    VaultPasswordEntry(
      id: 'vault-pw-1',
      title: 'Google',
      username: 'alex.morgan@gmail.com',
      email: 'alex.morgan@gmail.com',
      password: 'g00gle_Secur3_P@ss!99',
      category: 'Email',
      websiteUrl: 'https://accounts.google.com',
      notes: 'Primary personal Google workspace account.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    VaultPasswordEntry(
      id: 'vault-pw-2',
      title: 'Instagram',
      username: '@alex_creative',
      email: 'alex.creative@gmail.com',
      password: 'Insta_P#0to_Gr@ph2026',
      category: 'Instagram',
      websiteUrl: 'https://instagram.com',
      notes: 'Personal photography and design portfolio.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    VaultPasswordEntry(
      id: 'vault-pw-3',
      title: 'GitHub',
      username: 'alex-dev-99',
      email: 'alex.code@gmail.com',
      password: 'ghp_N3ur0K3y_Sup3rS3cr3tT0k3n',
      category: 'GitHub',
      websiteUrl: 'https://github.com',
      notes: 'Contains private repositories and open-source contributions.',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VaultPasswordEntry(
      id: 'vault-pw-4',
      title: 'Chase Bank',
      username: 'amorgan_vault',
      email: 'alex.morgan@gmail.com',
      password: 'Ch@s3_B@nk_2026_SecureKey!',
      category: 'Bank',
      websiteUrl: 'https://chase.com',
      notes: 'Checking and high yield savings account.',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    VaultPasswordEntry(
      id: 'vault-pw-5',
      title: 'Netflix',
      username: 'morgan.family@gmail.com',
      email: 'morgan.family@gmail.com',
      password: 'N3tfl!x_Str3am_4K_HDR',
      category: 'Entertainment',
      websiteUrl: 'https://netflix.com',
      notes: 'Family 4K UHD streaming tier.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

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
