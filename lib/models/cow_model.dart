import 'package:cloud_firestore/cloud_firestore.dart';

enum CowStatus { active, dry, pregnant, sick, sold }

enum MilkingSession { morning, afternoon, evening }

class Cow {
  String id;
  String name;
  String tagNumber;
  String breed;
  DateTime birthDate;
  String color;
  double weight;
  CowStatus status;
  bool isPregnant;
  DateTime? expectedCalvingDate;
  String? motherTag;
  String? fatherTag;
  String? imageUrl;
  List<MilkRecord> milkRecords;
  List<FeedRecord> feedRecords;
  List<HealthRecord> healthRecords;
  List<Note> notes;

  Cow({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.breed,
    required this.birthDate,
    required this.color,
    required this.weight,
    this.status = CowStatus.active,
    this.isPregnant = false,
    this.expectedCalvingDate,
    this.motherTag,
    this.fatherTag,
    this.imageUrl,
    this.milkRecords = const [],
    this.feedRecords = const [],
    this.healthRecords = const [],
    this.notes = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tagNumber': tagNumber,
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'color': color,
      'weight': weight,
      'status': status.name,
      'isPregnant': isPregnant,
      'expectedCalvingDate': expectedCalvingDate != null
          ? Timestamp.fromDate(expectedCalvingDate!)
          : null,
      'motherTag': motherTag,
      'fatherTag': fatherTag,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Create from Firestore document
  factory Cow.fromMap(Map<String, dynamic> map, String documentId) {
    return Cow(
      id: documentId,
      name: map['name'] ?? '',
      tagNumber: map['tagNumber'] ?? '',
      breed: map['breed'] ?? '',
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      color: map['color'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      status: CowStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CowStatus.active,
      ),
      isPregnant: map['isPregnant'] ?? false,
      expectedCalvingDate: map['expectedCalvingDate'] != null
          ? (map['expectedCalvingDate'] as Timestamp).toDate()
          : null,
      motherTag: map['motherTag'],
      fatherTag: map['fatherTag'],
      imageUrl: map['imageUrl'],
    );
  }

  // Get age in years
  int getAgeInYears() {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get today's milk production
  double getTodayMilkProduction() {
    final today = DateTime.now();
    return milkRecords
        .where((record) =>
            record.date.year == today.year &&
            record.date.month == today.month &&
            record.date.day == today.day)
        .fold(0.0, (sum, record) => sum + record.quantity);
  }

  // Get required milking sessions based on cow status
  List<MilkingSession> getRequiredMilkingSessions() {
    if (status != CowStatus.active) return [];
    return [
      MilkingSession.morning,
      MilkingSession.afternoon,
      MilkingSession.evening
    ];
  }

  // Check if cow has milking record for specific session today
  bool hasMilkingRecordForSession(DateTime date, MilkingSession session) {
    return milkRecords.any((record) =>
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day &&
        record.session == session);
  }

  // Get average daily milk production (last 7 days)
  double getAverageDailyMilkProduction() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentRecords = milkRecords.where((record) =>
        record.date.isAfter(weekAgo) &&
        record.date.isBefore(now.add(const Duration(days: 1))));

    if (recentRecords.isEmpty) return 0.0;

    final totalMilk =
        recentRecords.fold(0.0, (sum, record) => sum + record.quantity);
    return totalMilk / 7; // Average per day
  }

  // Get latest health status
  String getHealthStatus() {
    if (healthRecords.isEmpty) return 'Unknown';
    healthRecords.sort((a, b) => b.date.compareTo(a.date));
    return healthRecords.first.status;
  }

  // Add milk record
  void addMilkRecord(MilkRecord record) {
    milkRecords = [...milkRecords, record];
  }

  // Add feed record
  void addFeedRecord(FeedRecord record) {
    feedRecords = [...feedRecords, record];
  }

  // Add health record
  void addHealthRecord(HealthRecord record) {
    healthRecords = [...healthRecords, record];
  }

  // Add note
  void addNote(Note note) {
    notes = [...notes, note];
  }
}

class MilkRecord {
  String id;
  String cowId;
  DateTime date;
  MilkingSession session;
  double quantity; // in liters
  String quality;
  String? notes;

  MilkRecord({
    required this.id,
    required this.cowId,
    required this.date,
    required this.session,
    required this.quantity,
    this.quality = 'Good',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'session': session.name,
      'quantity': quantity,
      'quality': quality,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  factory MilkRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return MilkRecord(
      id: documentId,
      cowId: map['cowId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      session: MilkingSession.values.firstWhere(
        (e) => e.name == map['session'],
        orElse: () => MilkingSession.morning,
      ),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      quality: map['quality'] ?? 'Good',
      notes: map['notes'],
    );
  }
}

class FeedRecord {
  String id;
  String cowId;
  DateTime date;
  String feedType;
  double quantity; // in kg
  double cost;
  String? notes;

  FeedRecord({
    required this.id,
    required this.cowId,
    required this.date,
    required this.feedType,
    required this.quantity,
    required this.cost,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'feedType': feedType,
      'quantity': quantity,
      'cost': cost,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  factory FeedRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return FeedRecord(
      id: documentId,
      cowId: map['cowId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      feedType: map['feedType'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      notes: map['notes'],
    );
  }
}

class HealthRecord {
  String id;
  String cowId;
  DateTime date;
  String recordType; // vaccination, treatment, checkup
  String status; // healthy, sick, treated
  String description;
  String? medication;
  String? dosage;
  String? veterinarian;
  double? cost;
  DateTime? nextDueDate;

  HealthRecord({
    required this.id,
    required this.cowId,
    required this.date,
    required this.recordType,
    required this.status,
    required this.description,
    this.medication,
    this.dosage,
    this.veterinarian,
    this.cost,
    this.nextDueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cowId': cowId,
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
      'createdAt': Timestamp.now(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return HealthRecord(
      id: documentId,
      cowId: map['cowId'] ?? '',
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
    );
  }
}

class Note {
  String id;
  String cowId;
  DateTime date;
  String category; // general, health, breeding, behavior, feeding
  String title;
  String content;

  Note({
    required this.id,
    required this.cowId,
    required this.date,
    required this.category,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'category': category,
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      id: documentId,
      cowId: map['cowId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] ?? 'general',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
