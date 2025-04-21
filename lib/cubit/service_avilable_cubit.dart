import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'service_avilable_state.dart';

class ServiceAvilableCubit extends Cubit<ServiceAvilableState> {
  ServiceAvilableCubit() : super(ServiceAvilableInitial());

   bool ServiceAvilable=false;

   bool get isServiceAvilable=>ServiceAvilable;

   void UpdateServiceAvilable(bool value){
    if(value==true){
        ServiceAvilable=value;
        emit(ServiceIsAvilable());
    }
    if(value==false){
      ServiceAvilable=value;
      emit(ServiceIsNotAvilable());
    }
    
   }
}
