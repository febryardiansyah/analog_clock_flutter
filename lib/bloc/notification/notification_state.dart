part of 'notification_cubit.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}
class NotificationSuccess extends NotificationState {}
class NotificationFailure extends NotificationState {
  final String msg;

  NotificationFailure(this.msg);
}
