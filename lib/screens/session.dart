import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:text_and_pen2/widgets/scribble_preview.dart';

import '../providers/session_logic.dart';
import '../models/note.dart';
import '../helpers/get_full_height.dart';

class Session extends StatefulWidget {
  const Session({super.key});
  static const routeName = '/session';

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  late ProviderSessionLogic providerSessionLogic;
  List<Stroke> _strokes = [];

  void _startStroke(double x, double y) {
    Stroke newStroke = Stroke(actions: [PointAction(type: ActionType.moveTo, x: x, y: y)]);
    _strokes.add(newStroke);
    setState(() {});
  }

  void _moveStroke(double x, double y) {
    if (_strokes.isNotEmpty) {
      _strokes.last.actions.add(PointAction(type: ActionType.lineTo, x: x, y: y));
      setState(() {});
    }
  }

  void _endStroke(details) {
    providerSessionLogic.strokesJson = serializeStrokes(_strokes);

    // UPDATE DB WHEN SCRIBBLE IS DONE
    providerSessionLogic.updateDb();
  }

  void _undoPreviousStroke() {
    if (_strokes.isNotEmpty) _strokes.removeLast();
    _endStroke('');
    setState(() {});
  }

  void _clearPreviewStrokes() {
    providerSessionLogic.clearCurrentPreview();
    setState(() {});
  }

  void _navBack() {
    Navigator.of(context).pop(); // Still go back afterward

    Note tmpNote = providerSessionLogic.getNoteFromId(providerSessionLogic.selectedNoteId);

    if (tmpNote.scribblePreviewStrokes.isEmpty && tmpNote.text == '' && _strokes.isEmpty) {
      // delete the current note...
      providerSessionLogic.deleteById(tmpNote.id);
    }
  }

  @override
  void initState() {
    providerSessionLogic = Provider.of<ProviderSessionLogic>(context, listen: false);
    super.initState();

    _strokes = deserializeStrokes(providerSessionLogic.strokesJson);

    providerSessionLogic.textEditingController.addListener(() {
      // UPDATE DB WHEN TYPING IS DONE
      providerSessionLogic.updateDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fullWidth = MediaQuery.of(context).size.width;
    final double fullHeight = getFullHeight(MediaQuery.of(context));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _navBack();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Text and Pen'),
        actions: [
          Icon(Icons.brush),
          SizedBox(width: 10),
          Switch(
            activeColor: Colors.blue,
            value: providerSessionLogic.isKeyboardMode,
            onChanged: (val) {
              setState(() {
                providerSessionLogic.isKeyboardMode = val;
              });
            },
          ),
          SizedBox(width: 10),
          Icon(Icons.keyboard),
          SizedBox(width: 50),
        ],
      ),
      body: SizedBox(
        height: fullHeight,
        width: fullWidth,
        child: Stack(
          children: [
            Positioned(
              top: 21,
              left: 21,
              bottom: 21,
              right: 21,
              child: IgnorePointer(
                ignoring: !providerSessionLogic.isKeyboardMode, // ignore the drawing layer if it's painting mode...
                // Because we added this GestureDetector here,
                // tapping anywhere will refocus the TextField at its last character
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: providerSessionLogic.textEditingController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null, // or an integer > 1
                            decoration: InputDecoration(
                              hintText: "Insert your note",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: providerSessionLogic.isKeyboardMode, // ignore the drawing layer if it's painting mode...
                child: GestureDetector(
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
                    width: fullWidth,
                    height: fullHeight,
                    child: CustomPaint(
                      // painter: StrokePainter(strokes: deserializeStrokes(_strokesJson)),
                      painter: StrokePainter(strokes: _strokes),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _clearPreviewStrokes();
                },
                child: Container(
                  width: 150,
                  height: 25,
                  alignment: Alignment.center,
                  color: Colors.grey[300],
                  child: Text('Clear Preview'),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ScribblePreview(
                note: providerSessionLogic.getNoteFromId(providerSessionLogic.selectedNoteId),
                yDimension: 150,
              ),
            ),
            if (!providerSessionLogic.isKeyboardMode)
              Positioned(
                left: 50,
                bottom: 50,
                child: GestureDetector(
                  onTap: () {
                    _undoPreviousStroke();
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.undo, size: 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Stroke {
  List<PointAction> actions;

  Stroke({required this.actions});

  // Method to convert a stroke into a Path object for drawing
  Path toPath() {
    Path path = Path();
    for (var action in actions) {
      if (action.type == ActionType.moveTo) {
        path.moveTo(action.x, action.y);
      } else if (action.type == ActionType.lineTo) {
        path.lineTo(action.x, action.y);
      }
    }
    return path;
  }

  // Serialize the Stroke object to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
        "actions": actions.map((action) => action.toJson()).toList(),
      };

  // Deserialize the Stroke object from a Map (from JSON decoding)
  static Stroke fromJson(Map<String, dynamic> json) => Stroke(
        actions: List<PointAction>.from(json["actions"].map((x) => PointAction.fromJson(x))),
      );
}

class PointAction {
  ActionType type;
  double x, y;

  PointAction({required this.type, required this.x, required this.y});

  // Serialize the PointAction object to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
        "type": type.toString(),
        "x": x,
        "y": y,
      };

  // Deserialize the PointAction object from a Map (from JSON decoding)
  static PointAction fromJson(Map<String, dynamic> json) => PointAction(
        type: ActionType.values.firstWhere((e) => e.toString() == json["type"]),
        x: (json["x"] as num).toDouble(),
        y: (json["y"] as num).toDouble(),
      );
}

enum ActionType { moveTo, lineTo }

/////////////////
/////////////////
/////////////////

class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;

  StrokePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      canvas.drawPath(stroke.toPath(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

String serializeStrokes(List<Stroke> strokes) {
  // Convert the list of Stroke objects into a list of map objects
  List<Map<String, dynamic>> strokesJson = strokes.map((stroke) => stroke.toJson()).toList();
  // Encode the list of maps as a JSON string
  return jsonEncode(strokesJson);
}

List<Stroke> deserializeStrokes(String json) {
  if (json == '') return [];
  var decoded = jsonDecode(json) as List;
  List<Stroke> strokes = decoded.map<Stroke>((strokeJson) => Stroke.fromJson(strokeJson)).toList();
  return strokes;
}
