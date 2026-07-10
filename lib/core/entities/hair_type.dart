enum HairType { type2A, type2B, type2C, type3A, type3B, type3C, type4A, type4B, type4C }

extension HairTypeLabel on HairType {
  String get label {
    switch (this) {
      case HairType.type2A:
        return '2A — Wavy';
      case HairType.type2B:
        return '2B — Wavy';
      case HairType.type2C:
        return '2C — Wavy';
      case HairType.type3A:
        return '3A — Curly';
      case HairType.type3B:
        return '3B — Curly';
      case HairType.type3C:
        return '3C — Curly';
      case HairType.type4A:
        return '4A — Coily';
      case HairType.type4B:
        return '4B — Coily';
      case HairType.type4C:
        return '4C — Coily';
    }
  }
}
