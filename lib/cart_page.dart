import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // =====================================
    // USER BELUM LOGIN
    // =====================================
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "User belum login",
          ),
        ),
      );
    }

    return Scaffold(

      // =====================================
      // APPBAR
      // =====================================
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: AppColors.card,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // =====================================
          // HAPUS SEMUA CART
          // =====================================
          IconButton(
            onPressed: () async {
              final items = await FirebaseFirestore
                  .instance
                  .collection('carts')
                  .doc(user.uid)
                  .collection('items')
                  .get();

              for (var doc in items.docs) {
                await doc.reference.delete();
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Keranjang dikosongkan",
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.delete_sweep,
              color: AppColors.card,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // =====================================
          // LIST CART
          // =====================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .doc(user.uid)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                // =====================================
                // LOADING
                // =====================================
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // =====================================
                // KERANJANG KOSONG
                // =====================================
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 80,
                          color: Colors.grey[400],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Keranjang kosong",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Tambahkan produk ke keranjang",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!.docs;

                // =====================================
                // LISTVIEW
                // =====================================
                return ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index];

                    final map =
                        data.data()
                            as Map<String, dynamic>;

                    String name =
                        map['name'] ?? '';

                    String price =
                        map['price'] ?? '';

                    String image =
                        map['image'] ?? '';

                    // =====================================
                    // SAFE SIZE FIX
                    // =====================================
                    String size =
                        map.containsKey('size')
                            ? map['size'] ?? ''
                            : '';

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding:
                          const EdgeInsets.all(
                              12),

                      decoration:
                          BoxDecoration(
                        color: AppColors.card,

                        borderRadius:
                            BorderRadius.circular(
                                18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                                    alpha: 0.04),

                            blurRadius: 8,

                            offset:
                                const Offset(
                                    0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          // =================================
                          // IMAGE
                          // =================================
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    14),

                            child: Image.asset(
                              image,

                              width: 85,
                              height: 85,

                              fit: BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  width: 85,
                                  height: 85,

                                  color:
                                      Colors.grey[
                                          300],

                                  child: const Icon(
                                    Icons.image,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 14),

                          // =================================
                          // INFO
                          // =================================
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                // =============================
                                // NAME
                                // =============================
                                Text(
                                  name,

                                  maxLines: 2,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    fontSize: 16,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                    height: 6),

                                // =============================
                                // SIZE
                                // =============================
                                Text(
                                  size.isEmpty
                                      ? "-"
                                      : size,

                                  style: TextStyle(
                                    fontSize: 12,

                                    color:
                                        Colors.grey[
                                            600],

                                    fontWeight:
                                        FontWeight
                                            .w500,
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

                                // =============================
                                // PRICE
                                // =============================
                                Text(
                                  price,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.brown,

                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // =================================
                          // DELETE
                          // =================================
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),

                            onPressed: () async {
                              await FirebaseFirestore
                                  .instance
                                  .collection(
                                      'carts')
                                  .doc(user.uid)
                                  .collection(
                                      'items')
                                  .doc(data.id)
                                  .delete();

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Produk dihapus",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // =====================================
          // TOTAL + CHECKOUT
          // =====================================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore
                .instance
                .collection('carts')
                .doc(user.uid)
                .collection('items')
                .snapshots(),
            builder:
                (context, snapshot) {
              int total = 0;

              int totalItem = 0;

              if (snapshot.hasData) {
                totalItem =
                    snapshot.data!.docs.length;

                for (var doc
                    in snapshot.data!.docs) {
                  try {
                    int price = int.parse(
                      doc['price']
                          .toString()
                          .replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                    );

                    total += price;
                  } catch (e) {
                    // ignore: parsing error for non-numeric price
                  }
                }
              }

              return Container(
                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.card,

                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.05),

                      blurRadius: 10,

                      offset:
                          const Offset(0, -2),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          "Jumlah Produk",

                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        Text(
                          "$totalItem Item",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          "Total Harga",

                          style: TextStyle(
                            fontSize: 16,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(total),

                          style:
                              const TextStyle(
                            fontSize: 18,

                            fontWeight:
                                FontWeight.bold,

                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(
                        onPressed: () {
                          if (total == 0) {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Keranjang kosong",
                                ),
                              ),
                            );

                            return;
                          }

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                                  const CheckoutPage(),
                            ),
                          );
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.brown,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                        ),

                        child: const Text(
                          "Checkout",

                          style: TextStyle(
                            color: AppColors.card,

                            fontSize: 16,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}