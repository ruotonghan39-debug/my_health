enum PostType {
  diet,
  exercise,
  weight;

  static PostType fromDb(String value) {
    switch (value) {
      case 'diet':
        return PostType.diet;
      case 'exercise':
        return PostType.exercise;
      case 'weight':
        return PostType.weight;
      default:
        return PostType.diet;
    }
  }

  String get dbValue => switch (this) {
        PostType.diet => 'diet',
        PostType.exercise => 'exercise',
        PostType.weight => 'weight',
      };
}
