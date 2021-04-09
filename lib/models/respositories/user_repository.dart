// Interface
abstract class UserRepository<T> {
  Future<T> register();
  Future<T> signIn();
  Future<void> signOut();
}