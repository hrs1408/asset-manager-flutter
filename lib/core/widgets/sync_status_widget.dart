import 'package:flutter/material.dart';
import 'dart:async';

import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../services/offline_cache_service.dart';

/// Widget hiển thị trạng thái sync và kết nối
class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    Key? key,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SyncService _syncService = SyncService.instance;
  final OfflineCacheService _cacheService = OfflineCacheService.instance;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true;
  int _pendingOperations = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _initializeStatus() {
    _isConnected = _connectivityService.isConnected;
    
    // Lắng nghe thay đổi kết nối
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (mounted) {
          setState(() {
            _isConnected = isConnected;
          });
        }
      },
    );

    // Cập nhật số lượng pending operations định kỳ
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updatePendingOperationsCount();
    });

    // Cập nhật ngay lập tức
    _updatePendingOperationsCount();
  }

  void _updatePendingOperationsCount() async {
    try {
      final operations = await _cacheService.getPendingSyncOperations();
      if (mounted) {
        setState(() {
          _pendingOperations = operations.length;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showDetails && _isConnected && _pendingOperations == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap ?? _showSyncDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          border: Border.all(color: _getStatusColor().withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              size: 16,
              color: _getStatusColor(),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_pendingOperations > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_pendingOperations',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (!_isConnected) {
      return Icons.wifi_off;
    } else if (_pendingOperations > 0) {
      return Icons.sync;
    } else {
      return Icons.wifi;
    }
  }

  Color _getStatusColor() {
    if (!_isConnected) {
      return Colors.red;
    } else if (_pendingOperations > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText() {
    if (!_isConnected) {
      return 'Offline';
    } else if (_pendingOperations > 0) {
      return 'Đang đồng bộ';
    } else {
      return 'Đã đồng bộ';
    }
  }

  void _showSyncDetails() {
    showDialog(
      context: context,
      builder: (context) => SyncDetailsDialog(),
    );
  }
}

/// Dialog hiển thị chi tiết trạng thái sync
class SyncDetailsDialog extends StatefulWidget {
  @override
  State<SyncDetailsDialog> createState() => _SyncDetailsDialogState();
}

class _SyncDetailsDialogState extends State<SyncDetailsDialog> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SyncService _syncService = SyncService.instance;
  final OfflineCacheService _cacheService = OfflineCacheService.instance;

  bool _isConnected = true;
  int _pendingOperations = 0;
  Map<String, int> _cacheSize = {};
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSyncDetails();
  }

  void _loadSyncDetails() async {
    _isConnected = _connectivityService.isConnected;
    
    try {
      final operations = await _cacheService.getPendingSyncOperations();
      final cacheSize = await _cacheService.getCacheSize();
      
      if (mounted) {
        setState(() {
          _pendingOperations = operations.length;
          _cacheSize = cacheSize;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync),
          SizedBox(width: 8),
          Text('Trạng thái đồng bộ'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(
            'Kết nối mạng',
            _isConnected ? 'Có kết nối' : 'Không có kết nối',
            _isConnected ? Icons.wifi : Icons.wifi_off,
            _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Thao tác chờ đồng bộ',
            '$_pendingOperations',
            Icons.pending_actions,
            _pendingOperations > 0 ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Trạng thái',
            _isSyncing ? 'Đang đồng bộ' : 'Sẵn sàng',
            _isSyncing ? Icons.sync : Icons.check_circle,
            _isSyncing ? Colors.blue : Colors.green,
          ),
          const Divider(),
          const Text(
            'Dữ liệu đã cache:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ..._cacheSize.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getCacheTypeName(entry.key)),
                Text('${entry.value} mục'),
              ],
            ),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        if (_isConnected && _pendingOperations > 0)
          ElevatedButton(
            onPressed: _isSyncing ? null : _performManualSync,
            child: _isSyncing 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Đồng bộ ngay'),
          ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text('$label: '),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _getCacheTypeName(String key) {
    switch (key) {
      case 'assets':
        return 'Tài sản';
      case 'categories':
        return 'Danh mục';
      case 'transactions':
        return 'Giao dịch';
      case 'metadata':
        return 'Metadata';
      case 'pendingSync':
        return 'Chờ đồng bộ';
      default:
        return key;
    }
  }

  void _performManualSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await _syncService.manualSync();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
        
        // Reload details
        _loadSyncDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đồng bộ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}

/// Widget nhỏ gọn chỉ hiển thị icon trạng thái
class SyncStatusIcon extends StatefulWidget {
  final VoidCallback? onTap;

  const SyncStatusIcon({Key? key, this.onTap}) : super(key: key);

  @override
  State<SyncStatusIcon> createState() => _SyncStatusIconState();
}

class _SyncStatusIconState extends State<SyncStatusIcon> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = _connectivityService.isConnected;
    
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (mounted) {
          setState(() {
            _isConnected = isConnected;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onTap ?? () {
        showDialog(
          context: context,
          builder: (context) => SyncDetailsDialog(),
        );
      },
      icon: Icon(
        _isConnected ? Icons.wifi : Icons.wifi_off,
        color: _isConnected ? Colors.green : Colors.red,
      ),
      tooltip: _isConnected ? 'Có kết nối mạng' : 'Không có kết nối mạng',
    );
  }
}