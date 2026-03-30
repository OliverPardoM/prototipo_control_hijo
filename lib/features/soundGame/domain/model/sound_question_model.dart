// lib/models/sound_question_model.dart

class SoundOption {
  final String id;
  final String emoji;
  final String label;

  const SoundOption({
    required this.id,
    required this.emoji,
    required this.label,
  });
}

class SoundQuestion {
  final String id;
  final String audioAsset; // e.g. 'assets/audio/dog.mp3'
  final String hint; // shown under the sound button, e.g. '¿Qué animal es?'
  final String correctId;
  final List<SoundOption> options;

  const SoundQuestion({
    required this.id,
    required this.audioAsset,
    required this.hint,
    required this.correctId,
    required this.options,
  });
}

// ─── All questions ────────────────────────────────────────────
// Options are shuffled at runtime; only the pool is defined here.
class SoundGameData {
  static const List<SoundQuestion> all = [
    SoundQuestion(
      id: 'q_dog',
      audioAsset: 'assets/audio/dog.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'dog',
      options: [
        SoundOption(id: 'dog', emoji: '🐶', label: 'Perro'),
        SoundOption(id: 'cat', emoji: '🐱', label: 'Gato'),
        SoundOption(id: 'cow', emoji: '🐮', label: 'Vaca'),
        SoundOption(id: 'duck', emoji: '🦆', label: 'Pato'),
      ],
    ),
    SoundQuestion(
      id: 'q_cat',
      audioAsset: 'assets/audio/cat.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'cat',
      options: [
        SoundOption(id: 'cat', emoji: '🐱', label: 'Gato'),
        SoundOption(id: 'dog', emoji: '🐶', label: 'Perro'),
        SoundOption(id: 'frog', emoji: '🐸', label: 'Rana'),
        SoundOption(id: 'bird', emoji: '🐦', label: 'Pájaro'),
      ],
    ),
    SoundQuestion(
      id: 'q_cow',
      audioAsset: 'assets/audio/cow.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'cow',
      options: [
        SoundOption(id: 'cow', emoji: '🐮', label: 'Vaca'),
        SoundOption(id: 'sheep', emoji: '🐑', label: 'Oveja'),
        SoundOption(id: 'pig', emoji: '🐷', label: 'Cerdo'),
        SoundOption(id: 'horse', emoji: '🐴', label: 'Caballo'),
      ],
    ),
    SoundQuestion(
      id: 'q_duck',
      audioAsset: 'assets/audio/duck.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'duck',
      options: [
        SoundOption(id: 'duck', emoji: '🦆', label: 'Pato'),
        SoundOption(id: 'bird', emoji: '🐦', label: 'Pájaro'),
        SoundOption(id: 'frog', emoji: '🐸', label: 'Rana'),
        SoundOption(id: 'cat', emoji: '🐱', label: 'Gato'),
      ],
    ),
    SoundQuestion(
      id: 'q_frog',
      audioAsset: 'assets/audio/frog.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'frog',
      options: [
        SoundOption(id: 'frog', emoji: '🐸', label: 'Rana'),
        SoundOption(id: 'duck', emoji: '🦆', label: 'Pato'),
        SoundOption(id: 'fish', emoji: '🐟', label: 'Pez'),
        SoundOption(id: 'snake', emoji: '🐍', label: 'Serpiente'),
      ],
    ),
    SoundQuestion(
      id: 'q_bird',
      audioAsset: 'assets/audio/bird.mp3',
      hint: '¿Qué animal hace este sonido?',
      correctId: 'bird',
      options: [
        SoundOption(id: 'bird', emoji: '🐦', label: 'Pájaro'),
        SoundOption(id: 'bee', emoji: '🐝', label: 'Abeja'),
        SoundOption(id: 'cat', emoji: '🐱', label: 'Gato'),
        SoundOption(id: 'duck', emoji: '🦆', label: 'Pato'),
      ],
    ),
  ];
}
