import 'package:freezed_annotation/freezed_annotation.dart';

part 'five_elements.freezed.dart';
part 'five_elements.g.dart';

enum ElementType { wood, fire, earth, metal, water }

@freezed
class FiveElements with _$FiveElements {
  const factory FiveElements({
    @Default(0) int wood,
    @Default(0) int fire,
    @Default(0) int earth,
    @Default(0) int metal,
    @Default(0) int water,
  }) = _FiveElements;

  factory FiveElements.fromJson(Map<String, dynamic> json) =>
      _$FiveElementsFromJson(json);

  const FiveElements._();

  int get total => wood + fire + earth + metal + water;

  ElementType get dominant {
    final values = {
      ElementType.wood: wood,
      ElementType.fire: fire,
      ElementType.earth: earth,
      ElementType.metal: metal,
      ElementType.water: water,
    };
    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  ElementType get weakest {
    final values = {
      ElementType.wood: wood,
      ElementType.fire: fire,
      ElementType.earth: earth,
      ElementType.metal: metal,
      ElementType.water: water,
    };
    return values.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  double ratio(ElementType element) {
    if (total == 0) return 0.0;
    return switch (element) {
      ElementType.wood => wood / total,
      ElementType.fire => fire / total,
      ElementType.earth => earth / total,
      ElementType.metal => metal / total,
      ElementType.water => water / total,
    };
  }
}