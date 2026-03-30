import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/game_time_provider.dart';

mixin GameTimeMixin<T extends StatefulWidget> on State<T> {
  late String gameId;

  @override
  void initState() {
    super.initState();
    _startGameSession();
  }

  @override
  void dispose() {
    _endGameSession();
    super.dispose();
  }

  void _startGameSession() {
    final provider = Provider.of<GameTimeProvider>(context, listen: false);
    provider.startGameSession(gameId);
  }

  void _endGameSession() {
    final provider = Provider.of<GameTimeProvider>(context, listen: false);
    provider.endGameSession(gameId);
  }
}
