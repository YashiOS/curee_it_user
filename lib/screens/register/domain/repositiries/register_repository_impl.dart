import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/register/domain/entities/registerEntity.dart';
import 'package:cureeit_user_app/screens/register/domain/repositiries/register_repository.dart';

class RegisterRepositoryImpl extends registerRepository{
  final ApiService apiService;

  RegisterRepositoryImpl({required this.apiService});
  @override
  Future<void> registerUser(RegisterEntity register) async{
    final response=await apiService.post(
      "/auth/user/verify",
      body:register.toJson() 
      );
      if(response.statusCode==200){
        return;
      }
      throw Exception("failed to register");
  }
  
}