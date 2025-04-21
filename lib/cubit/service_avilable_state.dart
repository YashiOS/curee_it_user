part of 'service_avilable_cubit.dart';

@immutable
sealed class ServiceAvilableState {}

final class ServiceAvilableInitial extends ServiceAvilableState {}

final class ServiceIsAvilable extends ServiceAvilableState{}
final class ServiceIsNotAvilable extends ServiceAvilableState{}
