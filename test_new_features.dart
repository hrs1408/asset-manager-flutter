import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/di/service_locator.dart' as di;
import 'lib/features/assets/presentation/bloc/asset_bloc.dart';
import 'lib/features/assets/presentation/bloc/asset_event.dart';
import 'lib/features/assets/presentation/bloc/asset_state.dart';
import 'lib/features/assets/domain/entities/asset.dart';
import 'lib/features/assets/domain/entities/asset_type.dart';
import 'lib/features/assets/presentation/widgets/deposit_dialog.dart';
import 'lib/features/assets/presentation/widgets/transfer_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.init();
  
  runApp(TestNewFeaturesApp());
}

class TestNewFeaturesApp extends StatelessWidget {
  const TestNewFeaturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test New Features',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => di.sl<AssetBloc>(),
        child: const TestNewFeaturesScreen(),
      ),
    );
  }
}

class TestNewFeaturesScreen extends StatelessWidget {
  const TestNewFeaturesScreen({super.key});

  // Mock assets for testing
  static final List<Asset> mockAssets = [
    Asset(
      id: 'asset1',
      userId: 'user1',
      name: 'Tài khoản Vietcombank',
      type: AssetType.paymentAccount,
      balance: 5000000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Asset(
      id: 'asset2',
      userId: 'user1',
      name: 'Tài khoản tiết kiệm',
      type: AssetType.savingsAccount,
      balance: 10000000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test New Features'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AssetBloc, AssetState>(
        listener: (context, state) {
          if (state is AssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AssetOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Success: ${state.message}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Test Deposit & Transfer Features',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Test Deposit Dialog
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DepositDialog(asset: mockAssets[0]),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Test Deposit Dialog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Test Transfer Dialog
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TransferDialog(
                      fromAsset: mockAssets[0],
                      availableAssets: mockAssets,
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Test Transfer Dialog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              
              // Test Direct Deposit
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AssetBloc>().add(
                    const AssetDepositWithDetailsRequested(
                      assetId: 'asset1',
                      amount: 100000,
                      depositSource: 'salary',
                      notes: 'Test deposit from salary',
                    ),
                  );
                },
                icon: const Icon(Icons.attach_money),
                label: const Text('Test Direct Deposit (100,000 VND)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Test Direct Transfer
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AssetBloc>().add(
                    const AssetTransferRequested(
                      fromAssetId: 'asset1',
                      toAssetId: 'asset2',
                      amount: 50000,
                      notes: 'Test transfer between assets',
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Test Direct Transfer (50,000 VND)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              
              // Status
              BlocBuilder<AssetBloc, AssetState>(
                builder: (context, state) {
                  if (state is AssetOperationLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Processing...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Ready to test features',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}