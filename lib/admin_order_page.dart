import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderPage extends StatelessWidget {
  const AdminOrderPage({super.key});

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

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.brown,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "Manajemen Pesanan",

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection('orders')
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

                    Icons.inventory_2_outlined,

                    size: 80,

                    color: Colors.grey[400],
                  ),

                  const SizedBox(
                      height: 16),

                  Text(

                    "Belum ada pesanan",

                    style: TextStyle(

                      fontSize: 18,

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

              final data =
                  orders[index];

              final total =
                  data['total'] ?? 0;

              final status =
                  data['status'] ??
                      'paid';

              final items =
                  data['items'] as List;

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

                  color: Colors.white,

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
                    // EMAIL
                    // =====================================
                    Row(

                      children: [

                        const Icon(

                          Icons.email,

                          size: 18,

                          color:
                              Colors.brown,
                        ),

                        const SizedBox(
                            width: 8),

                        Expanded(

                          child: Text(

                            data['email'] ??
                                '-',

                            style:
                                const TextStyle(

                              fontWeight:
                                  FontWeight
                                      .bold,

                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
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
                        height: 18),

                    // =====================================
                    // TOTAL
                    // =====================================
                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(

                          "Total Harga",

                          style: TextStyle(

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        Text(

                          "Rp ${formatRupiah(total)}",

                          style:
                              const TextStyle(

                            color:
                                Colors.brown,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 10),

                    // =====================================
                    // ITEM COUNT
                    // =====================================
                    Row(

                      children: [

                        const Icon(

                          Icons.shopping_bag,

                          size: 18,

                          color:
                              Colors.grey,
                        ),

                        const SizedBox(
                            width: 8),

                        Text(
                          "${items.length} Item",
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 18),

                    // =====================================
                    // STATUS
                    // =====================================
                    Row(

                      children: [

                        const Text(

                          "Status",

                          style: TextStyle(

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            width: 14),

                        Expanded(

                          child:
                              DropdownButtonFormField(

                            initialValue: status,

                            decoration:
                                InputDecoration(

                              filled: true,

                              fillColor:
                                  Colors.grey[
                                      100],

                              contentPadding:
                                  const EdgeInsets.symmetric(

                                horizontal:
                                    14,

                                vertical:
                                    10,
                              ),

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),
                            ),

                            items: const [

                              DropdownMenuItem(
                                value: "paid",
                                child:
                                    Text("Paid"),
                              ),

                              DropdownMenuItem(
                                value:
                                    "diproses",
                                child: Text(
                                  "Diproses",
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                    "dikirim",
                                child: Text(
                                  "Dikirim",
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                    "selesai",
                                child: Text(
                                  "Selesai",
                                ),
                              ),
                            ],

                            onChanged:
                                (value) async {

                              await FirebaseFirestore
                                  .instance
                                  .collection(
                                      'orders')
                                  .doc(
                                      data.id)
                                  .update({

                                'status':
                                    value,
                              });

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    "Status berhasil diupdate",
                                  ),
                                ),
                              );
                            },
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