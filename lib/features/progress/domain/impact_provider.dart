import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/eco_tip.dart';
import '../../tips/domain/tip_provider.dart';

/// Environmental impact metrics based on completed tips
class ImpactMetrics {
  final double eWastePrevented; // in kg
  final double energySaved; // in kWh
  final double co2Reduced; // in kg
  final int tipsCompleted;
  final Map<EcoTipCategory, int> categoryBreakdown;
  final List<MonthlyImpact> monthlyTrend;

  const ImpactMetrics({
    required this.eWastePrevented,
    required this.energySaved,
    required this.co2Reduced,
    required this.tipsCompleted,
    required this.categoryBreakdown,
    required this.monthlyTrend,
  });

  static const empty = ImpactMetrics(
    eWastePrevented: 0,
    energySaved: 0,
    co2Reduced: 0,
    tipsCompleted: 0,
    categoryBreakdown: {},
    monthlyTrend: [],
  );
}

class MonthlyImpact {
  final String monthLabel; // e.g., "Nov 2024"
  final int completions;
  final double eWaste;
  final double energy;

  const MonthlyImpact({
    required this.monthLabel,
    required this.completions,
    required this.eWaste,
    required this.energy,
  });
}

/// Provider for environmental impact calculations
final impactMetricsProvider = FutureProvider<ImpactMetrics>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final tipRepo = ref.watch(tipRepositoryProvider);
  
  // Get all completed tips
  final allKeys = prefs.getKeys();
  final completionKeys = allKeys
      .where((k) => k.startsWith('completed_tip_'))
      .toList()
    ..sort();

  if (completionKeys.isEmpty) {
    return ImpactMetrics.empty;
  }

  // Fetch all tips to get category breakdown
  final allTips = await tipRepo.getAllTips();
  final tipMap = <String, ({EcoTipCategory category, String? source})>{};
  
  for (var t in allTips) {
    // Parse category from string to enum
    EcoTipCategory? cat;
    try {
      cat = EcoTipCategory.values.firstWhere(
        (c) => c.name == t.category,
        orElse: () => EcoTipCategory.deviceCare,
      );
    } catch (_) {
      cat = EcoTipCategory.deviceCare;
    }
    tipMap['t${t.id.toString().padLeft(3, '0')}'] = (category: cat, source: t.source);
  }

  // Calculate metrics
  int totalCompleted = 0;
  final categoryCount = <EcoTipCategory, int>{};
  final monthlyData = <String, MonthlyImpactData>{};

  for (final key in completionKeys) {
    final tipId = prefs.getString(key);
    if (tipId == null) continue;

    totalCompleted++;

    // Category breakdown
    final tipData = tipMap[tipId];
    if (tipData != null) {
      categoryCount[tipData.category] = (categoryCount[tipData.category] ?? 0) + 1;
    }

    // Monthly breakdown - extract date from key (completed_tip_2025-11-04)
    final dateStr = key.replaceFirst('completed_tip_', '');
    try {
      final date = DateTime.parse(dateStr);
      final monthKey = '${_monthName(date.month)} ${date.year}';
      
      final existing = monthlyData[monthKey] ?? MonthlyImpactData(monthKey, 0, 0, 0);
      monthlyData[monthKey] = MonthlyImpactData(
        monthKey,
        existing.completions + 1,
        existing.eWaste + _eWastePerTip(tipData?.category),
        existing.energy + _energyPerTip(tipData?.category),
      );
    } catch (_) {
      // Invalid date format, skip
    }
  }

  // Calculate total impact
  // Base estimation: each completed tip prevents ~0.5kg e-waste over device lifetime
  final eWastePrevented = totalCompleted * 0.5;
  
  // Energy saved varies by category (kWh per tip)
  double energySaved = 0;
  for (final entry in categoryCount.entries) {
    energySaved += entry.value * _energyPerTip(entry.key);
  }
  
  // CO2 reduction (0.5 kg CO2 per kWh saved, plus manufacturing impact)
  final co2Reduced = (energySaved * 0.5) + (eWastePrevented * 2.5);

  // Monthly trend (last 6 months)
  final now = DateTime.now();
  final monthlyTrend = <MonthlyImpact>[];
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthKey = '${_monthName(month.month)} ${month.year}';
    final data = monthlyData[monthKey];
    monthlyTrend.add(MonthlyImpact(
      monthLabel: _monthName(month.month),
      completions: data?.completions ?? 0,
      eWaste: data?.eWaste ?? 0,
      energy: data?.energy ?? 0,
    ));
  }

  return ImpactMetrics(
    eWastePrevented: eWastePrevented,
    energySaved: energySaved,
    co2Reduced: co2Reduced,
    tipsCompleted: totalCompleted,
    categoryBreakdown: categoryCount,
    monthlyTrend: monthlyTrend,
  );
});

class MonthlyImpactData {
  final String monthKey;
  final int completions;
  final double eWaste;
  final double energy;

  MonthlyImpactData(this.monthKey, this.completions, this.eWaste, this.energy);
}

double _eWastePerTip(EcoTipCategory? category) {
  if (category == null) return 0.5;
  switch (category) {
    case EcoTipCategory.deviceCare:
      return 0.7; // Extends device life
    case EcoTipCategory.disposal:
      return 0.8; // Proper recycling
    case EcoTipCategory.ecoBuying:
      return 0.6; // Sustainable purchases
    case EcoTipCategory.energySaving:
      return 0.3; // Indirect impact
  }
}

double _energyPerTip(EcoTipCategory? category) {
  if (category == null) return 2.0;
  switch (category) {
    case EcoTipCategory.energySaving:
      return 5.0; // kWh saved
    case EcoTipCategory.deviceCare:
      return 2.5; // Efficiency gains
    case EcoTipCategory.ecoBuying:
      return 3.0; // Efficient devices
    case EcoTipCategory.disposal:
      return 1.0; // Minimal energy impact
  }
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}
