part of 'dashboard_bloc.dart';

sealed class DashboardEvent {
  const DashboardEvent();
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}
