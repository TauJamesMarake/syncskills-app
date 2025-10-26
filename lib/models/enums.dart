enum ProficiencyLevel { novice, intermediate, advanced, expert }

extension ProficiencyLevelX on ProficiencyLevel {
  String get name {
    switch (this) {
      case ProficiencyLevel.novice:
        return 'Novice';
      case ProficiencyLevel.intermediate:
        return 'Intermediate';
      case ProficiencyLevel.advanced:
        return 'Advanced';
      case ProficiencyLevel.expert:
        return 'Expert';
    }
  }

  static ProficiencyLevel fromString(String s) {
    switch (s.toLowerCase()) {
      case 'novice':
        return ProficiencyLevel.novice;
      case 'intermediate':
        return ProficiencyLevel.intermediate;
      case 'advanced':
        return ProficiencyLevel.advanced;
      case 'expert':
        return ProficiencyLevel.expert;
      default:
        return ProficiencyLevel.novice;
    }
  }
}

enum PrivacySetting { Public, Private }

extension PrivacySettingX on PrivacySetting {
  String get name => this == PrivacySetting.Public ? 'Public' : 'Private';
  static PrivacySetting fromString(String s) =>
      s.toLowerCase() == 'private' ? PrivacySetting.Private : PrivacySetting.Public;
}
