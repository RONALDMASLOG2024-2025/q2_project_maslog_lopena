class RecyclingResource {
  final String name;
  final String description;
  final String link;

  const RecyclingResource({
    required this.name,
    required this.description,
    required this.link,
  });

  factory RecyclingResource.fromJson(Map<String, dynamic> j) => RecyclingResource(
        name: j['name'] as String,
        description: j['description'] as String,
        link: j['link'] as String,
      );
}

class RecyclingDirectory {
  final List<RecyclingResource> local;
  final List<RecyclingResource> national;
  final List<RecyclingResource> international;

  const RecyclingDirectory({
    required this.local,
    required this.national,
    required this.international,
  });

  factory RecyclingDirectory.fromJson(Map<String, dynamic> j) => RecyclingDirectory(
        local: (j['local'] as List<dynamic>).map((e) => RecyclingResource.fromJson(e as Map<String, dynamic>)).toList(),
        national: (j['national'] as List<dynamic>).map((e) => RecyclingResource.fromJson(e as Map<String, dynamic>)).toList(),
        international: (j['international'] as List<dynamic>).map((e) => RecyclingResource.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
