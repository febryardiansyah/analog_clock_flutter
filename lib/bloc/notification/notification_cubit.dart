import 'package:analog_clock_flutter/services/notification_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  final _repo = NotificationService();

  Future<void> setAlarm(TimeOfDay selectedTime)async{
    try{
      await _repo.showNotification(selectedTime);
      emit(NotificationSuccess());
    }catch(e){
      print(e);
      emit(NotificationFailure('Something wrong'));
    }
  }
}
