import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../../../services/save_manager.dart';

/// SaveManagerWidget provides save/load functionality to the game screen
class SaveManagerWidget extends StatelessWidget {
  final GameState gameState;
  
  const SaveManagerWidget({
    super.key,
    required this.gameState,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSaveSection(),
          const SizedBox(height: 12),
          _buildLoadSection(),
          const SizedBox(height: 12),
          _buildResetSection(),
        ],
      ),
    );
  }
  
  /// Save button section
  Widget _buildSaveSection() {
    final saveManager = gameState.saveManager;
    
    return ElevatedButton.icon(
      onPressed: () => _handleSave(saveManager),
      icon: const Icon(Icons.cloud_upload_outlined),
      label: const Text('💾 Save Game'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
  
  /// Load button section
  Widget _buildLoadSection() {
    final saveManager = gameState.saveManager;
    
    return ElevatedButton.icon(
      onPressed: () => _handleLoad(saveManager),
      icon: const Icon(Icons.cloud_download_outlined),
      label: const Text('☁️ Load Game'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
  
  /// Reset button section
  Widget _buildResetSection() {
    return OutlinedButton.icon(
      onPressed: () => _handleReset(),
      icon: const Icon(Icons.delete_outline),
      label: const Text('🗑️ Clear Save'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade800,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
  
  void _handleSave(SaveManager saveManager) async {
    try {
      await saveManager.saveGameState(gameState);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Game saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Update local state
      final now = DateTime.now();
      gameState._totalSessionsSinceSave++;
      gameState._lastSaveTime = now;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _handleLoad(SaveManager saveManager) async {
    final savedState = await saveManager.getGameState();
    
    if (savedState != null && savedState['inCurrentSession'] == true) {
      // Load the saved progress
      gameState._score = int.parse(savedState['score'].toString());
      gameState._totalTaps = int.parse(savedState['totalTaps'].toString());
      gameState._scoreMultiplier = 
          double.parse(savedState['scoreMultiplier'].toString());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Game loaded from save!'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Recalculate multiplier based on taps
      _recalculateMultiplier(savedState['totalTaps'] ?? 0);
    } else if (savedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No save found. Start a new game!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Save is from previous session - show prompt
      await _showLoadSessionPrompt(savedState);
    }
  }
  
  void _recalculateMultiplier(int taps) {
    final multiplier = AppConstants.scoreMultiplierBase + 
      (taps ~/ 100).clamp(0, AppConstants.maxScoreMultiplier - AppConstants.scoreMultiplierBase) * 0.1;
    gameState._scoreMultiplier = min(multiplier, AppConstants.maxScoreMultiplier);
    notifyListeners();
  }
  
  Future<void> _showLoadSessionPrompt(Map<String, dynamic> savedState) async {
    final saveTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(savedState['timestamp'].toString())
    );
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Previous Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 48),
            const SizedBox(height: 16),
            Text('This save is from ${saveTime.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            Text('Score at time of save: ${int.parse(savedState['score'].toString())} points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Load the old session
              gameState._score = int.parse(savedState['score'].toString());
              gameState._totalTaps = int.parse(savedState['totalTaps'].toString());
              gameState._scoreMultiplier = 
                  double.parse(savedState['scoreMultiplier'].toString());
              _recalculateMultiplier(savedState['totalTaps'] ?? 0);
              
              Navigator.pop(context, true);
            },
            child: const Text('Load Anyway'),
          ),
        ],
      ),
    );
  }
  
  void _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text('This will delete your save and start a new game.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final saveManager = gameState.saveManager;
      await saveManager.clearSaves();
      
      // Reset game state
      gameState.resetGame();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Game has been reset'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
