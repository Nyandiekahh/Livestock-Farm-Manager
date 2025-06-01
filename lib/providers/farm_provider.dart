import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm_model.dart';
import '../models/cow_model.dart';
import '../models/chicken_model.dart';

class FarmProvider with ChangeNotifier {
  Farm? _farm;
  List<Cow> _cows = [];
  List<ChickenGroup> _chickenGroups = [];
  List<MilkRecord> _milkRecords = [];
  List<FeedRecord> _feedRecords = [];
  List<EggRecord> _eggRecords = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Farm? get farm => _farm;
  List<Cow> get cows => _cows;
  List<ChickenGroup> get chickenGroups => _chickenGroups;
  List<MilkRecord> get milkRecords => _milkRecords;
  List<FeedRecord> get feedRecords => _feedRecords;
  List<EggRecord> get eggRecords => _eggRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize farm data
  Future<void> initializeFarm(Farm farmData) async {
    try {
      _setLoading(true);

      // Save farm to Firestore
      await _firestore
          .collection('farms')
          .doc(farmData.id)
          .set(farmData.toMap());

      // Save farm ID to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farm_id', farmData.id);
      await prefs.setBool('is_first_time', false);

      _farm = farmData;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize farm: $e');
    }
  }

  // Load farm data from Firestore
  Future<void> loadFarmData() async {
    try {
      _setLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final farmId = prefs.getString('farm_id');

      if (farmId == null) {
        _setError('No farm ID found');
        return;
      }

      // Load farm document
      final farmDoc = await _firestore.collection('farms').doc(farmId).get();
      if (!farmDoc.exists) {
        _setError('Farm not found');
        return;
      }

      _farm = Farm.fromMap(farmDoc.data()!, farmDoc.id);

      // Load cows
      await _loadCows();

      // Load chicken groups
      await _loadChickenGroups();

      // Load records
      await _loadMilkRecords();
      await _loadFeedRecords();
      await _loadEggRecords();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load farm data: $e');
    }
  }

  // Add a new cow
  Future<void> addCow(Cow cow) async {
    try {
      _setLoading(true);

      // Save to Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('cows')
          .doc(cow.id)
          .set(cow.toMap());

      // Update local list
      _cows.add(cow);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add cow: $e');
    }
  }

  // Update cow
  Future<void> updateCow(Cow cow) async {
    try {
      _setLoading(true);

      // Update in Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('cows')
          .doc(cow.id)
          .update(cow.toMap());

      // Update local list
      final index = _cows.indexWhere((c) => c.id == cow.id);
      if (index != -1) {
        _cows[index] = cow;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update cow: $e');
    }
  }

  // Delete cow
  Future<void> deleteCow(String cowId) async {
    try {
      _setLoading(true);

      // Delete from Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('cows')
          .doc(cowId)
          .delete();

      // Remove from local list
      _cows.removeWhere((cow) => cow.id == cowId);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete cow: $e');
    }
  }

  // Add chicken group
  Future<void> addChickenGroup(ChickenGroup group) async {
    try {
      _setLoading(true);

      // Save to Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('chicken_groups')
          .doc(group.id)
          .set(group.toMap());

      // Update local list
      _chickenGroups.add(group);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add chicken group: $e');
    }
  }

  // Update chicken group
  Future<void> updateChickenGroup(ChickenGroup group) async {
    try {
      _setLoading(true);

      // Update in Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('chicken_groups')
          .doc(group.id)
          .update(group.toMap());

      // Update local list
      final index = _chickenGroups.indexWhere((g) => g.id == group.id);
      if (index != -1) {
        _chickenGroups[index] = group;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update chicken group: $e');
    }
  }

  // Add milk record
  Future<void> addMilkRecord(MilkRecord record) async {
    try {
      _setLoading(true);

      // Save to Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('milk_records')
          .doc(record.id)
          .set(record.toMap());

      // Update local list
      _milkRecords.add(record);

      // Update cow's milk records
      final cowIndex = _cows.indexWhere((cow) => cow.id == record.cowId);
      if (cowIndex != -1) {
        _cows[cowIndex].addMilkRecord(record);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add milk record: $e');
    }
  }

  // Add feed record
  Future<void> addFeedRecord(FeedRecord record) async {
    try {
      _setLoading(true);

      // Save to Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('feed_records')
          .doc(record.id)
          .set(record.toMap());

      // Update local list
      _feedRecords.add(record);

      // Update cow's feed records
      final cowIndex = _cows.indexWhere((cow) => cow.id == record.cowId);
      if (cowIndex != -1) {
        _cows[cowIndex].addFeedRecord(record);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add feed record: $e');
    }
  }

  // Add egg record
  Future<void> addEggRecord(EggRecord record) async {
    try {
      _setLoading(true);

      // Save to Firestore
      await _firestore
          .collection('farms')
          .doc(_farm!.id)
          .collection('egg_records')
          .doc(record.id)
          .set(record.toMap());

      // Update local list
      _eggRecords.add(record);

      // Update chicken group's egg records
      final groupIndex =
          _chickenGroups.indexWhere((group) => group.id == record.groupId);
      if (groupIndex != -1) {
        _chickenGroups[groupIndex].addEggRecord(record);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add egg record: $e');
    }
  }

  // Copy yesterday's feeding data
  Future<void> copyYesterdayFeeding() async {
    try {
      _setLoading(true);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      final yesterdayFeedings = _feedRecords
          .where((record) =>
              record.date.year == yesterday.year &&
              record.date.month == yesterday.month &&
              record.date.day == yesterday.day)
          .toList();

      for (final yesterdayRecord in yesterdayFeedings) {
        final newRecord = FeedRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cowId: yesterdayRecord.cowId,
          date: today,
          feedType: yesterdayRecord.feedType,
          quantity: yesterdayRecord.quantity,
          cost: yesterdayRecord.cost,
          notes: 'Copied from yesterday',
        );

        await addFeedRecord(newRecord);
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to copy yesterday\'s feeding: $e');
    }
  }

  // Get farm statistics
  Map<String, dynamic> getFarmStatistics() {
    if (_farm == null) return {};

    final stats = _farm!.getStatistics();
    stats['totalMilkRecords'] = _milkRecords.length;
    stats['totalFeedRecords'] = _feedRecords.length;
    stats['totalEggRecords'] = _eggRecords.length;

    return stats;
  }

  // Get today's urgent tasks
  List<Map<String, dynamic>> getTodayUrgentTasks() {
    final tasks = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final currentHour = now.hour;

    for (final cow in _cows) {
      if (cow.status == CowStatus.active) {
        // Check morning milking (6-10 AM)
        if (currentHour >= 6 && currentHour < 10) {
          if (!cow.hasMilkingRecordForSession(now, MilkingSession.morning)) {
            tasks.add({
              'type': 'milking',
              'priority': 'urgent',
              'title': 'Morning Milking - ${cow.name}',
              'description': 'Milk ${cow.name} (${cow.tagNumber})',
              'cowId': cow.id,
              'session': MilkingSession.morning,
            });
          }
        }

        // Check afternoon milking (1-4 PM)
        if (currentHour >= 13 && currentHour < 16) {
          if (!cow.hasMilkingRecordForSession(now, MilkingSession.afternoon)) {
            tasks.add({
              'type': 'milking',
              'priority': 'urgent',
              'title': 'Afternoon Milking - ${cow.name}',
              'description': 'Milk ${cow.name} (${cow.tagNumber})',
              'cowId': cow.id,
              'session': MilkingSession.afternoon,
            });
          }
        }

        // Check evening milking (6-9 PM)
        if (currentHour >= 18 && currentHour < 21) {
          if (!cow.hasMilkingRecordForSession(now, MilkingSession.evening)) {
            tasks.add({
              'type': 'milking',
              'priority': 'urgent',
              'title': 'Evening Milking - ${cow.name}',
              'description': 'Milk ${cow.name} (${cow.tagNumber})',
              'cowId': cow.id,
              'session': MilkingSession.evening,
            });
          }
        }

        // Check overdue milking sessions
        if (currentHour > 10 &&
            !cow.hasMilkingRecordForSession(now, MilkingSession.morning)) {
          tasks.add({
            'type': 'milking',
            'priority': 'overdue',
            'title': 'OVERDUE: Morning Milking - ${cow.name}',
            'description': 'Morning milking missed for ${cow.name}',
            'cowId': cow.id,
            'session': MilkingSession.morning,
          });
        }

        if (currentHour > 16 &&
            !cow.hasMilkingRecordForSession(now, MilkingSession.afternoon)) {
          tasks.add({
            'type': 'milking',
            'priority': 'overdue',
            'title': 'OVERDUE: Afternoon Milking - ${cow.name}',
            'description': 'Afternoon milking missed for ${cow.name}',
            'cowId': cow.id,
            'session': MilkingSession.afternoon,
          });
        }

        if (currentHour > 21 &&
            !cow.hasMilkingRecordForSession(now, MilkingSession.evening)) {
          tasks.add({
            'type': 'milking',
            'priority': 'overdue',
            'title': 'OVERDUE: Evening Milking - ${cow.name}',
            'description': 'Evening milking missed for ${cow.name}',
            'cowId': cow.id,
            'session': MilkingSession.evening,
          });
        }
      }
    }

    return tasks;
  }

  // Load cows from Firestore
  Future<void> _loadCows() async {
    final cowsSnapshot = await _firestore
        .collection('farms')
        .doc(_farm!.id)
        .collection('cows')
        .get();

    _cows = cowsSnapshot.docs
        .map((doc) => Cow.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Load chicken groups from Firestore
  Future<void> _loadChickenGroups() async {
    final groupsSnapshot = await _firestore
        .collection('farms')
        .doc(_farm!.id)
        .collection('chicken_groups')
        .get();

    _chickenGroups = groupsSnapshot.docs
        .map((doc) => ChickenGroup.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Load milk records from Firestore
  Future<void> _loadMilkRecords() async {
    final recordsSnapshot = await _firestore
        .collection('farms')
        .doc(_farm!.id)
        .collection('milk_records')
        .orderBy('date', descending: true)
        .limit(1000) // Load last 1000 records
        .get();

    _milkRecords = recordsSnapshot.docs
        .map((doc) => MilkRecord.fromMap(doc.data(), doc.id))
        .toList();

    // Associate records with cows
    for (final record in _milkRecords) {
      final cowIndex = _cows.indexWhere((cow) => cow.id == record.cowId);
      if (cowIndex != -1) {
        _cows[cowIndex].addMilkRecord(record);
      }
    }
  }

  // Load feed records from Firestore
  Future<void> _loadFeedRecords() async {
    final recordsSnapshot = await _firestore
        .collection('farms')
        .doc(_farm!.id)
        .collection('feed_records')
        .orderBy('date', descending: true)
        .limit(1000) // Load last 1000 records
        .get();

    _feedRecords = recordsSnapshot.docs
        .map((doc) => FeedRecord.fromMap(doc.data(), doc.id))
        .toList();

    // Associate records with cows
    for (final record in _feedRecords) {
      final cowIndex = _cows.indexWhere((cow) => cow.id == record.cowId);
      if (cowIndex != -1) {
        _cows[cowIndex].addFeedRecord(record);
      }
    }
  }

  // Load egg records from Firestore
  Future<void> _loadEggRecords() async {
    final recordsSnapshot = await _firestore
        .collection('farms')
        .doc(_farm!.id)
        .collection('egg_records')
        .orderBy('date', descending: true)
        .limit(1000) // Load last 1000 records
        .get();

    _eggRecords = recordsSnapshot.docs
        .map((doc) => EggRecord.fromMap(doc.data(), doc.id))
        .toList();

    // Associate records with chicken groups
    for (final record in _eggRecords) {
      final groupIndex =
          _chickenGroups.indexWhere((group) => group.id == record.groupId);
      if (groupIndex != -1) {
        _chickenGroups[groupIndex].addEggRecord(record);
      }
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Clear all data (for logout)
  void clearData() {
    _farm = null;
    _cows = [];
    _chickenGroups = [];
    _milkRecords = [];
    _feedRecords = [];
    _eggRecords = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
