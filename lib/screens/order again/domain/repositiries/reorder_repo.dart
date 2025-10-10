import 'package:cureeit_user_app/screens/order%20again/domain/entities/reorderEntity.dart';



abstract class ReorderRepository {
  Future<bool> reorderItems(ReorderEntity reorderEntity);
}
