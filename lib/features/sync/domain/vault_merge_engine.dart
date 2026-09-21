import 'package:vaultx/features/vault/domain/vault_password_entry.dart';
import 'package:vaultx/features/wallet/domain/wallet_card_entry.dart';

/// Detailed report of a vault synchronization merge operation.
class VaultMergeReport {
  final int passwordsInserted;
  final int passwordsUpdated;
  final int passwordsPreservedLocal;
  final int cardsInserted;
  final int cardsUpdated;
  final int cardsPreservedLocal;
  final List<String> detectedConflicts;

  final List<VaultPasswordEntry> mergedPasswords;
  final List<WalletCardEntry> mergedCards;

  const VaultMergeReport({
    required this.passwordsInserted,
    required this.passwordsUpdated,
    required this.passwordsPreservedLocal,
    required this.cardsInserted,
    required this.cardsUpdated,
    required this.cardsPreservedLocal,
    required this.detectedConflicts,
    required this.mergedPasswords,
    required this.mergedCards,
  });

  int get totalChangesApplied =>
      passwordsInserted + passwordsUpdated + cardsInserted + cardsUpdated;
}

/// Conflict-free Merge Engine implementing timestamp-based Last-Write-Wins (LWW)
/// and missing-entry insertion per §6.2.8.
///
/// Guaranteed properties:
/// 1. Newer local edits are NEVER overwritten by older synced remote edits.
/// 2. Missing entries on either device are seamlessly merged.
/// 3. Concurrent conflicting edits are flagged and preserved.
class VaultMergeEngine {
  /// Merges [incomingPasswords] into [localPasswords].
  VaultMergeReport merge({
    required List<VaultPasswordEntry> localPasswords,
    required List<VaultPasswordEntry> incomingPasswords,
    required List<WalletCardEntry> localCards,
    required List<WalletCardEntry> incomingCards,
  }) {
    int pwInserted = 0;
    int pwUpdated = 0;
    int pwPreserved = 0;
    int cdInserted = 0;
    int cdUpdated = 0;
    int cdPreserved = 0;
    final conflicts = <String>[];

    // Merge Passwords
    final passwordMap = <String, VaultPasswordEntry>{
      for (final p in localPasswords) p.id: p,
    };

    for (final remote in incomingPasswords) {
      if (!passwordMap.containsKey(remote.id)) {
        // Missing on local -> Add
        passwordMap[remote.id] = remote;
        pwInserted++;
      } else {
        final local = passwordMap[remote.id]!;
        if (remote.updatedAt.isAfter(local.updatedAt)) {
          // Remote is strictly newer -> Update
          passwordMap[remote.id] = remote;
          pwUpdated++;
        } else if (local.updatedAt.isAfter(remote.updatedAt)) {
          // Local is strictly newer -> Preserve local
          pwPreserved++;
        } else {
          // Same timestamp -> Check for content divergence
          if (local.password != remote.password ||
              local.username != remote.username ||
              local.title != remote.title) {
            conflicts.add(
              'Password conflict on "${local.title}": identical timestamp with different data.',
            );
            // Preserve local as authoritative in tie
            pwPreserved++;
          }
        }
      }
    }

    // Merge Cards
    final cardMap = <String, WalletCardEntry>{
      for (final c in localCards) c.id: c,
    };

    for (final remote in incomingCards) {
      if (!cardMap.containsKey(remote.id)) {
        // Missing on local -> Add
        cardMap[remote.id] = remote;
        cdInserted++;
      } else {
        final local = cardMap[remote.id]!;
        if (remote.updatedAt.isAfter(local.updatedAt)) {
          // Remote is strictly newer -> Update
          cardMap[remote.id] = remote;
          cdUpdated++;
        } else if (local.updatedAt.isAfter(remote.updatedAt)) {
          // Local is strictly newer -> Preserve local
          cdPreserved++;
        } else {
          // Same timestamp
          if (local.cardNumber != remote.cardNumber ||
              local.cvv != remote.cvv ||
              local.title != remote.title) {
            conflicts.add(
              'Card conflict on "${local.title}": identical timestamp with different data.',
            );
            cdPreserved++;
          }
        }
      }
    }

    return VaultMergeReport(
      passwordsInserted: pwInserted,
      passwordsUpdated: pwUpdated,
      passwordsPreservedLocal: pwPreserved,
      cardsInserted: cdInserted,
      cardsUpdated: cdUpdated,
      cardsPreservedLocal: cdPreserved,
      detectedConflicts: conflicts,
      mergedPasswords: passwordMap.values.toList(),
      mergedCards: cardMap.values.toList(),
    );
  }
}
