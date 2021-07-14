import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/product.dart';
import 'api.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage(this.productId);

  final int productId;

  @override
  _ProductDetailPageState createState() =>
      _ProductDetailPageState(this.productId);
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _productUrl = '/api/products';
  int _indexImageSlider = 0;
  Map<int, int> selectedVariant = {};

  String get productUrl => _productUrl + '/$productId';

  Product? product;
  Map productVariant = {};
  int variantId = 0;
  final int productId;
  double price = 0.0;
  String priceFormatted = '';

  bool get _hasSelectedVariant => selectedVariant.length == 0
      ? false
      : !(selectedVariant.values.toList().any((v) => v == 0));

  _ProductDetailPageState(this.productId);

  Future<Product?> _getProduct() async {
    var params = {};
    var response = await get(productUrl, params);
    int statusCode = response.statusCode;
    Map responseData = response.data;
    if (statusCode == 200) {
      var productData = responseData['data'];
      price = productData['price'];
      if (priceFormatted == '') {
        priceFormatted = productData['price_formatted'];
      }
      product = Product.fromMap(productData);
    }
    return product;
  }

  AlertDialog _openChoice() {
    return AlertDialog(content: Text("You have chosen!"));
  }

  Widget createProductDetailContent() {
    Widget detailContent = FutureBuilder<Product?>(
        future: _getProduct(),
        builder: (context, response) {
          if (response.hasData) {
            Product product = response.data!;
            var image = loadImage(product.imageUrl);
            Text('Data');
            var carousel = Container(
                child: CarouselSlider(
                    items: [Center(child: image)],
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      pauseAutoPlayOnTouch: true,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        // setState(() {
                        //   _indexImageSlider = index;
                        // });
                      },
                    )),
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(width: 5.0, color: Color(0xFFeeeeee)),
                )));
            var dottedIndex = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 10.0,
                    height: 10.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueAccent))
              ],
            );
            var priceWidget = Row(
              children: [
                Container(
                    child: Text(priceFormatted,
                        style: TextStyle(
                            fontSize: 18, color: Color.fromRGBO(0, 0, 0, 1.0))),
                    margin: const EdgeInsets.only(left: 10.0, right: 20.0))
              ],
            );
            var productNameWidget = Row(
              children: [
                Container(
                    child: Text(product.name,
                        style: TextStyle(
                            fontSize: 18, color: Color.fromRGBO(0, 0, 0, 1.0))),
                    margin: const EdgeInsets.only(left: 10.0, right: 20.0))
              ],
            );
            var variantListWidget = <Widget>[];
            var attributes = product.attributes;
            if (attributes.length != 0) {
              for (var i = 0; i < attributes.length; i++) {
                var attribute = attributes[i];
                var variantCateg = Text(attribute["name"],
                    style: TextStyle(
                        fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1.0)));
                var attributeOptions = <Widget>[];
                var attributeValues = attribute["value_ids"];
                var optionTextColorSelected =
                    Color.fromRGBO(255, 255, 255, 1.0);
                int attributeId = attribute['attribute_id'];
                if (!selectedVariant.containsKey(attributeId)) {
                  selectedVariant[attributeId] = 0;
                }

                for (var iv = 0; iv < attributeValues.length; iv++) {
                  var attributeValue = attributeValues[iv];
                  var optionTextColor = Color.fromRGBO(0, 0, 0, 0.8);
                  var optionBoxColor = Colors.white;
                  if (selectedVariant[attributeId] == attributeValue['id']) {
                    optionTextColor = optionTextColorSelected;
                    optionBoxColor = Colors.blue;
                  }

                  attributeOptions.add(GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: optionBoxColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black)),
                        margin: const EdgeInsets.all(1.0),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(attributeValue["name"],
                            style: TextStyle(
                                fontSize: 14, color: optionTextColor)),
                      ),
                      onTap: () {
                        selectedVariant[attributeId] = attributeValue['id'];
                        List selectedVariantValues =
                            selectedVariant.values.toList();
                        if (!(selectedVariantValues.contains(0))) {
                          // Todo:
                          for (int vi = 0; vi < product.variants.length; vi++) {
                            List variantAttributes =
                                product.variants[vi]['value_ids'];
                            if (listEquals(selectedVariantValues,
                                variantAttributes.toList())) {
                              productVariant = product.variants[vi];
                              variantId = productVariant["variant_id"];
                              priceFormatted =
                                  productVariant["price_formatted"];
                              setState(() {});
                              break;
                            }
                          }
                        }
                      }));
                }
                var variantGroup = Container(
                    child: Column(children: [
                      variantCateg,
                      Row(children: attributeOptions)
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    margin: const EdgeInsets.only(left: 10.0, top: 5.0));
                variantListWidget.add(variantGroup);
              }
            }
            var variantContainerWidget = Container(
              child: Column(children: variantListWidget),
            );

            Column productView = Column(children: [
              carousel,
              dottedIndex,
              priceWidget,
              productNameWidget,
              variantContainerWidget,
            ]);

            Color addToCartButtonColor = Colors.white;
            Color addToCartTextColor = Colors.grey;

            if (_hasSelectedVariant || attributes.length == 0) {
              addToCartButtonColor = Colors.blue;
              addToCartTextColor = Colors.white;
            }
            ;
            var addToCartWidget = TextButton(
                onPressed: () {
                  var titleDialog = "";
                  var descriptionDialog = "";
                  if (variantId != 0) {
                    titleDialog = "Congratulations!";
                    descriptionDialog = "You have Chosen " +
                        product.name +
                        " with price " +
                        priceFormatted;
                  } else {
                    titleDialog = "Sorry!";
                    descriptionDialog =
                        "You are still not choosing any variant of " +
                            product.name;
                  }

                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(
                            titleDialog,
                            style: Theme.of(context).textTheme.title,
                          ),
                          content: Text(
                            descriptionDialog,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        );
                      });
                },
                child: Text(
                  "Add to cart",
                  style: TextStyle(
                      color: addToCartTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(addToCartButtonColor)));
            return Scaffold(
                appBar: AppBar(
                    title: Text(product.name,
                        style: TextStyle(color: Colors.white))),
                body: productView,
                bottomNavigationBar: addToCartWidget);
          } else if (response.hasError) {
            return Text("${response.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
    return RefreshIndicator(onRefresh: _pullRefresh, child: detailContent);
  }

  Future<void> _pullRefresh() async {
    await _getProduct();
    setState(() {});
  }

  @override
  void initState() {
    _getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return createProductDetailContent();
  }
}
