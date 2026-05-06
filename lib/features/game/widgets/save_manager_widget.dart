import 'package:flutter/material.dart';
import '../models/game_state.dart';

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
          _buildSaveSection(context),
          const SizedBox(height: 12),
          _buildLoadSection(context),
          const SizedBox(height: 12),
          _buildResetSection(context),
        ],
      ),
    );
  }
  
  /// Save button section
  Widget _buildSaveSection(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleSave(context),
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
  Widget _buildLoadSection(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleLoad(context),
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
  Widget _buildResetSection(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleReset(context),
      icon: const Icon(Icons.delete_outline),
      label: const Text('🗑️ Clear Save'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade800,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
  
  void _handleSave(BuildContext context) async {
    final saveManager = gameState.saveManager;
    try {
      await saveManager.saveGameState(gameState);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Game saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _handleLoad(BuildContext context) async {
    final saveManager = gameState.saveManager;
    final savedState = await saveManager.getGameState();
    
    if (savedState != null && savedState['inCurrentSession'] == true) {
      // Load the saved progress
      final taps = int.parse(savedState['totalTaps'].toString());
      gameState.loadFromSave(
        score: int.parse(savedState['score'].toString()),
        totalTaps: taps,
        scoreMultiplier: double.parse(savedState['scoreMultiplier'].toString()),
      );
      _recalculateMultiplier(taps);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Game loaded from save!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (savedState == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No save found. Start a new game!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Save is from previous session - show prompt
      if (context.mounted) {
        await _showLoadSessionPrompt(context, savedState);
      }
    }
  }
  
  void _recalculateMultiplier(int taps) {
    gameState.recalculateMultiplier();
  }
  
  Future<void> _showLoadSessionPrompt(BuildContext context, Map<String, dynamic> savedState) async {
    final saveTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(savedState['timestamp'].toString())
    );
    
    final confirmed = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load Anyway'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Load the old session
      final taps = int.parse(savedState['totalTaps'].toString());
      gameState.loadFromSave(
        score: int.parse(savedState['score'].toString()),
        totalTaps: taps,
        scoreMultiplier: double.parse(savedState['scoreMultiplier'].toString()),
      );
      _recalculateMultiplier(taps);
    }
  }
  
  Future<void> _handleReset(BuildContext context) async {
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
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Game has been reset'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
