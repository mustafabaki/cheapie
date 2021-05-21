import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Database db;
int user_id;

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: true,
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
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `category` (
  `category_id` INT AUTO_INCREMENT,
  `category_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`category_id`)) """);
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `seller` (
  `seller_id` INT AUTO_INCREMENT,
  `seller_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`seller_id`)) """);
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

  var tableNames =
      (await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
          .map((row) => row['name'] as String)
          .toList(growable: false);
  print(tableNames);

  await db.execute(
      """ insert into user (email,phone,username,password,gender,address_id,user_id)  values("m@gmail.com",12345, "user1", "12345", "male",1,1) """);

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
      ),
      body: Column(
        children: [
          Center(
            child: Image(
              image: AssetImage('images/logo.png'),
            ),
          ),
          TextFormField(
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username')),
          TextFormField(
            controller: password,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your password'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () async {
                String usrname = username.text;
                String passwordd = password.text;
                List<Map> list = await db.rawQuery(
                    'SELECT * FROM user where username = "$usrname" and password = "$passwordd"');

                if (list.isEmpty == false) {
                  user_id = list[0]['user_id'];
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => screen()));
                }
              },
              child: Text("LOGIN"),
              color: Colors.redAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => signup()));
              },
              child: Text("TAP HERE TO SIGN UP! "),
              color: Colors.redAccent,
            ),
          )
        ],
      ),
    );
  }
}

class signup extends StatefulWidget {
  @override
  _signupState createState() => _signupState();
}

class _signupState extends State<signup> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Sign Up For Cheapie'),
      ),
      body: Column(
        children: [
          TextFormField(
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username')),
          TextFormField(
              controller: email,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your email')),
          TextFormField(
              controller: password,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your password')),
          TextFormField(
              controller: gender,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your gender')),
          TextFormField(
              controller: phone,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your phone')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () async {
                await db.rawInsert(
                    """ insert into user (username, email,password,gender,phone, address_id,user_id) values ("${username.text}","${email.text}", "${password.text}", "${gender.text}", ${phone.text},2,2) """);
              },
              child: Text('SIGN UP'),
              color: Colors.redAccent,
            ),
          )
        ],
      ),
    );
  }
}

class screen extends StatefulWidget {
  @override
  _screenState createState() => _screenState();
}

class _screenState extends State<screen> {
  int currentIndex = 0;
  final List<Widget> screens = [home(), categories(), shops(), profile()];
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cheapie"),
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
                icon: Icon(Icons.person), title: Text('Profile'))
          ],
        ),
        body: screens[currentIndex]);
  }

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
  getproducts() async {
    products = await db.rawQuery("""select * from product""");
    return products;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getproducts();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController search = TextEditingController();
    getproducts();
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
            future: getproducts(),
            builder: (context, projectSnap) {
              if (projectSnap.connectionState == ConnectionState.none &&
                  projectSnap.hasData == null) {
                //print('project snapshot data is: ${projectSnap.data}');
                return Container();
              }

              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: products.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => detailpage(
                                      name: projectSnap.data[index]["name"],
                                      pic: projectSnap.data[index]["url"],
                                      rate: projectSnap.data[index]
                                          ["product_rate"],
                                      id: projectSnap.data[index]["product_id"],
                                      price: projectSnap.data[index]["price"],
                                    )));
                      },
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Text(projectSnap.data[index]["name"]),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image:
                                  NetworkImage(projectSnap.data[index]['url']),
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    );
                  });
            }));
  }
}

class categories extends StatefulWidget {
  @override
  _categoriesState createState() => _categoriesState();
}

class _categoriesState extends State<categories> {
  getcategory() async {
    return await db.rawQuery(""" select * from category""");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getcategory(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
          }
          return ListView.builder(
              itemCount: projectSnap.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.red.shade100,
                    title: Text(projectSnap.data[index]['category_name']),
                  ),
                );
              });
        });
  }
}

class shops extends StatefulWidget {
  @override
  _shopsState createState() => _shopsState();
}

class _shopsState extends State<shops> {
  getcategory() async {
    return await db.rawQuery(""" select * from category""");
  }

  getshops() async {
    return await db.rawQuery(""" select * from shops""");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getshops(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
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
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  getDetails() async {
    List<Map> list = await db.rawQuery(
        """ select * from user, address where user_id = ${user_id}  """);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    getDetails();
    return FutureBuilder(
        future: getDetails(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return CircularProgressIndicator();
          }
          return Column(
            children: [
              ListTile(
                title: Text("User Name"),
                subtitle: Text(projectSnap.data[0]["username"]),
              ),
              ListTile(
                title: Text("Email"),
                subtitle: Text(projectSnap.data[0]["email"]),
              ),
              ListTile(
                title: Text("Phone Number"),
                subtitle: Text(projectSnap.data[0]["phone"]),
              ),
              ListTile(
                title: Text("Country"),
                subtitle: Text(projectSnap.data[0]["country"]),
              ),
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
  detailpage({this.name, this.pic, this.rate, this.id, this.price});
  @override
  _detailpageState createState() => _detailpageState();
}

class _detailpageState extends State<detailpage> {
  List<Map> comments = [];
  TextEditingController comment = TextEditingController();

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
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details of ${widget.name}"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView(
        children: [
          Image(image: NetworkImage(widget.pic)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Rating of the product: ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          RatingBar.builder(
              initialRating: widget.rate.toDouble(),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
              onRatingUpdate: (rating) {
                print(rating);
              }),
          Text(
            "Price: ${widget.price}",
            style: TextStyle(fontSize: 20),
          ),
          FutureBuilder(
              future: getComments(),
              builder: (context, projectSnap) {
                if (projectSnap.connectionState == ConnectionState.none &&
                    projectSnap.hasData == null) {
                  //print('project snapshot data is: ${projectSnap.data}');
                  return Container();
                }
                return Container(
                  height: 200,
                  child: ListView.builder(
                      itemCount: projectSnap.data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.comment),
                              title: Text("User ${user_id} has said:"),
                              subtitle:
                                  Text(projectSnap.data[index]["comment"]),
                              tileColor: Colors.red.shade100),
                        );
                      }),
                );
              }),
          TextFormField(
            controller: comment,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'You can add your comment here'),
          ),
          FlatButton(
              onPressed: () async {
                await db.rawInsert(
                    """ insert into comment (comment, user_id,product_id) values ("${comment.text}",$user_id, ${widget.id}) """);
              },
              child: Text("Add Your Comment"))
        ],
      ),
    );
  }
}

// for search page...

class searchpage extends StatefulWidget {
  String name;
  @override
  _searchpageState createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
