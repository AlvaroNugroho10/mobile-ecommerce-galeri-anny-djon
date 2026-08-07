import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_page.dart';
import 'checkout_page.dart';

class DetailPage extends StatelessWidget {

  final String image;
  final String title;
  final String price;
  final String description;

  // =====================================
  // CATEGORY & SIZE
  // =====================================
  final String category;
  final String size;

  // =====================================
  // SOLD OUT FLAG
  // =====================================
  final bool soldOut;

  const DetailPage({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.size,
    this.soldOut = false,
  });

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    // =====================================
    // SIZE LOGIC
    // =====================================
    String ukuranText = "";

    if (
      category == "Lukisan" ||
      category == "Tas"
    ) {

      ukuranText =
          "Ukuran : $size";

    } else if (
      category == "Baju"
    ) {

      ukuranText =
          "One Size Fits All";
    }

    return Scaffold(

      body: Column(

        children: [

          // =====================================
          // IMAGE SECTION
          // =====================================
          Stack(

            children: [

              Container(

                width: double.infinity,
                height: 360,

                color: AppColors.card,

                child: Center(

                  child: Hero(

                    tag: image,

                    child: Image.asset(

                      image,

                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // =====================================
              // BACK BUTTON
              // =====================================
              Positioned(

                top: 45,
                left: 18,

                child: CircleAvatar(

                  backgroundColor:
                      AppColors.card,

                  child: IconButton(

                    icon: const Icon(
                      Icons.arrow_back,
                    ),

                    onPressed: () {

                      Navigator.pop(
                          context);
                    },
                  ),
                ),
              ),
            ],
          ),

          // =====================================
          // CONTENT
          // =====================================
          Expanded(

            child: Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                24,
              ),

              decoration:
                  const BoxDecoration(

                color: AppColors.card,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(
                    30,
                  ),
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // =====================================
                  // TITLE
                  // =====================================
                  Text(

                    title,

                    style:
                        const TextStyle(

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =====================================
                  // PRICE
                  // =====================================
                  Text(

                    price,

                    style:
                        const TextStyle(

                      fontSize: 22,

                      color:
                          Colors.brown,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =====================================
                  // SIZE INFO
                  // =====================================
                  if (ukuranText.isNotEmpty)

                    Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.brown
                                .withValues(
                          alpha: 0.08,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: Row(

                        children: [

                          const Icon(

                            Icons.straighten,

                            color:
                                Colors.brown,

                            size: 20,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(

                            child: Text(

                              ukuranText,

                              style:
                                  TextStyle(

                                color: Colors
                                    .grey[800],

                                fontWeight:
                                    FontWeight
                                        .w600,

                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =====================================
                  // DESCRIPTION TITLE
                  // =====================================
                  const Text(

                    "Deskripsi Produk",

                    style: TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =====================================
                  // DESCRIPTION
                  // =====================================
                  Expanded(

                    child:
                        SingleChildScrollView(

                      child: Text(

                        description,

                        style:
                            TextStyle(

                          color:
                              Colors.grey[700],

                          height: 1.7,

                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =====================================
                  // SOLD OUT BANNER
                  // =====================================
                  if (soldOut)
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color: Colors.red
                              .shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.block,
                            color: Colors
                                .red.shade600,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Produk ini sudah terjual habis",
                            style: TextStyle(
                              color: Colors
                                  .red.shade700,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // =====================================
                  // BUTTON SECTION
                  // =====================================
                  Row(

                    children: [

                      // =====================================
                      // CART BUTTON
                      // =====================================
                      GestureDetector(

                        onTap: soldOut
                            ? null
                            : () async {

                                if (user ==
                                    null) {

                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(

                                    const SnackBar(

                                      content: Text(
                                        "Silakan login dulu",
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                // =====================================
                                // ADD TO CART
                                // =====================================
                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                        'carts')
                                    .doc(user.uid)
                                    .collection(
                                        'items')
                                    .add({

                                  'name':
                                      title,

                                  'price':
                                      price,

                                  'image':
                                      image,

                                  'description':
                                      description,

                                  'category':
                                      category,

                                  'size':
                                      size,

                                  'createdAt':
                                      FieldValue
                                          .serverTimestamp(),
                                });

                                if (!context
                                    .mounted) { return; }

                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(

                                  const SnackBar(

                                    content: Text(
                                      "Produk masuk ke keranjang",
                                    ),
                                  ),
                                );

                                // =====================================
                                // GO TO CART
                                // =====================================
                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) =>
                                        const CartPage(),
                                  ),
                                );
                              },

                        child: Container(

                          padding:
                              const EdgeInsets
                                  .all(16),

                          decoration:
                              BoxDecoration(

                            color: soldOut
                                ? Colors.grey[300]
                                : Colors.grey[200],

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),

                          child: Icon(

                            Icons
                                .shopping_cart_outlined,

                            size: 24,

                            color: soldOut
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      // =====================================
                      // BUY NOW BUTTON
                      // =====================================
                      Expanded(

                        child: SizedBox(

                          height: 58,

                          child:
                              ElevatedButton(

                            onPressed: soldOut
                                ? null
                                : () {

                                    Navigator.push(

                                      context,

                                      MaterialPageRoute(

                                        builder: (_) =>

                                            // =====================================
                                            // FIX ERROR
                                            // =====================================
                                            CheckoutPage(

                                              items: [

                                                {

                                                  'name':
                                                      title,

                                                  'price':
                                                      price,

                                                  'image':
                                                      image,

                                                  'description':
                                                      description,

                                                  'category':
                                                      category,

                                                  'size':
                                                      size,
                                                }
                                              ],
                                            ),
                                      ),
                                    );
                                  },

                            style:
                                ElevatedButton
                                    .styleFrom(

                              backgroundColor: soldOut
                                  ? Colors.grey[400]
                                  : Colors.brown,

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),

                            child: Text(

                              soldOut
                                  ? "Sold Out"
                                  : "Beli Sekarang",

                              style:
                                  const TextStyle(

                                color:
                                    AppColors.card,

                                fontSize:
                                    16,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}