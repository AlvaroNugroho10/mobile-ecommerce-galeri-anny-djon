import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail_page.dart';
import 'cart_page.dart';
import 'category_page.dart';
import 'login_page.dart';
import 'order_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // =====================================
                // HEADER (SUDAH DIPERBAIKI ANTI-OVERFLOW)
                // =====================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // =================================
                    // USER (SISI KIRI)
                    // =================================
                    Expanded( // <-- KUNCI UTAMA: Memaksa area kiri fleksibel agar tombol kanan tidak terdorong keluar layar
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.brown.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.person,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded( // <-- Membuat teks email otomatis memotong pakai titik-titik (...) jika layar HP sempit
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello 👋",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? 'User',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8), // Jarak aman antara profil teks dan tombol aksi

                    // =================================
                    // ACTION (SISI KANAN)
                    // =================================
                    Row(
                      mainAxisSize: MainAxisSize.min, // Mengunci ukuran baris tombol pas sesuai isinya
                      children: [
                        // TOMBOL HISTORY
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderHistoryPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Colors.brown,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // TOMBOL LOGOUT
                        GestureDetector(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.logout,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // =====================================
                // SEARCH + CART
                // =====================================
                Row(

                  children: [

                    Expanded(

                      child: SizedBox(

                        height: 52,

                        child: TextField(

                          onChanged: (value) {

                            setState(() {

                              searchText =
                                  value.toLowerCase();
                            });
                          },

                          decoration:
                              InputDecoration(

                            hintText:
                                "Cari produk...",

                            prefixIcon:
                                const Icon(
                              Icons.search,
                            ),

                            filled: true,

                            fillColor:
                                AppColors.card,

                            border:
                                OutlineInputBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),

                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // =================================
                    // CART
                    // =================================
                    GestureDetector(

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const CartPage(),
                          ),
                        );
                      },

                      child: Container(

                        width: 52,
                        height: 52,

                        decoration:
                            BoxDecoration(

                          color: Colors.brown,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        child: Stack(

                          alignment:
                              Alignment.center,

                          children: [

                            const Icon(

                              Icons.shopping_cart,

                              color: AppColors.card,
                            ),

                            Positioned(

                              top: 5,
                              right: 5,

                              child:
                                  StreamBuilder(

                                stream:
                                    FirebaseFirestore
                                        .instance
                                        .collection(
                                            'carts')
                                        .doc(
                                            user!.uid)
                                        .collection(
                                            'items')
                                        .snapshots(),

                                builder:
                                    (
                                  context,
                                  snapshot,
                                ) {

                                  if (!snapshot
                                          .hasData ||
                                      snapshot
                                          .data!
                                          .docs
                                          .isEmpty) {

                                    return const SizedBox();
                                  }

                                  int total =
                                      snapshot
                                          .data!
                                          .docs
                                          .length;

                                  return Container(

                                    padding:
                                        const EdgeInsets
                                            .all(5),

                                    decoration:
                                        const BoxDecoration(

                                      color:
                                          Colors.red,

                                      shape:
                                          BoxShape
                                              .circle,
                                    ),

                                    child: Text(

                                      total
                                          .toString(),

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors
                                                .white,

                                        fontSize:
                                            10,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =====================================
                // CATEGORY
                // =====================================
                const Text(

                  "Kategori",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    categoryItem(
                      context,
                      "Lukisan",
                    ),

                    categoryItem(
                      context,
                      "Tas",
                    ),

                    categoryItem(
                      context,
                      "Baju",
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =====================================
                // PRODUCT TITLE
                // =====================================
                const Text(

                  "Produk",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================
                // PRODUCT GRID
                // =====================================
                StreamBuilder(

                  stream: searchText.isEmpty

                      ? FirebaseFirestore
                          .instance
                          .collection(
                              'products')
                          .snapshots()

                      : FirebaseFirestore
                          .instance
                          .collection(
                              'products')
                          .orderBy(
                              'name_lower')
                          .startAt(
                              [searchText])
                          .endAt([
                            '$searchText\uf8ff'
                          ])
                          .snapshots(),

                  builder:
                      (context, snapshot) {

                    if (!snapshot.hasData) {

                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    final products =
                        snapshot.data!.docs;

                    if (products.isEmpty) {

                      return const Center(
                        child: Text(
                          "Produk tidak ditemukan",
                        ),
                      );
                    }

                    return GridView.builder(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          products.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: 2,

                        crossAxisSpacing:
                            14,

                        mainAxisSpacing:
                            14,

                        childAspectRatio:
                            0.63,
                      ),

                      itemBuilder:
                          (context, index) {

                        final data =
                            products[index];

                        // Akses aman agar field baru
                        // yang belum ada tidak throw error
                        final dataMap = data.data();

                        return productCard(

                          context: context,

                          name:
                              dataMap['name'] ??
                                  '',

                          price:
                              dataMap['price'] ??
                                  '',

                          image:
                              dataMap['image'] ??
                                  '',

                          description:
                              dataMap['description'] ??
                                  '',

                          category:
                              dataMap['category'] ??
                                  '',

                          size:
                              dataMap['size'] ??
                                  '',

                          soldOut:
                              dataMap['soldOut'] ??
                                  false,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================
  // CATEGORY ITEM
  // =========================================
  Widget categoryItem(
    BuildContext context,
    String title,
  ) {

    // =====================================
    // CATEGORY IMAGE
    // =====================================
    String categoryImage = "";

    if (title == "Lukisan") {

      categoryImage =
          "assets/Lukisan.jpg";

    } else if (title == "Tas") {

      categoryImage =
          "assets/Tas.jpg";

    } else if (title == "Baju") {

      categoryImage =
          "assets/Baju.jpg";
    }

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
                CategoryPage(
              category: title,
            ),
          ),
        );
      },

      child: Column(

        children: [

          Container(

            width: 108,
            height: 108,

            decoration: BoxDecoration(

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              boxShadow: [

                BoxShadow(

                   color:
                       Colors.black.withValues(
                     alpha: 0.06,
                   ),

                  blurRadius: 10,

                  offset:
                      const Offset(0, 4),
                ),
              ],
            ),

            child: ClipRRect(

              borderRadius:
                  BorderRadius.circular(
                22,
              ),

              child: Image.asset(

                categoryImage,

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(

            title,

            style: const TextStyle(

              fontSize: 14,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // PRODUCT CARD
  // =========================================
  Widget productCard({

    required BuildContext context,
    required String name,
    required String price,
    required String image,
    required String description,
    required String category,
    required String size,
    bool soldOut = false,

  }) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Container(

      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(

        color: AppColors.card,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =================================
          // IMAGE
          // =================================
          GestureDetector(

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      DetailPage(

                    image: image,
                    title: name,
                    price: price,
                    description:
                        description,

                    category:
                        category,

                    size: size,

                    soldOut: soldOut,
                  ),
                ),
              );
            },

            child: Stack(
              children: [
                ClipRRect(

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  child: Hero(

                    tag: image,

                    child: ColorFiltered(
                      colorFilter: soldOut
                          ? const ColorFilter.mode(
                              Colors.black38,
                              BlendMode.darken,
                            )
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: Image.asset(

                        image,

                        height: 150,

                        width: double.infinity,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // =================================
                // SOLD OUT BADGE
                // =================================
                if (soldOut)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "SOLD OUT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =================================
          // PRODUCT NAME
          // =================================
          Text(

            name,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(

              fontWeight:
                  FontWeight.w600,

              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          // =================================
          // SIZE
          // =================================
          Text(

            size.isEmpty
                ? "-"
                : size,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(

              fontSize: 11,

              color: Colors.grey[600],

              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const Spacer(),

          // =================================
          // PRICE + CART
          // =================================
          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Expanded(

                child: Text(

                  price,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 15,

                    color: Colors.brown,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // =================================
              // CART BUTTON (DISABLED IF SOLD OUT)
              // =================================
              GestureDetector(

                onTap: soldOut
                    ? null
                    : () async {

                        await FirebaseFirestore
                            .instance
                            .collection('carts')
                            .doc(user!.uid)
                            .collection('items')
                            .add({

                          'name': name,
                          'price': price,
                          'image': image,
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

                        if (!mounted) return;
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(

                          const SnackBar(
                            content: Text(
                              "Masuk ke keranjang",
                            ),
                          ),
                        );
                      },

                child: Container(

                  padding:
                      const EdgeInsets.all(
                    8,
                  ),

                  decoration:
                      BoxDecoration(

                    color: soldOut
                        ? Colors.grey[300]
                        : Colors.brown,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Icon(

                    soldOut
                        ? Icons.block
                        : Icons.shopping_cart,

                    color: soldOut
                        ? Colors.grey[500]
                        : AppColors.card,

                    size: 18,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}