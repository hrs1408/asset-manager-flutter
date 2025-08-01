import 'package:flutter/material.dart';

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<List<T>> Function(int page, int pageSize)? onLoadMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final int pageSize;
  final bool hasReachedMax;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final Widget? separator;
  final RefreshCallback? onRefresh;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.pageSize = 20,
    this.hasReachedMax = false,
    this.scrollController,
    this.padding,
    this.separator,
    this.onRefresh,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isBottomReached && !_isLoadingMore && !widget.hasReachedMax) {
      _loadMore();
    }
  }

  bool get _isBottomReached {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null) return;

    setState(() {
      _isLoadingMore = true;
      _hasError = false;
    });

    try {
      await widget.onLoadMore!(_currentPage + 1, widget.pageSize);
      _currentPage++;
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return widget.loadingWidget ??
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ??
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                'Có lỗi xảy ra khi tải dữ liệu',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _buildEmptyWidget();
    }

    Widget listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (_isLoadingMore || _hasError ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index >= widget.items.length) return const SizedBox.shrink();
        return widget.separator ?? const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          if (_hasError) {
            return _buildErrorWidget();
          } else if (_isLoadingMore) {
            return _buildLoadingIndicator();
          }
          return const SizedBox.shrink();
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}

class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final Widget? separator;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.padding,
    this.separator,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu'),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return separator ?? const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}