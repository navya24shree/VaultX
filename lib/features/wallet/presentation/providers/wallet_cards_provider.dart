import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurokey/features/wallet/domain/wallet_card_entry.dart';

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
  WalletCardsNotifier() : super(WalletCardsState(allCards: _initialCards));

  static final List<WalletCardEntry> _initialCards = [
    WalletCardEntry(
      id: 'card-1',
      title: 'Chase Sapphire Reserve',
      cardholderName: 'ALEX MORGAN',
      cardNumber: '4532 8921 7843 7890',
      expiry: '08/29',
      cvv: '382',
      network: 'Visa',
      cardTheme: 'chase_sapphire',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WalletCardEntry(
      id: 'card-2',
      title: 'Apple Card Titanium',
      cardholderName: 'ALEX MORGAN',
      cardNumber: '5412 7534 8901 2345',
      expiry: '11/28',
      cvv: '914',
      network: 'Mastercard',
      cardTheme: 'apple_titanium',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    WalletCardEntry(
      id: 'card-3',
      title: 'Plexee Sovereign',
      cardholderName: 'ALEX MORGAN',
      cardNumber: '6011 3902 4819 5678',
      expiry: '04/30',
      cvv: '520',
      network: 'Plexee',
      cardTheme: 'plexee_sovereign',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

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
}

final walletCardsProvider =
    StateNotifierProvider<WalletCardsNotifier, WalletCardsState>((ref) {
  return WalletCardsNotifier();
});
