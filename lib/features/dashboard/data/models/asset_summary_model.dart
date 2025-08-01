import '../../domain/entities/asset_summary.dart';
import '../../../assets/domain/entities/asset_type.dart';

class AssetSummaryModel extends AssetSummary {
  const AssetSummaryModel({
    required super.totalBalance,
    required super.balanceByType,
    required super.countByType,
    required super.totalAssets,
  });

  factory AssetSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parse balanceByType
    final balanceByTypeJson = json['balanceByType'] as Map<String, dynamic>? ?? {};
    final Map<AssetType, double> balanceByType = {};
    for (final entry in balanceByTypeJson.entries) {
      final assetType = _parseAssetType(entry.key);
      balanceByType[assetType] = (entry.value as num).toDouble();
    }

    // Parse countByType
    final countByTypeJson = json['countByType'] as Map<String, dynamic>? ?? {};
    final Map<AssetType, int> countByType = {};
    for (final entry in countByTypeJson.entries) {
      final assetType = _parseAssetType(entry.key);
      countByType[assetType] = entry.value as int;
    }

    return AssetSummaryModel(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      balanceByType: balanceByType,
      countByType: countByType,
      totalAssets: json['totalAssets'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert balanceByType to JSON
    final Map<String, double> balanceByTypeJson = {};
    for (final entry in balanceByType.entries) {
      balanceByTypeJson[_assetTypeToString(entry.key)] = entry.value;
    }

    // Convert countByType to JSON
    final Map<String, int> countByTypeJson = {};
    for (final entry in countByType.entries) {
      countByTypeJson[_assetTypeToString(entry.key)] = entry.value;
    }

    return {
      'totalBalance': totalBalance,
      'balanceByType': balanceByTypeJson,
      'countByType': countByTypeJson,
      'totalAssets': totalAssets,
    };
  }

  factory AssetSummaryModel.fromEntity(AssetSummary entity) {
    return AssetSummaryModel(
      totalBalance: entity.totalBalance,
      balanceByType: entity.balanceByType,
      countByType: entity.countByType,
      totalAssets: entity.totalAssets,
    );
  }

  static AssetType _parseAssetType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'paymentaccount':
        return AssetType.paymentAccount;
      case 'savingsaccount':
        return AssetType.savingsAccount;
      case 'gold':
        return AssetType.gold;
      case 'loan':
        return AssetType.loan;
      case 'realestate':
        return AssetType.realEstate;
      default:
        return AssetType.other;
    }
  }

  static String _assetTypeToString(AssetType assetType) {
    switch (assetType) {
      case AssetType.paymentAccount:
        return 'paymentAccount';
      case AssetType.savingsAccount:
        return 'savingsAccount';
      case AssetType.gold:
        return 'gold';
      case AssetType.loan:
        return 'loan';
      case AssetType.realEstate:
        return 'realEstate';
      case AssetType.other:
        return 'other';
    }
  }
}