import 'package:cureeit_user_app/screens/order%20again/domain/entities/reorderEntity.dart';
import 'package:cureeit_user_app/screens/order%20again/domain/repositiries/reorder_repo.dart';


class ReorderUseCase {
  final ReorderRepository repository;

  ReorderUseCase(this.repository);

  Future<bool> call(ReorderEntity reorderEntity) async {
    return await repository.reorderItems(reorderEntity);
  }
}
