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
  final String? trackingId;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? totalAmount;
  final String? createdAt;
  final String? deliveryTimePaymentMode;
  final String? cancelReason;
  final String? confirmedAt;
  final String? deliveredAt;
  final CustomerModel? customer;
  final VendorModel? vendor;
  final DeliveryAddressModel? deliveryAddress;
  final List<OrderItemModel>? items;
  final List<PaymentModel>? payments;
  final double? itemsTotal;
  final double? deliveryCharge;
  final double? totalPayable;
  final double? totalPaid;
  final double? totalDue;
  final Map<String, dynamic>? rtData;
  final Map<String, dynamic>? rvpData;
  final String? fulfillmentCenterName;

  OrderModel({
    this.id,
    this.orderNumber,
    this.trackingId,
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
    this.deliveryTimePaymentMode,
    this.cancelReason,
    this.customer,
    this.vendor,
    this.deliveryAddress,
    this.items,
    this.payments,
    this.itemsTotal,
    this.deliveryCharge,
    this.totalPayable,
    this.totalPaid,
    this.totalDue,
    this.rtData,
    this.rvpData,
    this.fulfillmentCenterName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Robust address mapping for summary API
    DeliveryAddressModel? fallbackAddress;
    if (json['customer_address'] != null) {
      fallbackAddress =
          DeliveryAddressModel(addressLine1: json['customer_address']);
    }

    // Robust customer mapping for summary API
    CustomerModel? fallbackCustomer;
    if (json['customer_name'] != null || json['mobileno'] != null) {
      fallbackCustomer = CustomerModel(
        name: json['customer_name'],
        mobile: json['mobileno'],
      );
    }

    return OrderModel(
      id: json['id'] ?? json['order_id'],
      orderNumber: json['order_number'] ?? json['tracking_id'],
      orderStatus: json['order_status'],
      orderType: json['order_type'],
      deliveryType: json['delivery_type'],
      isExpress: json['is_express'] is bool
          ? json['is_express']
          : json['is_express'] == 1,
      slaMinutes: json['sla_minutes'] is int
          ? json['sla_minutes']
          : int.tryParse(json['sla_minutes']?.toString() ?? ''),
      slaMinutesRemaining: json['sla_minutes_remaining'],
      isSlaBreached:
          json['sla_status'] == 'breached' || json['is_sla_breached'] == true,
      slaStatus: json['sla_status'],
      trackingId: json['tracking_id']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? json['payment_type']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      totalAmount: _parseFloatOrNum(json['total_payable'] ??
          json['payable_amount'] ??
          json['total_amount'] ??
          json['grand_total'] ??
          json['amount']),
      createdAt: json['created_at'],
      confirmedAt: json['confirmed_at'],
      deliveredAt: json['delivered_at'],
      deliveryTimePaymentMode: json['delivery_time_payment_mode']?.toString(),
      cancelReason: json['cancel_reason']?.toString() ?? json['reason']?.toString() ?? json['remarks']?.toString(),
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : fallbackCustomer,
      vendor:
          json['vendor'] != null ? VendorModel.fromJson(json['vendor']) : null,
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddressModel.fromJson(json['delivery_address'])
          : fallbackAddress,
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
      itemsTotal: _parseDouble(json['items_total']),
      deliveryCharge: _parseDouble(json['delivery_charge']),
      totalPayable: _parseDouble(json['total_payable']),
      totalPaid: _parseDouble(json['total_paid']),
      totalDue: _parseDouble(json['total_due']),
      rtData: (json['rt_data'] ?? json['rt']) as Map<String, dynamic>?,
      rvpData: (json['rvp_data'] ?? json['rvp']) as Map<String, dynamic>?,
      fulfillmentCenterName: json['fulfillment_center'] != null
          ? (json['fulfillment_center'] is Map
                  ? json['fulfillment_center']['name']
                  : json['fulfillment_center'])
              ?.toString()
          : null,
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
      'fulfillment_center_name': fulfillmentCenterName,
    };
  }

  static double? _parseFloatOrNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove commas and other non-numeric chars if needed, but tryParse is usually enough
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    return _parseFloatOrNum(value);
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
  final String? address;

  VendorModel({
    this.id,
    this.vendorName,
    this.shopName,
    this.mobileNumber,
    this.email,
    this.address,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final rawAddress =
        json['address'] ?? json['shop_address'] ?? json['vendor_address'];
    String? formattedAddress;

    if (rawAddress is Map<String, dynamic>) {
      formattedAddress = _formatAddressJson(rawAddress);
    } else {
      formattedAddress = rawAddress?.toString();
    }

    return VendorModel(
      id: json['id'],
      vendorName: json['vendor_name'] ?? json['name'],
      shopName: json['shop_name'] ?? json['vendor_name'] ?? json['name'],
      mobileNumber: json['mobile_number'] ?? json['mobile'],
      email: json['email'],
      address: formattedAddress,
    );
  }

  static String _formatAddressJson(Map<String, dynamic> addressMap) {
    String address = addressMap['address_line1'] ?? addressMap['address'] ?? '';
    if (address.isEmpty && addressMap['landmark'] != null) {
      address = addressMap['landmark']?.toString() ?? '';
    }

    final area = addressMap['area'];
    if (area != null) {
      final areaName = area is Map ? area['name'] : area.toString();
      if (areaName != null && areaName.toString().isNotEmpty) {
        if (address.isNotEmpty) address += ", ";
        address += areaName.toString();
      }
    }

    final city = addressMap['city'];
    if (city != null) {
      final cityName = city is Map ? city['name'] : city.toString();
      if (cityName != null && cityName.toString().isNotEmpty) {
        if (address.isNotEmpty) address += ", ";
        address += cityName.toString();
      }
    }

    if (addressMap['pincode'] != null &&
        addressMap['pincode'].toString().isNotEmpty) {
      if (address.isNotEmpty) address += " - ";
      address += addressMap['pincode'].toString();
    }

    return address.isEmpty ? '' : address;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_name': vendorName,
        'shop_name': shopName,
        'mobile_number': mobileNumber,
        'email': email,
        'address': address,
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
  final List<OtherChargeModel>? otherCharges;

  PaymentModel({
    this.id,
    this.paymentMethod,
    this.paymentStatus,
    this.amount,
    this.transactionId,
    this.createdAt,
    this.otherCharges,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      amount: OrderModel._parseDouble(json['amount']),
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
      otherCharges: json['other_charges'] != null
          ? (json['other_charges'] as List)
              .map((o) => OtherChargeModel.fromJson(o))
              .toList()
          : null,
    );
  }
}

class OtherChargeModel {
  final int? id;
  final String? type;
  final String? label;
  final double? amount;
  final bool? isDiscount;

  OtherChargeModel({
    this.id,
    this.type,
    this.label,
    this.amount,
    this.isDiscount,
  });

  factory OtherChargeModel.fromJson(Map<String, dynamic> json) {
    return OtherChargeModel(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      amount: OrderModel._parseDouble(json['amount']),
      isDiscount: json['is_discount'] is bool
          ? json['is_discount']
          : json['is_discount'] == 1,
    );
  }
}
