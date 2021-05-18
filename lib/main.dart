import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

void main() async {
  runApp(MaterialApp(
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
  `address_id` INT NOT NULL,
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
  `category_id` INT NOT NULL,
  `category_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`category_id`)) """);
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `seller` (
  `seller_id` INT NOT NULL,
  `seller_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`seller_id`)) """);
    await db.execute(""" CREATE TABLE IF NOT EXISTS  `product` (
  `product_id` INT NOT NULL,
  `product_rate` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `total_amount` INT NOT NULL,
  `price` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `category_id` INT NOT NULL,
  `seller_id` INT NOT NULL,
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
  `shop_id` INT NOT NULL,
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
      """ insert into user (email,phone,username,password,gender,address_id)  values("m@gmail.com",12345, "user1", "12345", "male",1) """);
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => homepage()));
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
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your email')),
          TextFormField(
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your password')),
          TextFormField(
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your gender')),
          TextFormField(
              controller: username,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your phone')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              onPressed: () {},
              child: Text('SIGN UP'),
              color: Colors.redAccent,
            ),
          )
        ],
      ),
    );
  }
}

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  TextEditingController search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.redAccent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // this will be set when a new tab is tapped
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
      body: Column(
        children: [
          TextFormField(
              controller: search,
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  border: UnderlineInputBorder(),
                  labelText: 'Search a product here...')),
        ],
      ),
    );
  }
}
