import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Database db;
int user_id;

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: firstScreen(),
  ));

  // Get a location using getDatabasesPath
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'demo.db');

  await deleteDatabase(path);

  db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table

    await db.execute("""CREATE TABLE address_detail (
  postal_code INT NOT NULL,
  city VARCHAR(45) NOT NULL,
  PRIMARY KEY (postal_code))""");

    // add another table here......
    await db.execute(""" CREATE TABLE IF NOT EXISTS `address` (
  `address_id` INT AUTO_INCREMENT,
  `street` VARCHAR(45) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `postal_code` INT NOT NULL,
  PRIMARY KEY (`address_id`),
  CONSTRAINT `fk_address_address_detail1`
    FOREIGN KEY (`postal_code`)
    REFERENCES  `address_detail` (`postal_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //Create the user table 
    await db.execute(""" CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT  AUTO_INCREMENT,
  `email` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `gender` VARCHAR(45) NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`user_id`),
  
  CONSTRAINT `fk_user_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES  `address` (`address_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //SQFlite query to create category table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `category` (
  `category_id` INT AUTO_INCREMENT,
  `category_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`category_id`)) """);

  //SQFlite query to create seller table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `seller` (
  `seller_id` INT AUTO_INCREMENT,
  `seller_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`seller_id`)) """);

  //SQFlite query to create product table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `product` (
  `product_id` INT AUTO_INCREMENT,
  `product_rate` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `total_amount` INT NOT NULL,
  `price` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `category_id` INT NOT NULL,
  `seller_id` INT NOT NULL,
  `url` TEXT,
  PRIMARY KEY (`product_id`),
  
  CONSTRAINT `fk_product_category1`
    FOREIGN KEY (`category_id`)
    REFERENCES  `category` (`category_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_product_seller1`
    FOREIGN KEY (`seller_id`)
    REFERENCES  `seller` (`seller_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //SQFlite query to create buys table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `buys` (
  `user_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`user_id`, `product_id`),
  
  CONSTRAINT `fk_user_has_product_user`
    FOREIGN KEY (`user_id`)
    REFERENCES  `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_product_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES  `product` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //SQFlite query to create comment table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `comment` (
  `comment` VARCHAR(45) NOT NULL,
  `user_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  
  CONSTRAINT `fk_comment_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES  `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES  `product` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //SQL query to create shops table
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `shops` (
  `shop_id` INT AUTO_INCREMENT,
  `shop_name` VARCHAR(45) NOT NULL,
  `seller_id` INT NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`shop_id`),
  
  CONSTRAINT `fk_shops_seller1`
    FOREIGN KEY (`seller_id`)
    REFERENCES  `seller` (`seller_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_shops_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES  `address` (`address_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION) """);

    //Create Table sold_in query
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `sold_in` (
  `shop_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`shop_id`, `product_id`),
  
  CONSTRAINT `fk_shops_has_product_shops1`
    FOREIGN KEY (`shop_id`)
    REFERENCES  `shops` (`shop_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_shops_has_product_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES  `product` (`product_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)  """);
  });

  //List down all the table names of the app
  var tableNames =
      (await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
          .map((row) => row['name'] as String)
          .toList(growable: false);
  print(tableNames);

  //Insert query to user table
  await db.execute(
      """ insert into user (email,phone,username,password,gender,address_id,user_id)  values("m@gmail.com",12345, "user1", "12345", "male",1,1) """);

  //Insert queries to product table
  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(1,4, "Lenovo Laptop", 12345, 12000, "Lenovo", 1, 1,"https://www.lenovo.com/medias/lenovo-laptop-ideapad-3-15-intel-gallery-1.png?context=bWFzdGVyfHJvb3R8MjIxNjM1fGltYWdlL3BuZ3xoMjIvaDkyLzEwNzU3MjQzOTI4NjA2LnBuZ3xhMjhmOWI5NmQ1ODE2YzIyN2RjZjg0YjU1MTIzYzAyNzY2Y2I3MTU4ZTAyNWI1MjQ5OTY4ZTFjMjBmMzYyNWI4")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(2,5, "Huawei Laptop", 1000, 9000, "Huawei", 1, 2,"https://consumer.huawei.com/content/dam/huawei-cbg-site/common/mkt/pdp/pc/matebook-x-pro-2020/img/pc/huawei-matebook-x-pro-pc.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(3,2, "Samsung Laptop", 1000, 9000, "Samsung", 1, 1,"https://images-na.ssl-images-amazon.com/images/I/819QD8%2BXiFL._AC_SX450_.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(4,4, "Samsung Refrigerator", 500, 3500, "Samsung", 2, 2,"https://5.imimg.com/data5/FB/NX/MY-43601360/samsung-refrigerator-500x500.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(5,5, "Samsung Washing Machine", 500, 4100, "Samsung", 2, 1,"https://media.croma.com/image/upload/v1615902435/Croma%20Assets/Large%20Appliances/Washers%20and%20Dryers/Images/233541_fgxmdm.png")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(6,2, "Bosch Vacuum Cleaner", 500, 2100, "Bosch", 2, 2,"https://cdn11.bigcommerce.com/s-r173ig0mpx/images/stencil/1280x1280/products/235/512/Bosch-Vacuum-Cleaner-Bagged-Steel-2400-Watt-242005081646-100084-R-01__65598.1617541023.jpg?c=1")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(7,3, "Casper Laptop", 800, 2100, "Casper", 1, 2,"https://www.vatanbilgisayar.com/upload/HTML/PCPOR/CASPER/72881/1.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(8,5, " Samsung Chromebook", 800, 1100, "Samsung", 1, 2,"https://www.notebookcheck-tr.com/uploads/tx_nbc2/SamsungChromebookPlusXE521QABK01US__1_.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(9,2, "TCL Laptop", 700, 900, "TCL", 1, 1,"https://i.pinimg.com/originals/07/62/61/07626159af4953b4045aca3f9e0f305f.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(10,5, "Samsung Dishwasher", 700, 3900, "Samsung", 2, 1,"https://s.yimg.com/aah/usappliance/dw80r7061us-samsung-24-built-in-dishwasher-with-stormwash-and-autorelease-door-fingerprint-resistant-stainless-steel-12.jpg")  """);

  await db.rawInsert(
      """ insert into product (product_id,product_rate, name, total_amount, price, brand, category_id, seller_id, url) values(11,4, "Vestel Dishwasher", 100, 2800, "Vestel", 2, 1,"https://cdn.vestelinternational.com/media/15029200237a5bae25aba1fa4e72ae1876fec2a196.jpg")  """);

  await db.rawInsert(
      """ insert into address (address_id,street,postal_code,country) values (1, "Kurtulus Sokak", 38000, "Turkey") """);

  await db.rawInsert(
      """ insert into category (category_id,category_name) values (1, "Computers")  """);

  await db.rawInsert(
      """ insert into category (category_id,category_name) values (2, "Home Technologies")  """);

  await db.rawInsert(
      """ insert into shops (shop_id,shop_name,seller_id,address_id) values (1,"Teknosa", 1,1) """);

  await db.rawInsert(
      """ insert into shops (shop_id,shop_name,seller_id,address_id) values (2,"Media Markt", 2,1) """);
}


class firstScreen extends StatefulWidget {
  /** 
   * The firstscreen stateful widget displays the login screen of the app, the purpose of this controllers
   *  is to take the user and password input from the user
   */
  @override
  _firstScreenState createState() => _firstScreenState();
}

class _firstScreenState extends State<firstScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Cheapie'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Image(
                image: AssetImage('images/logo.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                //Textfield for Username, including the controller 
                child: TextFormField(
                    controller: username,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter your username')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                //Textfield for Username, including the signup
                child: TextFormField(
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your password'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              //Button to log in, it authenticate the user and communicates with the database to ensure that the user exist.
              child: FlatButton(
                onPressed: () async {
                  String usrname = username.text;
                  String passwordd = password.text;
                  //Function to check if the user exist in the database.
                  List<Map> list = await db.rawQuery(
                      'SELECT * FROM user where username = "$usrname" and password = "$passwordd"');

                  if (list.isEmpty == false) {
                    user_id = list[0]['user_id'];
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => screen()));
                  }
                },
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.redAccent,
              ),
            ),
            //Button to navigate to the sign up page
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () {
                  //Function to move the page to the signup.
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => signup()));
                },
                child: Text(
                  "TAP HERE TO SIGN UP! ",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.redAccent,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class signup extends StatefulWidget {
  @override
  _signupState createState() => _signupState();
  /**
   * The signup stateful widget is a page that display the page where user can sign up. 
   * It utilizes controller to manage user input, when the user have entered the necessary information
   * it will then go to the controller and from there will communicate to the database to execute queries.
   */
}

class _signupState extends State<signup> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController email = TextEditingController();
  String dropdownValue = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Sign Up For Cheapie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Textfield for username, including the controller
              TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your username')),
              SizedBox(height: 10),
              //Textfield for email, including the controller
              TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your email')),
              SizedBox(height: 15),
              //Textfield for password, including the controller, the obscuretext help in hiding user input
              TextFormField(
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your password')),
              SizedBox(height: 15),
              //Textfield for phone number, including the controller
              TextFormField(
                  controller: phone,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your phone')),
              SizedBox(height: 15),
              //Textfield for user location, including the controller
              TextFormField(
                  controller: city,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your city')),
              SizedBox(height: 15),
              //Code for drop down button, in this case to choose between male and female
              Padding(
                padding: const EdgeInsets.only(right: 180),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text(
                        'Gender: ',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    DropdownButton<String>(
                      value: dropdownValue,
                      elevation: 16,
                      style: const TextStyle(color: Colors.redAccent),
                      underline: Container(
                        height: 2,
                        color: Colors.redAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              //The button for the signup page, when clicked it execute a SQL query to insert it into the database
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: FlatButton(
                  onPressed: () async {
                    print(phone.text);
                    await db.rawInsert(
                        """ insert into user (username, email,password,gender,phone, address_id,user_id) values ("${username.text}","${email.text}", "${password.text}", "${dropdownValue}", ${phone.text},2,2) """);
                  },
                  child: Text('SIGN UP'),
                  color: Colors.redAccent,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class screen extends StatefulWidget {
  /**
   * The screen Widget displays the home page of the app after the user is succesfully authenticated
   * It utilizes bottom navigation bar that helps the user navigates trough multiple pages seamlessly
   */
  @override
  _screenState createState() => _screenState();
}

class _screenState extends State<screen> {
  int currentIndex = 0;

  //The list of pages that can be visited through the bottom navigation par
  final List<Widget> screens = [
    home(),
    categories(),
    shops(),
    profile(),
  ];

  //Search query
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Cheapie",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          centerTitle: true,
          leading: _isSearching ? const BackButton() : Container(),
          backgroundColor: Colors.redAccent,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex:
              currentIndex, // this will be set when a new tab is tapped
          onTap: (index) {
            onTabTapped(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.category_outlined),
              title: new Text('Categories'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_mall), title: Text('Shops')),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text('Profile')),
          ],
        ),
        body: screens[currentIndex]);
  }
  //Function to switch the page through index
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  List<Map> products = [];

  //Retrieve the list of products from the database.
  getproducts() async {
    products = await db.rawQuery("""select * from product""");
    return products;
  }

  TextEditingController search = TextEditingController();
  @override

  //Implement getFunction when the app is intialized.
  void initState() {
    // TODO: implement initState
    super.initState();
    getproducts();
  }

  @override
  Widget build(BuildContext context) {
    getproducts();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),

            //Textform field that includes the search function
            child: TextFormField(
                controller: search,
                decoration: InputDecoration(
                    icon: GestureDetector(
                      child: GestureDetector(child: Icon(Icons.search)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => searchpage(
                                      name: search.text,
                                    )));
                      },
                    ),
                    border: UnderlineInputBorder(),
                    labelText: 'Search')),
          ),
          Container(
            height: 500,
            child: FutureBuilder(
                future: getproducts(),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.none ||
                      projectSnap.hasData == null ||
                      projectSnap.connectionState == ConnectionState.waiting) {
                    //print('project snapshot data is: ${projectSnap.data}');
                    return CircularProgressIndicator();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                        itemCount: products.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return ClipRRect(
                            child: Hero(
                              tag: projectSnap.data[index]["product_id"],
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => detailpage(
                                        name: projectSnap.data[index]["name"],
                                        pic: projectSnap.data[index]["url"],
                                        rate: projectSnap.data[index]
                                            ["product_rate"],
                                        id: projectSnap.data[index]
                                            ["product_id"],
                                        price: projectSnap.data[index]["price"],
                                        brand: projectSnap.data[index]["brand"],
                                        total_amount: projectSnap.data[index]
                                            ["total_amount"],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(projectSnap.data[index]["name"],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w200,
                                          backgroundColor: Colors.transparent
                                              .withOpacity(0.5))),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            projectSnap.data[index]['url']),
                                        fit: BoxFit.fitWidth),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class categories extends StatefulWidget {
  /**
   * The categories widget displays a page with a list of category, so user can find products by categories.
   * When user select a specific category it will navigate to a page that display the list of products based
   * on that category.
   */
  @override
  _categoriesState createState() => _categoriesState();
}

class _categoriesState extends State<categories> {
  //Function to retrieve the list of category from the database.
  getcategory() async {
    return await db.rawQuery(""" select * from category""");
  }

  @override
  Widget build(BuildContext context) {
    //Futurebuilder to display all the categories
    return FutureBuilder(
        future: getcategory(),
        builder: (context, projectSnap) {
          //Check if connection is established and data is received.
          //If data is not received, return a loading state
          if (projectSnap.connectionState == ConnectionState.none ||
              projectSnap.hasData == null ||
              projectSnap.connectionState == ConnectionState.waiting) {
            //print('project snapshot data is: ${projectSnap.data}');
            return CircularProgressIndicator();
          }

          //If data is received, display this data through a list of categories.
          return ListView.builder(
              //THe length of the list, based on the amount of category available in the database.
              itemCount: projectSnap.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading:
                        index == 0 ? Icon(Icons.computer) : Icon(Icons.home),
                    tileColor: Colors.red.shade100,
                    title: Text(projectSnap.data[index]['category_name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => categoryList(
                              category_id: (index + 1),
                              category_name: projectSnap.data[index]
                                  ['category_name']),
                        ),
                      );
                    },
                  ),
                );
              });
        });
  }
}

class shops extends StatefulWidget {
  /**
   * The shops widget displays a page with a list of shops, so user can find products by shops.
   * When user select a specific category it will navigate to a page that display the list of products based
   * on the chosen shop.
   */
  @override
  _shopsState createState() => _shopsState();
}

class _shopsState extends State<shops> {
  //Retrieve the list of categories from the database
  getcategory() async {
    return await db.rawQuery(""" select * from category""");
  }

  //Retrieve the list of shops from the database
  getshops() async {
    return await db.rawQuery(""" select * from shops""");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //Futurebuilder to display all the shops
        future: getshops(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none ||
              projectSnap.hasData == null ||
              projectSnap.connectionState == ConnectionState.waiting) {
            //print('project snapshot data is: ${projectSnap.data}');
            return CircularProgressIndicator();
          }
          return ListView.builder(
              itemCount: projectSnap.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.red.shade100,
                    title: Text(projectSnap.data[index]['shop_name']),
                  ),
                );
              });
        });
  }
}

class profile extends StatefulWidget {
  /**
   * The profile widget displays all the information of the user.
   * this is retrieved from the database.
   */
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {

  //Function to retrieve list of details 
  getDetails() async {
    List<Map> list = await db.rawQuery(
        """ select * from user, address where user_id = ${user_id}  """);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    getDetails();
    return FutureBuilder(
      //Futurebuilder to display user details
        future: getDetails(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
                  projectSnap.hasData == null ||
              projectSnap.connectionState == ConnectionState.waiting) {
            //print('project snapshot data is: ${projectSnap.data}');
            return CircularProgressIndicator();
          }
          return Column(
            children: [
              //Display username 
              ListTile(
                title: Text("User Name"),
                subtitle: Text(projectSnap.data[0]["username"]),
              ),
              //Display user email information
              ListTile(
                title: Text("Email"),
                subtitle: Text(projectSnap.data[0]["email"]),
              ),
              //Display user phone number
              ListTile(
                title: Text("Phone Number"),
                subtitle: Text(projectSnap.data[0]["phone"]),
              ),
              //Display user location
              ListTile(
                title: Text("Country"),
                subtitle: Text(projectSnap.data[0]["country"]),
              ),
              //Display user postal code
              ListTile(
                title: Text("Postal Code"),
                subtitle: Text(projectSnap.data[0]["postal_code"].toString()),
              ),
            ],
          );
        });
  }
}

class detailpage extends StatefulWidget {
  int id;
  String name;
  String pic;
  int rate;
  int price;
  String brand;
  int total_amount;

  detailpage(
      {this.name,
      this.pic,
      this.rate,
      this.id,
      this.price,
      this.brand,
      this.total_amount});
  @override
  _detailpageState createState() => _detailpageState();

  /**
   * The detailspage widget displays detail information regarding the product, it will retrieve information
   * from the database regarding the various products, including name, picture, rating, id, price and brand.
   * It also include user comments. 
   */
}

class _detailpageState extends State<detailpage> {
  List<Map> comments = [];
  TextEditingController comment = TextEditingController();

  //Functions to retrieve the comments from the database.
  getComments() async {
    comments = await db.rawQuery(
        """ select * from comment where product_id = ${widget.id} and user_id = $user_id """);
    print("user idd : " + user_id.toString());
    print("product id : " + widget.id.toString());
    return comments;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Run function when app is first initialized.
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details of ${widget.name}"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Image(image: NetworkImage(widget.pic)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Rating of the product: ",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            RatingBar.builder(
                initialRating: widget.rate.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                onRatingUpdate: (rating) async {
                  double newrating = (widget.rate + rating) / 2;
                  //Update product rating based on user rating
                  await db.rawUpdate(
                      """ update product set product_rate = ${newrating} where product_id = ${widget.id}""");

                  print(rating);
                }),
            SizedBox(height: 15),
            //Display all the details of the product
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  width: double.infinity,
                  // color: Colors.green,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(children: <Widget>[
                          Expanded(child: Divider(thickness: 2)),
                          Text(
                            'Product Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.textScaleFactorOf(context) * 20,
                            ),
                          ),
                          Expanded(child: Divider(thickness: 2)),
                        ]),
                      ),
                      SizedBox(height: 20),
                      //Display product price
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Price: ${widget.price}",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      //Display amount in stock
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'In stock: ${widget.total_amount}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.textScaleFactorOf(context) * 19,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      //Display product brand
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Brand: ${widget.brand}',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.textScaleFactorOf(context) * 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 40),
            //Display Comments
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19.0),
              child: Row(children: <Widget>[
                Expanded(child: Divider(thickness: 1.5)),
                Text(
                  'Comments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.textScaleFactorOf(context) * 20,
                  ),
                ),
                Expanded(child: Divider(thickness: 1.5)),
              ]),
            ),
            //Futurebuilder that automatically update when there is new comments
            FutureBuilder(
                future: getComments(),
                builder: (context, projectSnap) {
                  //Check if connection has data
                  if (projectSnap.connectionState == ConnectionState.none ||
                      projectSnap.hasData == null ||
                      projectSnap.connectionState == ConnectionState.waiting) {
                    //print('project snapshot data is: ${projectSnap.data}');
                    return CircularProgressIndicator();
                  }

                  //Display user comments
                  return Container(
                    height: 200,
                    child: projectSnap.data.length != 0
                        ? ListView.builder(
                            itemCount: projectSnap.data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    leading: Icon(Icons.comment),
                                    title: Text("User ${user_id} has said:"),
                                    subtitle: Text(
                                        projectSnap.data[index]["comment"]),
                                    tileColor: Colors.red.shade100),
                              );
                            })
                        : Center(
                            child: Text(
                              'This product has no comments yet, Be the first to comment',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  );
                }),
            Container(
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                border: new Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(255),
                ],
                controller: comment,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: UnderlineInputBorder(),
                    labelText: ' comment here'),
              ),
            ),
            //Button that execute an insert to the database when pressed.
            FlatButton(
                onPressed: () async {
                  await db.rawInsert(
                      """ insert into comment (comment, user_id,product_id) values ("${comment.text}",$user_id, ${widget.id}) """);
                  setState(() {});
                },
                child: Text("Add Your Comment"))
          ],
        ),
      ),
    );
  }
}

// for search page...

class searchpage extends StatefulWidget {
  String name;
  searchpage({this.name});

  @override
  _searchpageState createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  /**
   * The searchpage state includes the search function, it will communicate with the database to execute read functions
   */
  List<Map> result = [];

  //Function to retrieve the result based on user input
  getresult() async {
    List<Map> aa;
    aa = await db.rawQuery(
        """ select * from  product, category where category.category_id = product.category_id and (product.name like "%${widget.name}%" or category.category_name like "%${widget.name}%") """);
    setState(() {
      result = aa;
    });
  }

  //Function to refresh the search function
  Future<bool> refresh() async {
    List<Map> aa;
    aa = await db.rawQuery(
        """ select * from  product, category where category.category_id = product.category_id and (product.name like "%${widget.name}%" or category.category_name like "%${widget.name}%") """);
    setState(() {
      result = aa;
    });
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getresult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Results for ${widget.name}"),
          backgroundColor: Colors.redAccent,
        ),
        body: result.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: 550,
                    child: RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView.builder(
                          itemCount: result.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => detailpage(
                                        name: result[index]["name"],
                                        pic: result[index]["url"],
                                        rate: result[index]["product_rate"],
                                        id: result[index]["product_id"],
                                        price: result[index]["price"],
                                        brand: result[index]["brand"],
                                        total_amount: result[index]
                                            ["total_amount"],
                                      ),
                                    ),
                                  );
                                },
                                leading: Image(
                                  image: NetworkImage(result[index]["url"]),
                                ),
                                title: Text(result[index]["name"]),
                                subtitle: Text("Price : " +
                                    result[index]["price"].toString() +
                                    "\n" +
                                    "Rate : ${result[index]['product_rate']}/5 "),
                                isThreeLine: true,
                              ),
                            );
                          }),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 57,
                          child: TextButton(
                            onPressed: () async {
                              List<Map> aa;
                              aa = await db.rawQuery(
                                  """ select * from  product, category where category.category_id = product.category_id and (product.name like "%${widget.name}%" or category.category_name like "%${widget.name}%") order by price""");
                              setState(() {
                                result = aa;
                              });
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.arrow_downward_outlined),
                                )
                              ],
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.redAccent)),
                          ),
                        ),
                      ),
                      Container(
                        width: 57,
                        child: TextButton(
                          onPressed: () async {
                            List<Map> aa;
                            aa = await db.rawQuery(
                                """ select * from  product, category where category.category_id = product.category_id and (product.name like "%${widget.name}%" or category.category_name like "%${widget.name}%") order by product_rate desc""");
                            setState(() {
                              result = aa;
                            });
                          },
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.star_rate_rounded))
                            ],
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.redAccent)),
                        ),
                      ),
                      Container(
                        width: 57,
                        child: TextButton(
                          onPressed: () async {
                            List<Map> aa;
                            aa = await db.rawQuery(
                                """ select * from  product, category where category.category_id = product.category_id and (product.name like "%${widget.name}%" or category.category_name like "%${widget.name}%") order by product_rate desc, price asc""");
                            setState(() {
                              result = aa;
                            });
                          },
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.attach_money_rounded))
                            ],
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.redAccent)),
                        ),
                      ),
                    ],
                  )
                ],
              ));
  }
}

//====================================================== Categories List Shop ==============================

class categoryList extends StatefulWidget {
  /**
   * The category List will list all the products based on user category selection from the database. 
   * This will help users in choosing product based on the category of preference.
   */
  int category_id;
  String category_name;

  categoryList({
    this.category_id,
    this.category_name,
  });

  @override
  _categoryListState createState() => _categoryListState();
}

class _categoryListState extends State<categoryList> {
  List<Map> productsByCategory = [];

  // the function below is async and is used to fetch products based on their category.
  getproductsByCategory() async {
    productsByCategory = await db.rawQuery(
        """select * from product WHERE category_id = ${widget.category_id} """);
    print(productsByCategory.length);
    return productsByCategory;
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getproductsByCategory();
    print(widget.category_name);
  }

  @override
  Widget build(BuildContext context) {
    getproductsByCategory();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        title: Text('${widget.category_name}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 500,
              child: FutureBuilder(
                  future: getproductsByCategory(),
                  builder: (context, projectSnap) {
                    if (projectSnap.connectionState == ConnectionState.none ||
                        projectSnap.hasData == null ||
                        projectSnap.connectionState ==
                            ConnectionState.waiting) {
                      //print('project snapshot data is: ${projectSnap.data}');
                      return CircularProgressIndicator();
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemCount: productsByCategory.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return ClipRRect(
                              child: Hero(
                                tag: projectSnap.data[index]["product_id"],
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to the list of product based on their category.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => detailpage(
                                          name: projectSnap.data[index]["name"],
                                          pic: projectSnap.data[index]["url"],
                                          rate: projectSnap.data[index]
                                              ["product_rate"],
                                          id: projectSnap.data[index]
                                              ["product_id"],
                                          price: projectSnap.data[index]
                                              ["price"],
                                          brand: projectSnap.data[index]
                                              ["brand"],
                                          total_amount: projectSnap.data[index]
                                              ["total_amount"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(projectSnap.data[index]["name"],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w200,
                                            backgroundColor: Colors.transparent
                                                .withOpacity(0.5))),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              projectSnap.data[index]['url']),
                                          fit: BoxFit.fitWidth),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
