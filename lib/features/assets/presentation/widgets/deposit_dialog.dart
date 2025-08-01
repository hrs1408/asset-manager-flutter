import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset.dart';
import '../../../expenses/domain/entities/deposit_source.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';
import 'deposit_source_dropdown.dart';

class DepositDialog extends StatefulWidget {
  final Asset asset;

  const DepositDialog({
    super.key,
    required this.asset,
  });

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DepositSource _selectedSource = DepositSource.salary;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return value;
    
    // Remove all non-digit characters except decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Parse as double and format with commas
    final number = double.tryParse(cleanValue);
    if (number == null) return value;
    
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }
    
    if (amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(
        _amountController.text.replaceAll(',', ''),
      );
      
      context.read<AssetBloc>().add(
        AssetDepositWithDetailsRequested(
          assetId: widget.asset.id,
          amount: amount,
          depositSource: _selectedSource.value,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Nộp tiền vào tài sản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Asset info - Compact
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tài sản:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    widget.asset.name,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Số dư: ${_formatCurrency(widget.asset.balance.toStringAsFixed(0))} VNĐ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền nộp',
                          hintText: 'Nhập số tiền',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          suffixText: 'VNĐ',
                          isDense: true,
                        ),
                        validator: _validateAmount,
                        onChanged: (value) {
                          final formatted = _formatCurrency(value);
                          if (formatted != value) {
                            _amountController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Deposit source dropdown
                      DepositSourceDropdown(
                        selectedSource: _selectedSource,
                        onChanged: (source) {
                          setState(() {
                            _selectedSource = source;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Notes field - Compact
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú (tùy chọn)',
                          hintText: 'Nhập ghi chú...',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Nộp tiền'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}