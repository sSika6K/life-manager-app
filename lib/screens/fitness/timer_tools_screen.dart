import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/custom_card.dart';

class TimerToolsScreen extends StatefulWidget {
  const TimerToolsScreen({Key? key}) : super(key: key);

  @override
  State<TimerToolsScreen> createState() => _TimerToolsScreenState();
}

class _TimerToolsScreenState extends State<TimerToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outils d\'entraînement'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'Chronomètre'),
            Tab(icon: Icon(Icons.hourglass_empty), text: 'Minuteur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StopwatchTab(),
          CountdownTab(),
        ],
      ),
    );
  }
}

// ========== CHRONOMÈTRE ==========
class StopwatchTab extends StatefulWidget {
  const StopwatchTab({Key? key}) : super(key: key);

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  List<String> _laps = [];

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
      _laps.clear();
    });
  }

  void _lap() {
    if (_isRunning) {
      setState(() {
        _laps.insert(0, _formatTime(_seconds));
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Affichage du temps
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(_seconds),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Boutons de contrôle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton Tour
              FloatingActionButton.extended(
                onPressed: _isRunning ? _lap : null,
                backgroundColor: _isRunning ? Colors.blue : Colors.grey,
                icon: const Icon(Icons.flag),
                label: const Text('Tour'),
              ),
              
              // Bouton Start/Stop
              FloatingActionButton.large(
                onPressed: _startStop,
                backgroundColor: _isRunning ? Colors.orange : Colors.green,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 40),
              ),
              
              // Bouton Reset
              FloatingActionButton.extended(
                onPressed: !_isRunning && _seconds > 0 ? _reset : null,
                backgroundColor: !_isRunning && _seconds > 0 ? Colors.red : Colors.grey,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Liste des tours
          if (_laps.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, index) {
                  return CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tour ${_laps.length - index}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _laps[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ========== MINUTEUR ==========
class CountdownTab extends StatefulWidget {
  const CountdownTab({Key? key}) : super(key: key);

  @override
  State<CountdownTab> createState() => _CountdownTabState();
}

class _CountdownTabState extends State<CountdownTab> {
  Timer? _timer;
  int _totalSeconds = 60; // Par défaut 1 minute
  int _remainingSeconds = 60;
  bool _isRunning = false;
  
  final _minutesController = TextEditingController(text: '1');
  final _secondsController = TextEditingController(text: '0');

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_remainingSeconds > 0) {
        setState(() => _isRunning = true);
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              _timer?.cancel();
              _isRunning = false;
              _showTimeUpDialog();
            }
          });
        });
      }
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _setTime() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final total = (minutes * 60) + seconds;
    
    if (total > 0) {
      setState(() {
        _totalSeconds = total;
        _remainingSeconds = total;
      });
      Navigator.pop(context);
    }
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Temps écoulé !'),
        content: const Text('Votre minuteur est terminé !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSetTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir le temps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Secondes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _QuickTimeButton(
                  label: '30s',
                  onTap: () {
                    _minutesController.text = '0';
                    _secondsController.text = '30';
                  },
                ),
                _QuickTimeButton(
                  label: '1min',
                  onTap: () {
                    _minutesController.text = '1';
                    _secondsController.text = '0';
                  },
                ),
                _QuickTimeButton(
                  label: '2min',
                  onTap: () {
                    _minutesController.text = '2';
                    _secondsController.text = '0';
                  },
                ),
                _QuickTimeButton(
                  label: '5min',
                  onTap: () {
                    _minutesController.text = '5';
                    _secondsController.text = '0';
                  },
                ),
                _QuickTimeButton(
                  label: '10min',
                  onTap: () {
                    _minutesController.text = '10';
                    _secondsController.text = '0';
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _setTime,
            child: const Text('Définir'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    if (_totalSeconds == 0) return 0;
    return _remainingSeconds / _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          
          // Affichage circulaire du temps
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: _getProgress(),
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10 ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds <= 10 ? Colors.red : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: !_isRunning ? _showSetTimeDialog : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifier'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Boutons de contrôle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton Start/Stop
              FloatingActionButton.large(
                onPressed: _remainingSeconds > 0 ? _startStop : null,
                backgroundColor: _isRunning ? Colors.orange : Colors.green,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 40),
              ),
              
              // Bouton Reset
              FloatingActionButton.extended(
                onPressed: !_isRunning && _remainingSeconds != _totalSeconds ? _reset : null,
                backgroundColor: !_isRunning && _remainingSeconds != _totalSeconds ? Colors.red : Colors.grey,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
