import 'package:equatable/equatable.dart';

enum EcoTipCategory { deviceCare, energySaving, disposal, ecoBuying }

class EcoTip extends Equatable {
  final String id;
  final String text;
  final EcoTipCategory category;
  final String? explanation; // optional local explanation
  final DateTime createdAt;

  const EcoTip({
    required this.id,
    required this.text,
    required this.category,
    this.explanation,
    required this.createdAt,
  });

  EcoTip copyWith({String? explanation}) => EcoTip(
        id: id,
        text: text,
        category: category,
        explanation: explanation ?? this.explanation,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, text, category, explanation, createdAt];
}
