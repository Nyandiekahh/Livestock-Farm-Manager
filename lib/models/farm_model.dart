import 'package:cloud_firestore/cloud_firestore.dart';
import 'cow_model.dart';
import 'chicken_model.dart';

class Farm {
  String id;
  String name;
  String location;
  String ownerName;
  String contactNumber;
  DateTime setupDate;
  Map<String, dynamic> settings;
  List<Cow> cows;
  List<ChickenGroup> chickenGroups;

  Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.ownerName,
    required this.contactNumber,
    required this.setupDate,
    this.settings = const {},
    this.cows = const [],
    this.chickenGroups = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'setupDate': Timestamp.fromDate(setupDate),
      'settings': settings,
      'cowCount': cows.length,
      'chickenGroupCount': chickenGroups.length,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Create from Firestore document
  factory Farm.fromMap(Map<String, dynamic> map, String documentId) {
    return Farm(
      id: documentId,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      ownerName: map['ownerName'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      setupDate: (map['setupDate'] as Timestamp).toDate(),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  // Copy with method for updates
  Farm copyWith({
    String? name,
    String? location,
    String? ownerName,
    String? contactNumber,
    DateTime? setupDate,
    Map<String, dynamic>? settings,
    List<Cow>? cows,
    List<ChickenGroup>? chickenGroups,
  }) {
    return Farm(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      ownerName: ownerName ?? this.ownerName,
      contactNumber: contactNumber ?? this.contactNumber,
      setupDate: setupDate ?? this.setupDate,
      settings: settings ?? this.settings,
      cows: cows ?? this.cows,
      chickenGroups: chickenGroups ?? this.chickenGroups,
    );
  }

  // Get total milk production for today
  double getTodayMilkProduction() {
    final today = DateTime.now();
    double total = 0.0;

    for (final cow in cows) {
      total += cow.getTodayMilkProduction();
    }

    return total;
  }

  // Get total egg production for today
  int getTodayEggProduction() {
    final today = DateTime.now();
    int total = 0;

    for (final group in chickenGroups) {
      total += group.getTodayEggProduction();
    }

    return total;
  }

  // Get active cows count
  int getActiveCowsCount() {
    return cows.where((cow) => cow.status == CowStatus.active).length;
  }

  // Get total chickens count
  int getTotalChickensCount() {
    return chickenGroups.fold(0, (sum, group) => sum + group.chickenCount);
  }

  // Get pending tasks count
  int getPendingTasksCount() {
    int count = 0;
    final now = DateTime.now();

    // Check milking sessions for each cow
    for (final cow in cows) {
      if (cow.status == CowStatus.active) {
        final sessions = cow.getRequiredMilkingSessions();
        for (final session in sessions) {
          if (!cow.hasMilkingRecordForSession(DateTime.now(), session)) {
            count++;
          }
        }
      }
    }

    return count;
  }

  // Get farm statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalCows': cows.length,
      'activeCows': getActiveCowsCount(),
      'totalChickens': getTotalChickensCount(),
      'chickenGroups': chickenGroups.length,
      'todayMilk': getTodayMilkProduction(),
      'todayEggs': getTodayEggProduction(),
      'pendingTasks': getPendingTasksCount(),
    };
  }
}
