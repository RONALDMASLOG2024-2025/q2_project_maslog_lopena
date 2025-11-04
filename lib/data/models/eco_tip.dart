import 'package:equatable/equatable.dart';

enum EcoTipCategory { deviceCare, energySaving, disposal, ecoBuying }

class EcoTip extends Equatable {
  final String id;
  final String text;
  final EcoTipCategory category;
  final String? explanation; // optional local explanation
  final DateTime createdAt;
  final String? source; // optional source attribution (e.g., "PCMag", "AI-Generated")

  const EcoTip({
    required this.id,
    required this.text,
    required this.category,
    this.explanation,
    required this.createdAt,
    this.source,
  });

  EcoTip copyWith({String? explanation, String? source}) => EcoTip(
        id: id,
        text: text,
        category: category,
        explanation: explanation ?? this.explanation,
        createdAt: createdAt,
        source: source ?? this.source,
      );

  @override
  List<Object?> get props => [id, text, category, explanation, createdAt, source];
}
