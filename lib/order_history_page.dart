import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {

  const OrderHistoryPage({super.key});

  // =====================================
  // FORMAT RUPIAH
  // =====================================
  String formatRupiah(int number) {

    return number.toString().replaceAllMapped(

      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),

      (Match match) => '${match[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

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

      appBar: AppBar(

        backgroundColor:
            Colors.brown,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "Riwayat Pesanan",

          style: TextStyle(

            color: AppColors.card,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection('orders')

                // =====================================
                // FILTER USER LOGIN
                // =====================================
                .where(
                  'userId',
                  isEqualTo: user.uid,
                )

                // =====================================
                // URUTKAN TERBARU
                // =====================================
                .orderBy(
                  'paidAt',
                  descending: true,
                )

                .snapshots(),

        builder: (context, snapshot) {

          // =====================================
          // LOADING
          // =====================================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
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

                    Icons.history,

                    size: 80,

                    color:
                        Colors.grey[400],
                  ),

                  const SizedBox(
                      height: 16),

                  Text(

                    "Belum ada riwayat pesanan",

                    style: TextStyle(

                      fontSize: 17,

                      color:
                          Colors.grey[600],

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders =
              snapshot.data!.docs;

          return ListView.builder(

            padding:
                const EdgeInsets.all(16),

            itemCount:
                orders.length,

            itemBuilder:
                (context, index) {

              final order =
                  orders[index];

              final data =
                  order.data()
                      as Map<String, dynamic>;

              final items =
                  List<Map<String, dynamic>>
                      .from(
                data['items'] ?? [],
              );

              final total =
                  data['total'] ?? 0;

              final status =
                  data['status'] ??
                      'paid';

              final paidAt =
                  data['paidAt'];

              // =====================================
              // NEW DATA
              // =====================================
              final receiverName =
                  data['receiverName'] ??
                      '-';

              final phoneNumber =
                  data['phoneNumber'] ??
                      '-';

              final address =
                  data['address'] ??
                      '-';

              return Container(

                margin:
                    const EdgeInsets.only(
                  bottom: 18,
                ),

                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration: BoxDecoration(

                  color: AppColors.card,

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  boxShadow: [

                    BoxShadow(

                      color: Colors.black
                          .withValues(
                              alpha: 0.04),

                      blurRadius: 10,

                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    // =====================================
                    // STATUS
                    // =====================================
                    Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(

                        color:
                            status == "paid"

                                ? Colors.green
                                    .withValues(
                                        alpha: 0.12)

                                : status ==
                                        "diproses"

                                    ? Colors.orange
                                        .withValues(
                                            alpha: 0.12)

                                    : status ==
                                            "dikirim"

                                        ? Colors.blue
                                            .withValues(
                                                alpha: 0.12)

                                        : Colors
                                            .purple
                                            .withValues(
                                                alpha: 0.12),

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Text(

                        status.toUpperCase(),

                        style: TextStyle(

                          color:
                              status == "paid"

                                  ? Colors.green

                                  : status ==
                                          "diproses"

                                      ? Colors.orange

                                      : status ==
                                              "dikirim"

                                          ? Colors.blue

                                          : Colors
                                              .purple,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    // =====================================
                    // RECEIVER
                    // =====================================
                    infoTile(
                      icon: Icons.person,
                      title:
                          "Nama Penerima",
                      value:
                          receiverName,
                    ),

                    const SizedBox(
                        height: 12),

                    // =====================================
                    // PHONE
                    // =====================================
                    infoTile(
                      icon: Icons.phone,
                      title: "Nomor HP",
                      value:
                          phoneNumber,
                    ),

                    const SizedBox(
                        height: 12),

                    // =====================================
                    // ADDRESS
                    // =====================================
                    infoTile(
                      icon:
                          Icons.location_on,
                      title: "Alamat",
                      value: address,
                    ),

                    const SizedBox(
                        height: 20),

                    // =====================================
                    // ITEM TITLE
                    // =====================================
                    const Text(

                      "Produk",

                      style: TextStyle(

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                        height: 14),

                    // =====================================
                    // ITEMS
                    // =====================================
                    Column(

                      children:
                          items.map((item) {

                        return Container(

                          margin:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),

                          child: Row(

                            children: [

                              // =====================================
                              // IMAGE
                              // =====================================
                              ClipRRect(

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),

                                child: Image.asset(

                                  item['image'] ??
                                      '',

                                  width: 70,
                                  height: 70,

                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {

                                    return Container(

                                      width: 70,
                                      height: 70,

                                      color: Colors
                                          .grey[300],

                                      child:
                                          const Icon(
                                        Icons.image,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                  width: 14),

                              // =====================================
                              // INFO
                              // =====================================
                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      item['name'] ??
                                          '',

                                      maxLines: 2,

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize:
                                            14,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                            6),

                                    Text(

                                      item['price'] ??
                                          '',

                                      style:
                                          const TextStyle(

                                        color: Colors
                                            .brown,

                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // =====================================
                    // TOTAL
                    // =====================================
                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(

                          "Total Pembayaran",

                          style: TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 15,
                          ),
                        ),

                        Text(

                          "Rp ${formatRupiah(total)}",

                          style:
                              const TextStyle(

                            color:
                                Colors.brown,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 12),

                    // =====================================
                    // DATE
                    // =====================================
                    Row(

                      children: [

                        Icon(

                          Icons.access_time,

                          size: 16,

                          color:
                              Colors.grey[600],
                        ),

                        const SizedBox(
                            width: 6),

                        Text(

                          paidAt != null

                              ? paidAt
                                  .toDate()
                                  .toString()

                              : '-',

                          style: TextStyle(

                            color:
                                Colors.grey[600],

                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =====================================
  // INFO TILE
  // =====================================
  Widget infoTile({

    required IconData icon,
    required String title,
    required String value,

  }) {

    return Container(

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color:
            const Color(0xFFF7F7F7),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(

            icon,

            color: Colors.brown,

            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    fontSize: 12,

                    color:
                        Colors.grey[600],
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(

                  value,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}