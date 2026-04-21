import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  const StorageService(this._box);

  final Box _box;

  T? get<T>(String key) => _box.get(key) as T?;

  T getOrDefault<T>(String key, T defaultValue) =>
      (_box.get(key) as T?) ?? defaultValue;

  Future<void> put<T>(String key, T value) => _box.put(key, value);

  Future<void> delete(String key) => _box.delete(key);

  bool containsKey(String key) => _box.containsKey(key);

  Future<int> clear() => _box.clear();
}

final storageServiceProvider = Provider<StorageService>(
  (_) => throw UnimplementedError('storageServiceProvider not initialized'),
);

/// 专门用于 Mock 设计数据持久化的 box
final designsStorageProvider = Provider<StorageService>(
  (_) => throw UnimplementedError('designsStorageProvider not initialized'),
);
