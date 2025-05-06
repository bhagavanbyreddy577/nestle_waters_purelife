enum HiveBox {
  cart,
  user,
  product,
  country,
}

extension HiveBoxName on HiveBox {
  String get name {
    switch (this) {
      case HiveBox.cart:
        return 'cartBox';
      case HiveBox.user:
        return 'userBox';
      case HiveBox.product:
        return 'productBox';
      case HiveBox.country:
        return 'country';
    }
  }
}
