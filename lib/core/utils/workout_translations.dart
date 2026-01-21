/// Utility functions for translating workout-related enums to Portuguese

/// Translate goal/objective enum value to Portuguese
String translateGoal(String? goal) {
  if (goal == null || goal.isEmpty) return '';
  switch (goal.toLowerCase()) {
    case 'hypertrophy':
      return 'Hipertrofia';
    case 'strength':
      return 'Força';
    case 'fat_loss':
      return 'Emagrecimento';
    case 'endurance':
      return 'Resistência';
    case 'functional':
      return 'Funcional';
    case 'general_fitness':
      return 'Condicionamento';
    default:
      return goal;
  }
}

/// Translate difficulty enum value to Portuguese
String translateDifficulty(String? difficulty) {
  if (difficulty == null || difficulty.isEmpty) return '';
  switch (difficulty.toLowerCase()) {
    case 'beginner':
      return 'Iniciante';
    case 'intermediate':
      return 'Intermediário';
    case 'advanced':
      return 'Avançado';
    default:
      return difficulty;
  }
}

/// Translate split type enum value to Portuguese
String translateSplitType(String? splitType) {
  if (splitType == null || splitType.isEmpty) return '';
  switch (splitType.toLowerCase()) {
    case 'abc':
      return 'ABC';
    case 'abcd':
      return 'ABCD';
    case 'abcde':
      return 'ABCDE';
    case 'fullbody':
    case 'full_body':
      return 'Full Body';
    case 'upper_lower':
      return 'Upper/Lower';
    case 'push_pull_legs':
    case 'ppl':
      return 'Push/Pull/Legs';
    case 'custom':
      return 'Personalizado';
    default:
      return splitType.toUpperCase();
  }
}
