class OrderModel {
  final int? id;
  final String? orderNumber;
  final String? orderStatus;
  final String? orderType;
  final String? deliveryType;
  final bool? isExpress;
  final int? slaMinutes;
  final int? slaMinutesRemaining;
  final bool? isSlaBreached;
  final String? slaStatus;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? totalAmount;
  final String? createdAt;
  final String? confirmedAt;
  final String? deliveredAt;
  final CustomerModel? customer;
  final VendorModel? vendor;
  final DeliveryAddressModel? deliveryAddress;
  final List<OrderItemModel>? items;
  final List<PaymentModel>? payments;
  final Map<String, dynamic>? rtData;
  final Map<String, dynamic>? rvpData;

  OrderModel({
    this.id,
    this.orderNumber,
    this.orderStatus,
    this.orderType,
    this.deliveryType,
    this.isExpress,
    this.slaMinutes,
    this.slaMinutesRemaining,
    this.isSlaBreached,
    this.slaStatus,
    this.paymentMethod,
    this.paymentStatus,
    this.totalAmount,
    this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
    this.customer,
    this.vendor,
    this.deliveryAddress,
    this.items,
    this.payments,
    this.rtData,
    this.rvpData,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderNumber: json['order_number'],
      orderStatus: json['order_status'],
      orderType: json['order_type'],
      deliveryType: json['delivery_type'],
      isExpress: json['is_express'],
      slaMinutes: json['sla_minutes'],
      slaMinutesRemaining: json['sla_minutes_remaining'],
      isSlaBreached: json['is_sla_breached'],
      slaStatus: json['sla_status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      totalAmount: _parseDouble(json['total_amount']),
      createdAt: json['created_at'],
      confirmedAt: json['confirmed_at'],
      deliveredAt: json['delivered_at'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      vendor:
          json['vendor'] != null ? VendorModel.fromJson(json['vendor']) : null,
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddressModel.fromJson(json['delivery_address'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => OrderItemModel.fromJson(i))
              .toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((p) => PaymentModel.fromJson(p))
              .toList()
          : null,
      rtData: json['rt'] as Map<String, dynamic>?,
      rvpData: json['rvp'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_status': orderStatus,
      'order_type': orderType,
      'delivery_type': deliveryType,
      'is_express': isExpress,
      'sla_minutes': slaMinutes,
      'total_amount': totalAmount,
      'created_at': createdAt,
      'customer': customer?.toJson(),
      'vendor': vendor?.toJson(),
      'delivery_address': deliveryAddress?.toJson(),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class CustomerModel {
  final int? id;
  final String? name;
  final String? mobile;
  final String? email;

  CustomerModel({this.id, this.name, this.mobile, this.email});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
      };
}

class VendorModel {
  final int? id;
  final String? vendorName;
  final String? shopName;
  final String? mobileNumber;
  final String? email;

  VendorModel(
      {this.id, this.vendorName, this.shopName, this.mobileNumber, this.email});

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'],
      vendorName: json['vendor_name'],
      shopName: json['shop_name'],
      mobileNumber: json['mobile_number'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_name': vendorName,
        'shop_name': shopName,
        'mobile_number': mobileNumber,
        'email': email,
      };
}

class DeliveryAddressModel {
  final int? id;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final AreaModel? state;
  final AreaModel? city;
  final AreaModel? area;

  DeliveryAddressModel({
    this.id,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.pincode,
    this.latitude,
    this.longitude,
    this.state,
    this.city,
    this.area,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      landmark: json['landmark'],
      pincode: json['pincode'],
      latitude: OrderModel._parseDouble(json['latitude']),
      longitude: OrderModel._parseDouble(json['longitude']),
      state: json['state'] != null ? AreaModel.fromJson(json['state']) : null,
      city: json['city'] != null ? AreaModel.fromJson(json['city']) : null,
      area: json['area'] != null ? AreaModel.fromJson(json['area']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'area': area?.toJson(),
      };
}

class AreaModel {
  final int? id;
  final String? name;

  AreaModel({this.id, this.name});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class OrderItemModel {
  final int? id;
  final int? productId;
  final String? productName;
  final String? productSlug;
  final String? productDescription;
  final List<ProductImageModel>? productImages;
  final int? variantId;
  final String? variantSku;
  final double? variantPrice;
  final double? variantSalePrice;
  final int? quantity;
  final double? unitPrice;
  final double? itemTotal;
  final String? deliveryStatus;

  OrderItemModel({
    this.id,
    this.productId,
    this.productName,
    this.productSlug,
    this.productDescription,
    this.productImages,
    this.variantId,
    this.variantSku,
    this.variantPrice,
    this.variantSalePrice,
    this.quantity,
    this.unitPrice,
    this.itemTotal,
    this.deliveryStatus,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productSlug: json['product_slug'],
      productDescription: json['product_description'],
      productImages: (json['product_images'] as List?)
          ?.map((i) => ProductImageModel.fromJson(i))
          .toList(),
      variantId: json['variant_id'],
      variantSku: json['variant_sku'],
      variantPrice: OrderModel._parseDouble(json['variant_price']),
      variantSalePrice: OrderModel._parseDouble(json['variant_sale_price']),
      quantity: json['quantity'],
      unitPrice: OrderModel._parseDouble(json['unit_price']),
      itemTotal: OrderModel._parseDouble(json['item_total']),
      deliveryStatus: json['delivery_status'],
    );
  }
}

class ProductImageModel {
  final int? id;
  final String? imageUrl;
  final bool? isPrimary;

  ProductImageModel({this.id, this.imageUrl, this.isPrimary});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'],
      imageUrl: json['image_url'],
      isPrimary: json['is_primary'],
    );
  }
}

class PaymentModel {
  final int? id;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? amount;
  final String? transactionId;
  final String? createdAt;

  PaymentModel({
    this.id,
    this.paymentMethod,
    this.paymentStatus,
    this.amount,
    this.transactionId,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      amount: OrderModel._parseDouble(json['amount']),
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
    );
  }
}
