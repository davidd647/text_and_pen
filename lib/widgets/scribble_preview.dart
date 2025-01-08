import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_logic.dart';
import '../screens/session.dart';
import '../models/note.dart';

class ScribblePreview extends StatefulWidget {
  const ScribblePreview({
    super.key,
    required this.note,
    required this.yDimension,
  });

  final Note note;
  final double yDimension;

  @override
  State<ScribblePreview> createState() => _ScribblePreviewState();
}

class _ScribblePreviewState extends State<ScribblePreview> {
  late ProviderSessionLogic providerSessionLogic;
  // List<Stroke> _strokes = [];

  void _startStroke(double x, double y) {
    Stroke newStroke = Stroke(actions: [PointAction(type: ActionType.moveTo, x: x, y: y)]);
    widget.note.scribblePreviewStrokes.add(newStroke);
    setState(() {});
  }

  void _moveStroke(double x, double y) {
    if (widget.note.scribblePreviewStrokes.isNotEmpty) {
      widget.note.scribblePreviewStrokes.last.actions.add(PointAction(type: ActionType.lineTo, x: x, y: y));
      setState(() {});
    }
  }

  void _endStroke(details) async {
    // providerSessionLogic.strokesJson = serializeStrokes(widget.note.scribblePreviewStrokes);

    // set the previewStrokesJson for this specific note
    int selectedIndex = providerSessionLogic.getNoteIndexFromId(widget.note.id);
    providerSessionLogic.notesList[selectedIndex].scribblePreview = serializeStrokes(
      widget.note.scribblePreviewStrokes,
    );

    // UPDATE DB WHEN SCRIBBLE IS DONE
    // providerSessionLogic.updateDb();
    providerSessionLogic.updateDbNoteById(widget.note.id);
  }

  @override
  void initState() {
    providerSessionLogic = Provider.of<ProviderSessionLogic>(context, listen: false);
    super.initState();

    int selectedIndex = providerSessionLogic.getNoteIndexFromId(widget.note.id);

    widget.note.scribblePreviewStrokes = deserializeStrokes(
      providerSessionLogic.notesList[selectedIndex].scribblePreview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      alignment: Alignment.center,
      width: widget.yDimension,
      height: widget.yDimension,
      child: Stack(
        children: [
          if (widget.note.scribblePreviewStrokes.isEmpty)
            Center(
              child: Icon(
                Icons.brush,
                color: Colors.grey[300],
                size: 50,
              ),
            ),
          GestureDetector(
            onPanDown: (details) => _startStroke(
              details.localPosition.dx,
              details.localPosition.dy,
            ),
            onPanUpdate: (details) => _moveStroke(
              details.localPosition.dx,
              details.localPosition.dy,
            ),
            onPanEnd: (details) => _endStroke(details),
            child: SizedBox(
              width: widget.yDimension,
              height: widget.yDimension,
              child: CustomPaint(
                painter: StrokePainter(strokes: widget.note.scribblePreviewStrokes),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
