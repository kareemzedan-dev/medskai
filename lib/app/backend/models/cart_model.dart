class CartItemPricesModel {
  String? price;
  String? regularPrice;
  String? salePrice;
  String? currencyCode;
  int currencyMinorUnit = 2;

  CartItemPricesModel({this.price, this.regularPrice, this.salePrice, this.currencyCode, this.currencyMinorUnit = 2});

  CartItemPricesModel.fromJson(Map<String, dynamic> json) {
    price = json['price']?.toString();
    regularPrice = json['regular_price']?.toString();
    salePrice = json['sale_price']?.toString();
    currencyCode = json['currency_code']?.toString();
    currencyMinorUnit = json['currency_minor_unit'] ?? 2;
  }

  double get priceAsDouble {
    if (price == null) return 0;
    final raw = double.tryParse(price!) ?? 0;
    return raw / _divisor;
  }

  double get regularPriceAsDouble {
    if (regularPrice == null) return 0;
    final raw = double.tryParse(regularPrice!) ?? 0;
    return raw / _divisor;
  }

  int get _divisor {
    int d = 1;
    for (int i = 0; i < currencyMinorUnit; i++) d *= 10;
    return d;
  }

  String get formattedPrice => '\$${priceAsDouble.toStringAsFixed(2)}';
}

class CartItemModel {
  String? key;
  int? id;
  String? name;
  int quantity = 1;
  CartItemPricesModel? prices;
  List<String> images = [];

  CartItemModel({this.key, this.id, this.name, this.quantity = 1, this.prices});

  CartItemModel.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    id = json['id'];
    name = json['name']?.toString();
    quantity = json['quantity'] ?? 1;

    if (json['prices'] != null && json['prices'] is Map) {
      prices = CartItemPricesModel.fromJson(json['prices']);
    }

    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List)
          .map((e) => e is Map ? (e['src']?.toString() ?? '') : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  String? get imageUrl => images.isNotEmpty ? images.first : null;
}

class CartCouponModel {
  String? code;
  String? discount;
  String? discountType;

  CartCouponModel({this.code, this.discount, this.discountType});

  CartCouponModel.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    discount = json['discount']?.toString();
    discountType = json['discount_type']?.toString();
  }
}

class CartTotalsModel {
  String? totalItems;
  String? totalDiscount;
  String? totalPrice;
  String? currencyCode;
  int currencyMinorUnit = 2;

  CartTotalsModel({this.totalItems, this.totalDiscount, this.totalPrice, this.currencyCode});

  CartTotalsModel.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items']?.toString();
    totalDiscount = json['total_discount']?.toString();
    totalPrice = json['total_price']?.toString();
    currencyCode = json['currency_code']?.toString();
    currencyMinorUnit = json['currency_minor_unit'] ?? 2;
  }

  double _toDouble(String? val) {
    if (val == null) return 0;
    final raw = double.tryParse(val) ?? 0;
    int d = 1;
    for (int i = 0; i < currencyMinorUnit; i++) d *= 10;
    return raw / d;
  }

  String get formattedTotal => '\$${_toDouble(totalPrice).toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${_toDouble(totalItems).toStringAsFixed(2)}';
  String get formattedDiscount => '-\$${_toDouble(totalDiscount).toStringAsFixed(2)}';
}

class CartModel {
  List<CartItemModel> items = [];
  List<CartCouponModel> coupons = [];
  CartTotalsModel? totals;
  int itemsCount = 0;
  bool needsPayment = false;

  CartModel({this.itemsCount = 0, this.needsPayment = false});

  CartModel.fromJson(Map<String, dynamic> json) {
    itemsCount = json['items_count'] ?? 0;
    needsPayment = json['needs_payment'] == true;

    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }

    if (json['coupons'] != null && json['coupons'] is List) {
      coupons = (json['coupons'] as List)
          .map((e) => CartCouponModel.fromJson(e))
          .toList();
    }

    if (json['totals'] != null && json['totals'] is Map) {
      totals = CartTotalsModel.fromJson(json['totals']);
    }
  }

  bool get isEmpty => items.isEmpty;
  bool get hasCoupons => coupons.isNotEmpty;
}
