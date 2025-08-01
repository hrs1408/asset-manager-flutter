import 'package:equatable/equatable.dart';
import '../../../assets/domain/entities/asset_type.dart';

class AssetSummary extends Equatable {
  final double totalBalance;
  final Map<AssetType, double> balanceByType;
  final Map<AssetType, int> countByType;
  final int totalAssets;

  const AssetSummary({
    required this.totalBalance,
    required this.balanceByType,
    required this.countByType,
    required this.totalAssets,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        balanceByType,
        countByType,
        totalAssets,
      ];
}