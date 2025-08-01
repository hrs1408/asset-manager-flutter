import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';

class TransferDialog extends StatefulWidget {
  final Asset fromAsset;
  final List<Asset> availableAssets;

  const TransferDialog({
    super.key,
    required this.fromAsset,
    required this.availableAssets,
  });

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  Asset? _selectedToAsset;

  @override
  void initState() {
    super.initState();
    // Lọc ra các tài sản khác (không phải tài sản nguồn)
    final otherAssets = widget.availableAssets
        .where((asset) => asset.id != widget.fromAsset.id)
        .toList();
    
    if (otherAssets.isNotEmpty) {
      _selectedToAsset = otherAssets.first;
    }
  }

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
    
    if (amount > widget.fromAsset.balance) {
      return 'Số dư không đủ để thực hiện chuyển tiền';
    }
    
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _selectedToAsset != null) {
      final amount = double.parse(
        _amountController.text.replaceAll(',', ''),
      );
      
      context.read<AssetBloc>().add(
        AssetTransferRequested(
          fromAssetId: widget.fromAsset.id,
          toAssetId: _selectedToAsset!.id,
          amount: amount,
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
    final otherAssets = widget.availableAssets
        .where((asset) => asset.id != widget.fromAsset.id)
        .toList();

    if (otherAssets.isEmpty) {
      return AlertDialog(
        title: const Text('Không thể chuyển tiền'),
        content: const Text(
          'Bạn cần có ít nhất 2 tài sản để thực hiện chuyển tiền.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      );
    }

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chuyển tiền giữa tài sản',
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
                      // From asset info - Compact
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Từ tài sản:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    widget.fromAsset.name,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Số dư: ${_formatCurrency(widget.fromAsset.balance.toStringAsFixed(0))} VNĐ',
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

                      // To asset dropdown - Compact
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Đến tài sản:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Asset>(
                              value: _selectedToAsset,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              items: otherAssets.map((asset) {
                                return DropdownMenuItem<Asset>(
                                  value: asset,
                                  child: Text(
                                    asset.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (asset) {
                                setState(() {
                                  _selectedToAsset = asset;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn tài sản đích';
                                }
                                return null;
                              },
                            ),
                            // Hiển thị số dư của tài sản được chọn
                            if (_selectedToAsset != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Số dư: ${_formatCurrency(_selectedToAsset!.balance.toStringAsFixed(0))} VNĐ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền chuyển',
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Chuyển tiền'),
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