import 'package:cloud_firestore/cloud_firestore.dart';

enum ChickenGroupStatus { active, brooding, molting, sick }

class ChickenGroup {
  String id;
  String name;
  String breed;
  int chickenCount;
  DateTime establishedDate;
  ChickenGroupStatus status;
  bool isBrooding;
  DateTime? expectedHatchDate;
  List<EggRecord> eggRecords;
  List<GroupFeedRecord> feedRecords;
  List<GroupHealthRecord> healthRecords;
  List<GroupNote> notes;

  ChickenGroup({
    required this.id,
    required this.name,
    required this.breed,
    required this.chickenCount,
    required this.establishedDate,
    this.status = ChickenGroupStatus.active,
    this.isBrooding = false,
    this.expectedHatchDate,
    this.eggRecords = const [],
    this.feedRecords = const [],
    this.healthRecords = const [],
    this.notes = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'chickenCount': chickenCount,
      'establishedDate': Timestamp.fromDate(establishedDate),
      'status': status.name,
      'isBrooding': isBrooding,
      'expectedHatchDate': expectedHatchDate != null
          ? Timestamp.fromDate(expectedHatchDate!)
          : null,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Create from Firestore document
  factory ChickenGroup.fromMap(Map<String, dynamic> map, String documentId) {
    return ChickenGroup(
      id: documentId,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      chickenCount: map['chickenCount'] ?? 0,
      establishedDate: (map['establishedDate'] as Timestamp).toDate(),
      status: ChickenGroupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ChickenGroupStatus.active,
      ),
      isBrooding: map['isBrooding'] ?? false,
      expectedHatchDate: map['expectedHatchDate'] != null
          ? (map['expectedHatchDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Get today's egg production
  int getTodayEggProduction() {
    final today = DateTime.now();
    return eggRecords
        .where((record) =>
            record.date.year == today.year &&
            record.date.month == today.month &&
            record.date.day == today.day)
        .fold(0, (sum, record) => sum + record.eggCount);
  }

  // Get average daily egg production (last 7 days)
  double getAverageDailyEggProduction() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentRecords = eggRecords.where((record) =>
        record.date.isAfter(weekAgo) &&
        record.date.isBefore(now.add(const Duration(days: 1))));

    if (recentRecords.isEmpty) return 0.0;

    final totalEggs =
        recentRecords.fold(0, (sum, record) => sum + record.eggCount);
    return totalEggs / 7; // Average per day
  }

  // Get production efficiency (eggs per chicken per day)
  double getProductionEfficiency() {
    if (chickenCount == 0) return 0.0;
    return getAverageDailyEggProduction() / chickenCount;
  }

  // Get latest health status
  String getHealthStatus() {
    if (healthRecords.isEmpty) return 'Unknown';
    healthRecords.sort((a, b) => b.date.compareTo(a.date));
    return healthRecords.first.status;
  }

  // Add egg record
  void addEggRecord(EggRecord record) {
    eggRecords = [...eggRecords, record];
  }

  // Add feed record
  void addFeedRecord(GroupFeedRecord record) {
    feedRecords = [...feedRecords, record];
  }

  // Add health record
  void addHealthRecord(GroupHealthRecord record) {
    healthRecords = [...healthRecords, record];
  }

  // Add note
  void addNote(GroupNote note) {
    notes = [...notes, note];
  }

  // Update chicken count
  void updateChickenCount(int newCount) {
    chickenCount = newCount;
  }
}

class EggRecord {
  String id;
  String groupId;
  DateTime date;
  int eggCount;
  int brokenEggs;
  int dirtyEggs;
  String quality;
  String? notes;

  EggRecord({
    required this.id,
    required this.groupId,
    required this.date,
    required this.eggCount,
    this.brokenEggs = 0,
    this.dirtyEggs = 0,
    this.quality = 'Good',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'eggCount': eggCount,
      'brokenEggs': brokenEggs,
      'dirtyEggs': dirtyEggs,
      'quality': quality,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  factory EggRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return EggRecord(
      id: documentId,
      groupId: map['groupId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      eggCount: map['eggCount'] ?? 0,
      brokenEggs: map['brokenEggs'] ?? 0,
      dirtyEggs: map['dirtyEggs'] ?? 0,
      quality: map['quality'] ?? 'Good',
      notes: map['notes'],
    );
  }

  // Get good eggs count
  int getGoodEggsCount() {
    return eggCount - brokenEggs - dirtyEggs;
  }
}

class GroupFeedRecord {
  String id;
  String groupId;
  DateTime date;
  String feedType;
  double quantity; // in kg
  double cost;
  String? notes;

  GroupFeedRecord({
    required this.id,
    required this.groupId,
    required this.date,
    required this.feedType,
    required this.quantity,
    required this.cost,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'feedType': feedType,
      'quantity': quantity,
      'cost': cost,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  factory GroupFeedRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupFeedRecord(
      id: documentId,
      groupId: map['groupId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      feedType: map['feedType'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      notes: map['notes'],
    );
  }
}

class GroupHealthRecord {
  String id;
  String groupId;
  DateTime date;
  String recordType; // vaccination, treatment, checkup
  String status; // healthy, sick, treated
  String description;
  String? medication;
  String? dosage;
  String? veterinarian;
  double? cost;
  DateTime? nextDueDate;
  int affectedChickens;

  GroupHealthRecord({
    required this.id,
    required this.groupId,
    required this.date,
    required this.recordType,
    required this.status,
    required this.description,
    this.medication,
    this.dosage,
    this.veterinarian,
    this.cost,
    this.nextDueDate,
    this.affectedChickens = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'recordType': recordType,
      'status': status,
      'description': description,
      'medication': medication,
      'dosage': dosage,
      'veterinarian': veterinarian,
      'cost': cost,
      'nextDueDate':
          nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
      'affectedChickens': affectedChickens,
      'createdAt': Timestamp.now(),
    };
  }

  factory GroupHealthRecord.fromMap(
      Map<String, dynamic> map, String documentId) {
    return GroupHealthRecord(
      id: documentId,
      groupId: map['groupId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      recordType: map['recordType'] ?? '',
      status: map['status'] ?? '',
      description: map['description'] ?? '',
      medication: map['medication'],
      dosage: map['dosage'],
      veterinarian: map['veterinarian'],
      cost: map['cost']?.toDouble(),
      nextDueDate: map['nextDueDate'] != null
          ? (map['nextDueDate'] as Timestamp).toDate()
          : null,
      affectedChickens: map['affectedChickens'] ?? 0,
    );
  }
}

class GroupNote {
  String id;
  String groupId;
  DateTime date;
  String category; // general, health, production, behavior, feeding
  String title;
  String content;

  GroupNote({
    required this.id,
    required this.groupId,
    required this.date,
    required this.category,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'category': category,
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    };
  }

  factory GroupNote.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupNote(
      id: documentId,
      groupId: map['groupId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] ?? 'general',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
