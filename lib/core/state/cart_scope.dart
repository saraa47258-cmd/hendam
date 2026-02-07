import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'dart:convert';
import 'package:hindam/features/cart/models/cart_item.dart';
import 'package:hindam/features/catalog/models/product.dart';
import 'package:hindam/features/orders/models/order.dart';
import 'package:hindam/core/error/error_handler.dart';
import 'package:hindam/core/services/firebase_service.dart';

class CartState extends ChangeNotifier {
  final List<CartItem> _items = <CartItem>[];
  final List<Order> _orders = <Order>[];
  SharedPreferences? _prefs;

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold<int>(0, (s, i) => s + i.qty);
  double get total => _items.fold<double>(0, (s, i) => s + (i.price * i.qty));
  List<Order> get orders => List.unmodifiable(_orders);

  // تهيئة SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // تحميل البيانات المحفوظة
  Future<void> loadData() async {
    try {
      await _initPrefs();

      // تحميل السلة
      final cartData = _prefs!.getString('cart_items');
      if (cartData != null) {
        try {
          final List<dynamic> decoded = json.decode(cartData);
          _items.clear();
          for (var item in decoded) {
            _items.add(CartItem.fromJson(item));
          }
        } catch (e) {
          ErrorHandler.handleError(e, null, context: 'تحميل بيانات السلة');
        }
      }

      // تحميل الطلبات
      final ordersData = _prefs!.getString('orders');
      if (ordersData != null) {
        try {
          final List<dynamic> decoded = json.decode(ordersData);
          _orders.clear();
          for (var order in decoded) {
            _orders.add(Order.fromJson(order));
          }
        } catch (e) {
          ErrorHandler.handleError(e, null, context: 'تحميل بيانات الطلبات');
        }
      }

      notifyListeners();
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'تهيئة البيانات');
    }
  }

  // حفظ البيانات
  Future<void> _saveData() async {
    try {
      await _initPrefs();

      // حفظ السلة
      final cartJson = _items.map((item) => item.toJson()).toList();
      await _prefs!.setString('cart_items', json.encode(cartJson));

      // حفظ الطلبات
      final ordersJson = _orders.map((order) => order.toJson()).toList();
      await _prefs!.setString('orders', json.encode(ordersJson));
    } catch (e) {
      ErrorHandler.handleError(e, null, context: 'حفظ البيانات');
    }
  }

  void addProduct(Product p) {
    final idx = _items.indexWhere((i) => i.product?.id == p.id);
    if (idx >= 0) {
      final cur = _items[idx];
      _items[idx] = cur.copyWith(qty: cur.qty + 1);
    } else {
      _items.add(CartItem(product: p, price: p.priceOmr, qty: 1));
    }
    _saveData();
    notifyListeners();
  }

  void addService({required String name, required double price}) {
    _items.add(CartItem(serviceName: name, price: price, qty: 1));
    _saveData();
    notifyListeners();
  }

  /// إضافة عباية للسلة مع تفاصيل التخصيص
  void addAbayaItem({
    required String id,
    required String title,
    required double price,
    String? imageUrl,
    String? subtitle,
    String? selectedColor,
    String? colorName,
    Map<String, double>? measurements,
    String? unit,
    String? notes,
  }) {
    // إنشاء كائن التخصيص
    CartCustomization? customization;
    if (selectedColor != null || measurements != null || notes != null) {
      customization = CartCustomization(
        selectedColor: selectedColor,
        colorName: colorName,
        measurements: measurements,
        unit: unit ?? 'in',
        notes: notes,
      );
    }

    // البحث عن نفس المنتج مع نفس التخصيص
    final idx = _items.indexWhere((i) => i.matches(id, customization));

    if (idx >= 0) {
      // إذا كان موجوداً بنفس التخصيص، نزيد الكمية
      final cur = _items[idx];
      _items[idx] = cur.copyWith(qty: cur.qty + 1);
    } else {
      // إضافة عنصر جديد مع التخصيص
      _items.add(CartItem(
        productId: id,
        serviceName: title,
        imageUrl: imageUrl,
        price: price,
        qty: 1,
        customization: customization,
      ));
    }
    _saveData();
    notifyListeners();
  }

  /// إضافة عباية مع مقاسات كاملة (من شاشة المقاسات)
  void addAbayaWithMeasurements({
    required String id,
    required String title,
    required double price,
    String? imageUrl,
    String? selectedColor,
    String? colorName,
    required double length,
    required double sleeve,
    required double width,
    String unit = 'in',
    String? notes,
  }) {
    addAbayaItem(
      id: id,
      title: title,
      price: price,
      imageUrl: imageUrl,
      selectedColor: selectedColor,
      colorName: colorName,
      measurements: {
        'length': length,
        'sleeve': sleeve,
        'width': width,
      },
      unit: unit,
      notes: notes,
    );
  }

  /// إضافة منتج من متجر (محلات المستلزمات) للسلة
  void addMerchantProduct({
    required String id,
    required String title,
    required double price,
    String? imageUrl,
    String? subtitle,
    String? selectedColor,
    String? shopId,
    String? shopName,
  }) {
    // إنشاء كائن التخصيص للون المختار
    CartCustomization? customization;
    if (selectedColor != null) {
      customization = CartCustomization(
        selectedColor: selectedColor,
      );
    }

    // البحث عن نفس المنتج مع نفس اللون
    final idx = _items.indexWhere((i) => i.matches(id, customization));

    if (idx >= 0) {
      // إذا كان موجوداً بنفس اللون، نزيد الكمية
      final cur = _items[idx];
      _items[idx] = cur.copyWith(qty: cur.qty + 1);
    } else {
      // إضافة عنصر جديد
      _items.add(CartItem(
        productId: id,
        serviceName: title,
        imageUrl: imageUrl,
        price: price,
        qty: 1,
        customization: customization,
      ));
    }
    _saveData();
    notifyListeners();
  }

  void inc(CartItem item) {
    item.qty += 1;
    _saveData();
    notifyListeners();
  }

  void dec(CartItem item) {
    if (item.qty > 1) {
      item.qty -= 1;
    } else {
      _items.remove(item);
    }
    _saveData();
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    _saveData();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveData();
    notifyListeners();
  }

  void placeOrder() {
    if (_items.isEmpty) return;
    final id = 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final snapshot = _items.map((e) => e.copy()).toList(growable: false);
    final order = Order(
      id: id,
      status: 'قيد المعالجة',
      createdAt: DateTime.now(),
      totalOmr: total,
      items: snapshot,
    );
    _orders.insert(0, order);
    _items.clear();
    _saveData();
    notifyListeners();
  }

  /// إرسال طلب السلة إلى Firebase
  Future<String?> submitCartOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) async {
    if (_items.isEmpty) return null;

    try {
      // تجميع المنتجات حسب المتجر
      final itemsByShop = <String, List<CartItem>>{};
      for (final item in _items) {
        // استخراج معرف المتجر من productId أو استخدام 'default'
        const shopId = 'default'; // يمكن تحسينه لاحقاً
        itemsByShop.putIfAbsent(shopId, () => []).add(item);
      }

      String? lastOrderId;

      // إنشاء طلب لكل منتج في السلة
      for (final item in _items) {
        final orderData = {
          // نوع الطلب
          'orderType': 'cart_order',

          // معلومات العميل
          'customerId': customerId,
          'customerName': customerName,
          'customerPhone': customerPhone,

          // معلومات المنتج
          'productId': item.productId ?? '',
          'productName': item.title,
          'productImageUrl': item.imageUrl ?? '',
          'productPrice': item.price,
          'quantity': item.qty,
          'selectedColor': item.customization?.selectedColor,

          // السعر الإجمالي
          'totalPrice': item.price * item.qty,

          // حالة الطلب
          'status': 'pending',

          // التواريخ
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        print('📦 إرسال طلب من السلة:');
        print('   👤 العميل: $customerName');
        print('   📦 المنتج: ${item.title}');
        print('   💰 السعر: ${item.price * item.qty} ر.ع');

        final docRef =
            await FirebaseService.firestore.collection('orders').add(orderData);

        lastOrderId = docRef.id;
        print('✅ تم إرسال الطلب: ${docRef.id}');
      }

      // مسح السلة بعد الإرسال
      _items.clear();
      _saveData();
      notifyListeners();

      return lastOrderId;
    } catch (e, stackTrace) {
      print('❌ خطأ في إرسال طلب السلة: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }
}

class CartScope extends InheritedNotifier<CartState> {
  const CartScope({super.key, required CartState state, required super.child})
      : super(notifier: state);

  static CartState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in context');
    return scope!.notifier!;
  }
}
