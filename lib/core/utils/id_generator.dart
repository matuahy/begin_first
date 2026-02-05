import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
