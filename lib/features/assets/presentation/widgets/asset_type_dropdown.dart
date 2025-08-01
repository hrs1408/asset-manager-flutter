import 'package:flutter/material.dart';
import '../../domain/entities/asset_type.dart';

class AssetTypeDropdown extends StatelessWidget {
  final AssetType selectedType;
  final ValueChanged<AssetType> onChanged;

  const AssetTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.paymentAccount:
        return Icons.credit_card;
      case AssetType.savingsAccount:
        return Icons.savings;
      case AssetType.gold:
        return Icons.diamond;
      case AssetType.loan:
        return Icons.handshake;
      case AssetType.realEstate:
        return Icons.home;
      case AssetType.other:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AssetType>(
      value: selectedType,
      onChanged: (AssetType? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      decoration: InputDecoration(
        labelText: 'Loại tài sản',
        prefixIcon: Icon(_getAssetIcon(selectedType)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: AssetType.values.map((AssetType type) {
        return DropdownMenuItem<AssetType>(
          value: type,
          child: Row(
            children: [
              Icon(
                _getAssetIcon(type),
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn loại tài sản';
        }
        return null;
      },
    );
  }
}