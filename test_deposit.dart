import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/core/di/service_locator.dart' as di;
import 'lib/features/assets/presentation/bloc/asset_bloc.dart';
import 'lib/features/assets/presentation/bloc/asset_event.dart';
import 'lib/features/assets/presentation/bloc/asset_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.init();
  
  runApp(TestDepositApp());
}

class TestDepositApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Deposit Feature',
      home: BlocProvider(
        create: (context) => di.sl<AssetBloc>(),
        child: TestDepositScreen(),
      ),
    );
  }
}

class TestDepositScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Deposit Feature'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Test Deposit Feature',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Test deposit with dummy asset ID
                  context.read<AssetBloc>().add(
                    AssetDepositRequested(
                      assetId: 'test-asset-id',
                      amount: 100000,
                    ),
                  );
                },
                child: Text('Test Deposit 100,000 VND'),
              ),
              SizedBox(height: 20),
              BlocBuilder<AssetBloc, AssetState>(
                builder: (context, state) {
                  if (state is AssetOperationLoading) {
                    return CircularProgressIndicator();
                  }
                  return Text('Ready to test');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}