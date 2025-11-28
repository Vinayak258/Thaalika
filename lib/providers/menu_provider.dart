import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService;
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = false;

  MenuProvider(this._menuService);

  List<MenuItemModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> fetchMenu(String messId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _menuItems = await _menuService.getMenuByMessId(messId);
    } catch (e) {
      debugPrint('Error fetching menu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await _menuService.addMenuItem(item);
    await fetchMenu(item.messId);
  }
  
  Future<void> deleteMenuItem(String id, String messId) async {
    await _menuService.deleteMenuItem(id);
    await fetchMenu(messId);
  }

  Future<List<String>> searchCatalog(String query) async {
    return await _menuService.searchCatalog(query);
  }

  Future<void> addToCatalog(String name) async {
    await _menuService.addToCatalog(name);
  }
}
