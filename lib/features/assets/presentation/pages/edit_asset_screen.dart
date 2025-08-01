import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';
import '../bloc/asset_state.dart';
import '../widgets/asset_type_dropdown.dart';
import '../widgets/deposit_dialog.dart';
import '../widgets/transfer_dialog.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/auth_button.dart';

class EditAssetScreen extends StatefulWidget {
  final Asset asset;

  const EditAssetScreen({
    super.key,
    required this.asset,
  });

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AssetType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _balanceController = TextEditingController(
      text: _formatCurrency(widget.asset.balance.toStringAsFixed(0)),
    );
    _selectedType = widget.asset.type;
    
    // Thêm listener để theo dõi thay đổi
    _nameController.addListener(() => setState(() {}));
    _balanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên tài sản';
    }
    if (value.trim().length < 2) {
      return 'Tên tài sản phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validateBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số dư';
    }
    
    final balance = double.tryParse(value.replaceAll(',', ''));
    if (balance == null) {
      return 'Số dư không hợp lệ';
    }
    
    if (balance < 0) {
      return 'Số dư không thể âm';
    }
    
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final balance = double.parse(
        _balanceController.text.replaceAll(',', ''),
      );
      
      final updatedAsset = widget.asset.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: balance,
        updatedAt: DateTime.now(),
      );

      context.read<AssetBloc>().add(
            AssetUpdateRequested(asset: updatedAsset),
          );
    }
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

  bool _hasChanges() {
    final currentBalance = double.tryParse(
      _balanceController.text.replaceAll(',', ''),
    ) ?? 0;
    
    // So sánh với độ chính xác để tránh lỗi floating point
    final balanceChanged = (currentBalance - widget.asset.balance).abs() > 0.01;
    
    return _nameController.text.trim() != widget.asset.name ||
           _selectedType != widget.asset.type ||
           balanceChanged;
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => DepositDialog(asset: widget.asset),
    );
  }

  void _showTransferDialog() {
    final currentState = context.read<AssetBloc>().state;
    if (currentState is AssetLoaded) {
      showDialog(
        context: context,
        builder: (context) => TransferDialog(
          fromAsset: widget.asset,
          availableAssets: currentState.assets,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải danh sách tài sản'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa tài sản'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: BlocListener<AssetBloc, AssetState>(
        listener: (context, state) {
          if (state is AssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AssetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Nếu là thao tác nộp tiền, cập nhật lại form với số dư mới
            if (state.message.contains('Nộp tiền thành công')) {
              final updatedAsset = state.assets.firstWhere(
                (asset) => asset.id == widget.asset.id,
                orElse: () => widget.asset,
              );
              setState(() {
                _balanceController.text = _formatCurrency(updatedAsset.balance.toStringAsFixed(0));
              });
            } else {
              // Các thao tác khác thì đóng màn hình
              Navigator.pop(context);
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(
                  Icons.edit,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chỉnh sửa tài sản',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cập nhật thông tin tài sản của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Asset Name Field
                AuthTextField(
                  controller: _nameController,
                  labelText: 'Tên tài sản',
                  hintText: 'Ví dụ: Tài khoản Vietcombank',
                  prefixIcon: Icons.label,
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                // Asset Type Dropdown
                AssetTypeDropdown(
                  selectedType: _selectedType,
                  onChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Balance Field
                AuthTextField(
                  controller: _balanceController,
                  labelText: 'Số dư hiện tại',
                  hintText: 'Nhập số dư',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: _validateBalance,
                  onChanged: (value) {
                    final formatted = _formatCurrency(value);
                    if (formatted != value) {
                      _balanceController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn vị: VNĐ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showDepositDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Nộp tiền'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showTransferDialog,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Chuyển tiền'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                BlocBuilder<AssetBloc, AssetState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: 'Cập nhật tài sản',
                      onPressed: _hasChanges() ? _onSubmit : null,
                      isLoading: state is AssetOperationLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài sản "${widget.asset.name}"? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
              context.read<AssetBloc>().add(
                    AssetDeleteRequested(assetId: widget.asset.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}