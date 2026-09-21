import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultx/features/wallet/domain/wallet_card_entry.dart';

class WalletCardsState {
  final List<WalletCardEntry> allCards;
  final String searchQuery;
  final String selectedNetwork;

  const WalletCardsState({
    this.allCards = const [],
    this.searchQuery = '',
    this.selectedNetwork = 'All',
  });

  List<WalletCardEntry> get filteredCards {
    return allCards.where((card) {
      final matchesNetwork = selectedNetwork == 'All' ||
          card.network.toLowerCase() == selectedNetwork.toLowerCase();
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          card.title.toLowerCase().contains(query) ||
          card.cardholderName.toLowerCase().contains(query) ||
          card.network.toLowerCase().contains(query) ||
          card.cardNumber.contains(query);
      return matchesNetwork && matchesSearch;
    }).toList();
  }

  WalletCardsState copyWith({
    List<WalletCardEntry>? allCards,
    String? searchQuery,
    String? selectedNetwork,
  }) {
    return WalletCardsState(
      allCards: allCards ?? this.allCards,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedNetwork: selectedNetwork ?? this.selectedNetwork,
    );
  }
}

class WalletCardsNotifier extends StateNotifier<WalletCardsState> {
  WalletCardsNotifier() : super(const WalletCardsState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedNetwork(String network) {
    state = state.copyWith(selectedNetwork: network);
  }

  void addCard(WalletCardEntry card) {
    state = state.copyWith(
      allCards: [card, ...state.allCards],
    );
  }

  void updateCard(WalletCardEntry updated) {
    final updatedList = state.allCards.map((c) {
      return c.id == updated.id ? updated : c;
    }).toList();
    state = state.copyWith(allCards: updatedList);
  }

  void deleteCard(String id) {
    final updatedList = state.allCards.where((c) => c.id != id).toList();
    state = state.copyWith(allCards: updatedList);
  }

  void saveCard(WalletCardEntry card) {
    if (state.allCards.any((c) => c.id == card.id)) {
      updateCard(card);
    } else {
      addCard(card);
    }
  }
}

final walletCardsProvider =
    StateNotifierProvider<WalletCardsNotifier, WalletCardsState>((ref) {
  return WalletCardsNotifier();
});
