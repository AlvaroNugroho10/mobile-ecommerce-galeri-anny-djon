import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail_page.dart';

class CategoryPage extends StatelessWidget {

  final String category;

  const CategoryPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        title: Text(

          category,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.brown,

        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('products')
            .where(
              'category',
              isEqualTo: category,
            )
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
          // EMPTY
          // =====================================
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return Center(

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.grey[400],
                  ),

                  const SizedBox(height: 14),

                  Text(

                    "Produk belum tersedia",

                    style: TextStyle(

                      fontSize: 16,

                      color: Colors.grey[600],

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final products =
              snapshot.data!.docs;

          // =====================================
          // GRID PRODUCT
          // =====================================
          return GridView.builder(

            padding:
                const EdgeInsets.all(16),

            itemCount: products.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount: 2,

              crossAxisSpacing: 14,
              mainAxisSpacing: 14,

              childAspectRatio: 0.67,
            ),

            itemBuilder: (context, index) {

              final data =
                  products[index];

              // =====================================
              // SAFE DATA (via Map agar field baru
              // tidak throw Bad State error)
              // =====================================
              final dataMap = data.data()
                  as Map<String, dynamic>;

              final image =
                  dataMap['image'] ?? '';

              final title =
                  dataMap['name'] ?? '';

              final price =
                  dataMap['price'] ?? '';

              final description =
                  dataMap['description'] ?? '';

              final size =
                  dataMap['size'] ?? '';

              final productCategory =
                  dataMap['category'] ?? '';

              // =====================================
              // SOLD OUT
              // =====================================
              final soldOut =
                  dataMap['soldOut'] ?? false;

              return GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          DetailPage(

                        image: image,

                        title: title,

                        price: price,

                        description:
                            description,

                        category:
                            productCategory,

                        size: size,

                        soldOut: soldOut,
                      ),
                    ),
                  );
                },

                child: Container(

                  padding:
                      const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color: AppColors.card,

                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black
                            .withValues(alpha: 0.04),

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

                      // =====================================
                      // IMAGE
                      // =====================================
                      Expanded(

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

                                    width: double.infinity,

                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // =====================================
                            // SOLD OUT BADGE
                            // =====================================
                            if (soldOut)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors.red,
                                    borderRadius:
                                        BorderRadius.circular(
                                      7,
                                    ),
                                  ),
                                  child: const Text(
                                    "SOLD OUT",
                                    style: TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight.bold,
                                      letterSpacing:
                                          0.4,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // =====================================
                      // TITLE
                      // =====================================
                      Text(

                        title,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(

                          fontSize: 14,

                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // =====================================
                      // SIZE
                      // =====================================
                      Text(

                        size.isEmpty
                            ? "One Size Fits All"
                            : size,

                        style: TextStyle(

                          fontSize: 12,

                          color:
                              Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // =====================================
                      // PRICE
                      // =====================================
                      Text(

                        price,

                        style: const TextStyle(

                          fontSize: 15,

                          fontWeight:
                              FontWeight.bold,

                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}