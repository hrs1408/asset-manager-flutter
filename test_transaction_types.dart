import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/di/service_locator.dart';
import 'lib/features/expenses/domain/entities/transaction.dart';
import 'lib/features/expenses/domain/entities/transaction_type.dart';
import 'lib/features/expenses/domain/entities/deposit_source.dart';
import 'lib/features/expenses/presentation/widgets/transaction_item.dart';
import 'lib/features/expenses/presentation/bloc/transaction_bloc.dart';
import 'lib/features/assets/presentation/bloc/asset_bloc.dart';
import 'lib/features/expenses/presentation/bloc/category_bloc.dart';

class TransactionTypesDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo các loại giao dịch',
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TransactionBloc>(
            create: (context) => sl<TransactionBloc>(),
          ),
          BlocProvider<AssetBloc>(
            create: (context) => sl<AssetBloc>(),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => sl<CategoryBloc>(),
          ),
        ],
        child: TransactionTypesScreen(),
      ),
    );
  }
}

class TransactionTypesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo các loại giao dịch'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Các loại giao dịch trong ứng dụng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ứng dụng hỗ trợ 3 loại giao dịch chính với cách hiển thị khác nhau',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Chi tiêu
          _buildSectionHeader('1. Giao dịch Chi tiêu (Expense)', Colors.red),
          _buildDescription('Trừ tiền từ tài sản để chi tiêu, hiển thị với màu đỏ và dấu trừ'),
          TransactionItem(
            transaction: Transaction(
              id: 'expense_demo',
              userId: 'demo',
              assetId: 'seabank',
              categoryId: 'food',
              amount: 70000,
              description: 'Ăn trưa hôm nay',
              date: DateTime.now(),
              type: TransactionType.expense,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Nộp tiền
          _buildSectionHeader('2. Giao dịch Nộp tiền (Deposit)', Colors.green),
          _buildDescription('Cộng tiền vào tài sản từ nguồn bên ngoài, hiển thị với màu xanh và dấu cộng'),
          TransactionItem(
            transaction: Transaction(
              id: 'deposit_demo',
              userId: 'demo',
              assetId: 'seabank',
              categoryId: '',
              amount: 10000000,
              description: '',
              date: DateTime.now(),
              type: TransactionType.deposit,
              depositSource: DepositSource.salary,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Chuyển tiền
          _buildSectionHeader('3. Giao dịch Chuyển tiền (Transfer)', Colors.blue),
          _buildDescription('Chuyển tiền giữa các tài sản, tạo 2 giao dịch liên kết với màu sắc khác nhau'),
          
          Text(
            'Tài sản nguồn (trừ tiền):',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 4),
          TransactionItem(
            transaction: Transaction(
              id: 'transfer_out_demo',
              userId: 'demo',
              assetId: 'test1',
              categoryId: '',
              amount: -10000000, // Số âm cho tài sản nguồn
              description: '',
              date: DateTime.now(),
              type: TransactionType.transfer,
              toAssetId: 'test2',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
          
          SizedBox(height: 8),
          
          Text(
            'Tài sản đích (nhận tiền):',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 4),
          TransactionItem(
            transaction: Transaction(
              id: 'transfer_in_demo',
              userId: 'demo',
              assetId: 'test2',
              categoryId: '',
              amount: 10000000, // Số dương cho tài sản đích
              description: '',
              date: DateTime.now(),
              type: TransactionType.transfer,
              toAssetId: 'test1',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
          
          SizedBox(height: 32),
          
          // Chú thích
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Chú thích',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildLegendItem('🔴', 'Chi tiêu: Màu đỏ, dấu trừ, hiển thị danh mục'),
                  _buildLegendItem('🟢', 'Nộp tiền: Màu xanh, dấu cộng, hiển thị nguồn tiền'),
                  _buildLegendItem('🔵', 'Chuyển tiền: Màu xanh dương, hiển thị tài sản liên quan'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildDescription(String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Initialize service locator
  runApp(TransactionTypesDemo());
}