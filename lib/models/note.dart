import '../screens/session.dart';

class Note {
  int id;
  String dateCreated;
  String dateModified;
  String text;
  String scribbles;
  String scribblePreview;
  List<Stroke> scribblePreviewStrokes;

  Note({
    required this.id,
    required this.dateCreated,
    required this.dateModified,
    required this.text,
    required this.scribbles,
    required this.scribblePreview,
    required this.scribblePreviewStrokes,
  });
}
