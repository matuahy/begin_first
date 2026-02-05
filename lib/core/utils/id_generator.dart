import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static final Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
