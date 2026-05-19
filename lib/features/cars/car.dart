class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.pricePerDay,
    required this.address,
    required this.available,
    this.favorite = false,
  });

  final String id;
  final String brand;
  final String model;
  final double pricePerDay;
  final String address;
  final bool available;
  final bool favorite;

  String get title => '$brand $model';

  Car copyWith({
    String? brand,
    String? model,
    double? pricePerDay,
    String? address,
    bool? available,
    bool? favorite,
  }) {
    return Car(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      address: address ?? this.address,
      available: available ?? this.available,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'brand': brand,
    'model': model,
    'pricePerDay': pricePerDay,
    'address': address,
    'available': available,
    'favorite': favorite,
  };

  factory Car.fromMap(Map<dynamic, dynamic> map) {
    return Car(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      pricePerDay: (map['pricePerDay'] as num).toDouble(),
      address: map['address'] as String,
      available: map['available'] as bool? ?? true,
      favorite: map['favorite'] as bool? ?? false,
    );
  }
}
