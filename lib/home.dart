import 'package:flutter/material.dart';
import 'package:flutterku_istimewa/product_detail.dart';
import 'models/product.dart';
import 'api.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String productUrl = '/api/products';
  List<Product> products = [];
  int _selectedIndex = 1;

  Future<List> _getProduct() async {
    List<Product> productsTemp = [];
    var params = {};
    var response = await get(productUrl, params);
    int statusCode = response.statusCode;
    Map responseData = response.data;
    if (statusCode == 200) {
      List data = responseData['data'];
      for (var i = 0; i < data.length; i++) {
        var product = data[i];
        productsTemp.add(Product.fromMap(product));
      }
    }
    products = productsTemp;
    return products;
  }

  Widget createHomeContent() {
    // TextStyle textStyle = Theme.of(context).textTheme.subhead;
    var Content = RefreshIndicator(
        onRefresh: _pullRefresh,
        child: FutureBuilder<List>(
            future: _getProduct(),
            builder: (context, response) {
              if (response.hasData) {
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    Product product = products[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.payment_rounded),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.priceFormatted),
                        trailing: GestureDetector(
                          child: Icon(Icons.payment_rounded),
                          onTap: () {},
                        ),
                        onTap: () async {
                          goToProductDetail(index);
                        },
                      ),
                    );
                  },
                );
              } else if (response.hasError) {
                return Text("${response.error}");
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            }));
    return Content;
  }

  Future<void> _pullRefresh() async {
    await _getProduct();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getProduct();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List menuContent = [Center(child: Text("Your News Feed"),), createHomeContent(), Container(child: Text("Your Profile"),)];
    List menuTitle = ["News Feed", "Product Catalog", "Profile"];
    return Scaffold(
      appBar: AppBar(
        title: Text(menuTitle[_selectedIndex],
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: menuContent[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.house_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void goToProductDetail(int index) async {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return ProductDetailPage(products[index].id);
    }));
  }
}
