import 'package:flutter/material.dart';
import '../../../expenses/domain/entities/deposit_source.dart';

class DepositSourceDropdown extends StatelessWidget {
  final DepositSource selectedSource;
  final ValueChanged<DepositSource> onChanged;
  final String? labelText;

  const DepositSourceDropdown({
    super.key,
    required this.selectedSource,
    required this.onChanged,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DepositSource>(
      value: selectedSource,
      decoration: InputDecoration(
        labelText: labelText ?? 'Nguồn nộp tiền',
        prefixIcon: Icon(
          _getSourceIcon(selectedSource),
          color: _getSourceColor(selectedSource),
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
      items: DepositSource.values.map((source) {
        return DropdownMenuItem<DepositSource>(
          value: source,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSourceIcon(source),
                size: 18,
                color: _getSourceColor(source),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  source.displayName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn nguồn nộp tiền';
        }
        return null;
      },
    );
  }

  IconData _getSourceIcon(DepositSource source) {
    switch (source) {
      case DepositSource.salary:
        return Icons.work;
      case DepositSource.bonus:
        return Icons.card_giftcard;
      case DepositSource.business:
        return Icons.business;
      case DepositSource.investment:
        return Icons.trending_up;
      case DepositSource.gift:
        return Icons.redeem;
      case DepositSource.loan:
        return Icons.handshake;
      case DepositSource.other:
        return Icons.more_horiz;
    }
  }

  Color _getSourceColor(DepositSource source) {
    switch (source) {
      case DepositSource.salary:
        return Colors.blue;
      case DepositSource.bonus:
        return Colors.orange;
      case DepositSource.business:
        return Colors.green;
      case DepositSource.investment:
        return Colors.purple;
      case DepositSource.gift:
        return Colors.pink;
      case DepositSource.loan:
        return Colors.amber;
      case DepositSource.other:
        return Colors.grey;
    }
  }
}