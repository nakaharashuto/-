import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  Id pasword = Isar.autoIncrement;
  late String text;
  
}
