class Product {
  final List optionalFieldName = ['attribute_line_ids', 'product_variant_ids'];

  Product.fromMap(Map<String, dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._price = map['price'];
    this.priceFormatted = map['price_formatted'];
    this._imageUrl = map['image'];
    if (map.containsKey(optionalFieldName[0])){
      this.attributes = map[optionalFieldName[0]];
    }
    if (map.containsKey(optionalFieldName[1])) {
      this.variants = map[optionalFieldName[1]];
    }
  }

  late String priceFormatted;

  late List attributes;

  late List variants;

  late int _id;

  int get id => _id;

  late String _name;

  String get name => _name;

  late String _imageUrl;

  String get imageUrl => _imageUrl;

  late double _price;

  double get price => _price;
}