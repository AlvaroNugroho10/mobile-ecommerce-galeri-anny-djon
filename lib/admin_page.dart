import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'product_admin_page.dart';
import 'admin_order_page.dart';
import 'user_admin_page.dart';
import 'sales_recap_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(

        backgroundColor: Colors.brown,

        centerTitle: true,

        elevation: 0,

        title: const Text(

          "Admin Panel",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =================================
            // HEADER
            // =================================
            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.brown,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    "Welcome Admin 👋",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(

                    "Kelola produk, pesanan, dan user",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================
            // MENU GRID
            // =================================
            GridView.count(

              crossAxisCount: 2,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisSpacing: 15,
              mainAxisSpacing: 15,

              childAspectRatio: 1,

              children: [

                // =============================
                // PRODUK
                // =============================
                adminMenu(

                  icon: Icons.shopping_bag,

                  title: "Produk",

                  subtitle: "Kelola produk",

                  color: Colors.orange,

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const ProductAdminPage(),
                      ),
                    );
                  },
                ),

                // =============================
                // PESANAN
                // =============================
                adminMenu(

                  icon: Icons.receipt_long,

                  title: "Pesanan",

                  subtitle: "Lihat transaksi",

                  color: Colors.green,

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminOrderPage(),
                      ),
                    );
                  },
                ),

                // =============================
                // USER
                // =============================
                adminMenu(

                  icon: Icons.people,

                  title: "User",

                  subtitle: "Kelola user",

                  color: Colors.blue,

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const UserAdminPage(),
                      ),
                    );
                  },
                ),

                // =============================
                // REKAP PENJUALAN
                // =============================
                adminMenu(

                  icon: Icons.bar_chart,

                  title: "Rekap",

                  subtitle: "Penjualan produk",

                  color: Colors.purple,

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const SalesRecapPage(),
                      ),
                    );
                  },
                ),

                // =============================
                // LOGOUT
                // =============================
                adminMenu(

                  icon: Icons.logout,

                  title: "Logout",

                  subtitle: "Keluar akun",

                  color: Colors.red,

                  onTap: () async {

                    await FirebaseAuth.instance
                        .signOut();

                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginPage(),
                      ),

                      (route) => false,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(

              "Ringkasan",

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // =================================
            // TOTAL PRODUK
            // =================================
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("products")
                  .snapshots(),

              builder: (context, snapshot) {

                int total =
                    snapshot.data?.docs.length ?? 0;

                return infoCard(

                  title: "Total Produk",

                  value: total.toString(),

                  icon: Icons.shopping_cart,
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================
            // TOTAL ORDER
            // =================================
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("orders")
                  .snapshots(),

              builder: (context, snapshot) {

                int total =
                    snapshot.data?.docs.length ?? 0;

                return infoCard(

                  title: "Total Pesanan",

                  value: total.toString(),

                  icon: Icons.receipt_long,
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================
            // TOTAL USER
            // =================================
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),

              builder: (context, snapshot) {

                int total =
                    snapshot.data?.docs.length ?? 0;

                return infoCard(

                  title: "Total User",

                  value: total.toString(),

                  icon: Icons.people,
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================
            // TOTAL PENDAPATAN
            // =================================
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("orders")
                  .snapshots(),

              builder: (context, snapshot) {

                int totalPendapatan = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data()
                        as Map<String, dynamic>;
                    totalPendapatan +=
                        (data['total'] ?? 0) as int;
                  }
                }

                return infoCard(

                  title: "Total Pendapatan",

                  value:
                      "Rp ${totalPendapatan.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}",

                  icon: Icons.attach_money,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // MENU CARD
  // =====================================
  Widget adminMenu({

    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,

  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black.withValues(alpha: 0.05),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            CircleAvatar(

              radius: 24,

              backgroundColor:
                  color.withValues(alpha: 0.18),

              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),

            const Spacer(),

            Text(

              title,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            Text(

              subtitle,

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // INFO CARD
  // =====================================
  Widget infoCard({

    required String title,
    required String value,
    required IconData icon,

  }) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withValues(alpha: 0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 28,

            backgroundColor:
                Colors.brown.withValues(alpha: 0.15),

            child: Icon(
              icon,
              color: Colors.brown,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                Text(

                  value,

                  style: const TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,
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