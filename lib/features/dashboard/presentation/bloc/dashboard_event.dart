import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDashboardData({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class RefreshDashboardData extends DashboardEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshDashboardData({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class UpdateDateRange extends DashboardEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const UpdateDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}