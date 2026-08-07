import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>>? items;

  const CheckoutPage({
    super.key,
    this.items,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoadingPayment = false;

  String formatRupiah(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isBuyNow = widget.items != null;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User belum login"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // =========================
          // FORM INPUT
          // =========================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                customField(
                  controller: nameController,
                  hint: "Nama Penerima",
                  icon: Icons.person,
                ),
                const SizedBox(height: 14),
                customField(
                  controller: phoneController,
                  hint: "Nomor HP",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                customField(
                  controller: addressController,
                  hint: "Alamat Lengkap",
                  icon: Icons.location_on,
                  maxLines: 3,
                ),
              ],
            ),
          ),

          // =========================
          // ITEM LIST
          // =========================
          Expanded(
            child: isBuyNow
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.items!.length,
                    itemBuilder: (context, index) {
                      return checkoutItem(widget.items![index]);
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('carts')
                        .doc(user.uid)
                        .collection('items')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("Keranjang kosong"),
                        );
                      }

                      final cartItems = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final data = cartItems[index];
                          return checkoutItem(data);
                        },
                      );
                    },
                  ),
          ),

          // =========================
          // TOTAL & BUTTON ACTION
          // =========================
          StreamBuilder<QuerySnapshot>(
            stream: isBuyNow
                ? null
                : FirebaseFirestore.instance
                    .collection('carts')
                    .doc(user.uid)
                    .collection('items')
                    .snapshots(),
            builder: (context, snapshot) {
              int total = 0;
              List<Map<String, dynamic>> orderItems = [];

              if (isBuyNow) {
                for (var item in widget.items!) {
                  final price = int.tryParse(
                        item['price']
                            .toString()
                            .replaceAll(RegExp(r'[^0-9]'), ''),
                      ) ??
                      0;
                  total += price;
                  orderItems.add(item);
                }
              } else if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final price = int.tryParse(
                        data['price']
                            .toString()
                            .replaceAll(RegExp(r'[^0-9]'), ''),
                      ) ??
                      0;
                  total += price;
                  orderItems.add({
                    'name': data['name'] ?? '',
                    'price': data['price'] ?? '',
                    'image': data['image'] ?? '',
                    'description': data['description'] ?? '',
                    'category': data['category'] ?? '',
                    'size': data['size'] ?? '',
                  });
                }
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Harga"),
                        const SizedBox(height: 6),
                        Text(
                          "Rp ${formatRupiah(total)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: isLoadingPayment
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty ||
                                  phoneController.text.trim().isEmpty ||
                                  addressController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lengkapi data pengiriman"),
                                  ),
                                );
                                return;
                              }

                              try {
                                setState(() {
                                  isLoadingPayment = true;
                                });

                                final response = await http.post(
                                  Uri.parse("http://10.0.2.2:3000/token"),
                                  headers: {
                                    "Content-Type": "application/json",
                                  },
                                  body: jsonEncode({
                                    "total": total,
                                    "userId": user.uid,
                                    "email": user.email,
                                    "items": orderItems,
                                  }),
                                );

                                final data = jsonDecode(response.body);
                                final token = data['token'];

                                if (!mounted) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MidtransPaymentPage(
                                      token: token,
                                      orderItems: orderItems,
                                      total: total,
                                      receiverName: nameController.text.trim(),
                                      phoneNumber: phoneController.text.trim(),
                                      address: addressController.text.trim(),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isLoadingPayment = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      child: isLoadingPayment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Bayar Sekarang",
                              style: TextStyle(color: Colors.white),
                            ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget checkoutItem(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              data['image'] ?? '',
              width: 75,
              height: 75,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(data['price'] ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================
// MIDTRANS PAGE
// =====================================
class MidtransPaymentPage extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> orderItems;
  final int total;
  final String receiverName;
  final String phoneNumber;
  final String address;

  const MidtransPaymentPage({
    super.key,
    required this.token,
    required this.orderItems,
    required this.total,
    required this.receiverName,
    required this.phoneNumber,
    required this.address,
  });

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController controller;
  bool isLoading = true;
  bool _isRedirected = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            final html = await controller.runJavaScriptReturningResult(
              "document.body.innerText",
            );

            final content = html.toString().toLowerCase();
            debugPrint("PAGE CONTENT: $content");

            if (!_isRedirected && content.contains("transaction is successful")) {
              _isRedirected = true;

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessPage(
                    token: widget.token,
                    receiverName: widget.receiverName,
                    phoneNumber: widget.phoneNumber,
                    address: widget.address,
                    orderItems: widget.orderItems,
                    total: widget.total,
                  ),
                ),
              );
            }

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) async {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.token}",
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          "Pembayaran",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.brown)),
        ],
      ),
    );
  }
}

// ====================================================================
// SUCCESS PAGE (MENAMBAL DATA KOSONG DI FIRESTORE TANPA MERUBAH TAMPILAN)
// ====================================================================
class PaymentSuccessPage extends StatefulWidget {
  final String token;
  final String receiverName;
  final String phoneNumber;
  final String address;
  final List<Map<String, dynamic>> orderItems;
  final int total;

  const PaymentSuccessPage({
    super.key,
    required this.token,
    required this.receiverName,
    required this.phoneNumber,
    required this.address,
    required this.orderItems,
    required this.total,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isSaving = true;
  static String _lastProcessedToken = ""; 

  @override
  void initState() {
    super.initState();
    _patchOrderData();
  }

  Future<void> _patchOrderData() async {
    if (_lastProcessedToken == widget.token) {
      if (mounted) setState(() { _isSaving = false; });
      return;
    }
    _lastProcessedToken = widget.token;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // FIX UTAMA: Mencari dokumen pesanan asli buatan server di Firestore
      String targetDocId = widget.token; 

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Jika server mendaftarkan transaksi menggunakan Order ID kustom (bukan Token ID),
      // kita cari dokumen mana yang memiliki item yang sama atau field pengiriman yang masih kosong.
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (!data.containsKey('receiverName') || data['receiverName'] == null || data['receiverName'] == '') {
            targetDocId = doc.id; // Menemukan ID dokumen buatan server asli
            break;
          }
        }
      }

      // Gabungkan data inputan aplikasi ke dokumen pesanan tersebut
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(targetDocId)
          .set({
        'orderId': targetDocId,
        'userId': user.uid,
        'email': user.email,
        'receiverName': widget.receiverName,
        'phoneNumber': widget.phoneNumber,
        'address': widget.address,
        'items': widget.orderItems,
        'total': widget.total,
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Otomatis bersihkan keranjang belanja
      final cartItems = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      // =====================================
      // TANDAI PRODUK SEBAGAI SOLD OUT
      // =====================================
      for (final item in widget.orderItems) {
        final productName =
            item['name']?.toString() ?? '';
        if (productName.isEmpty) continue;

        final productQuery =
            await FirebaseFirestore.instance
                .collection('products')
                .where(
                  'name',
                  isEqualTo: productName,
                )
                .limit(1)
                .get();

        for (final productDoc
            in productQuery.docs) {
          await productDoc.reference
              .update({'soldOut': true});
        }
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 120,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Pembayaran Berhasil",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isSaving 
                      ? "Sedang sinkronisasi data pesanan..." 
                      : "Terima kasih telah melakukan pembelian.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                if (!_isSaving)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      child: const Text(
                        "Kembali ke Home",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(color: Colors.brown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}