import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesRecapPage extends StatefulWidget {
  const SalesRecapPage({super.key});

  @override
  State<SalesRecapPage> createState() => _SalesRecapPageState();
}

class _SalesRecapPageState extends State<SalesRecapPage> {
  // =====================================
  // FILTER STATUS
  // =====================================
  String _selectedStatus = 'semua';

  final List<Map<String, String>> _statusOptions = [
    {'value': 'semua', 'label': 'Semua'},
    {'value': 'paid', 'label': 'Paid'},
    {'value': 'diproses', 'label': 'Diproses'},
    {'value': 'dikirim', 'label': 'Dikirim'},
    {'value': 'selesai', 'label': 'Selesai'},
  ];

  // =====================================
  // FORMAT RUPIAH
  // =====================================
  String formatRupiah(num number) {
    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }

  // =====================================
  // WARNA & LABEL STATUS
  // =====================================
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'dikirim':
        return Colors.purple;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rekap Penjualan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('paidAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          // =====================================
          // LOADING
          // =====================================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          // =====================================
          // ERROR
          // =====================================
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final allOrders = snapshot.data?.docs ?? [];

          // =====================================
          // FILTER BERDASARKAN STATUS
          // =====================================
          final filteredOrders = _selectedStatus == 'semua'
              ? allOrders
              : allOrders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] ?? '') == _selectedStatus;
                }).toList();

          // =====================================
          // HITUNG TOTAL PENDAPATAN & TRANSAKSI
          // =====================================
          int totalPendapatan = 0;
          int totalProdukTerjual = 0;

          for (final doc in filteredOrders) {
            final data = doc.data() as Map<String, dynamic>;
            totalPendapatan += (data['total'] ?? 0) as int;
            final items = data['items'] as List? ?? [];
            totalProdukTerjual += items.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =====================================
                // FILTER STATUS
                // =====================================
                _buildFilterBar(),

                const SizedBox(height: 20),

                // =====================================
                // KARTU PENDAPATAN (FULL WIDTH)
                // =====================================
                _summaryCardWide(
                  icon: Icons.attach_money,
                  label: 'Total Pendapatan',
                  value: 'Rp ${formatRupiah(totalPendapatan)}',
                  color: Colors.green,
                ),

                const SizedBox(height: 12),

                // =====================================
                // 2 KARTU BAWAH (SAMA LEBAR)
                // =====================================
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.receipt_long,
                          label: 'Total Transaksi',
                          value: '${filteredOrders.length} Order',
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Produk Terjual',
                          value: '$totalProdukTerjual Item',
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // =====================================
                // JUDUL DAFTAR TRANSAKSI
                // =====================================
                Row(
                  children: [
                    const Text(
                      'Daftar Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (filteredOrders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          '${filteredOrders.length} transaksi',
                          style: const TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // =====================================
                // KOSONG
                // =====================================
                if (filteredOrders.isEmpty)
                  _emptyState()

                // =====================================
                // DAFTAR TRANSAKSI
                // =====================================
                else
                  ...filteredOrders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _transaksiCard(data);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================
  // FILTER BAR
  // =====================================
  Widget _buildFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final opt = _statusOptions[index];
          final isSelected = _selectedStatus == opt['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = opt['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown : Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                opt['label']!,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =====================================
  // SUMMARY CARD (KECIL — 2 KOLOM)
  // =====================================
  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // SUMMARY CARD WIDE (FULL WIDTH)
  // =====================================
  Widget _summaryCardWide({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================
  // TRANSAKSI CARD
  // =====================================
  Widget _transaksiCard(Map<String, dynamic> data) {
    final status = data['status']?.toString() ?? 'paid';
    final receiverName = data['receiverName']?.toString() ?? '-';
    final address = data['address']?.toString() ?? '-';
    final phoneNumber = data['phoneNumber']?.toString() ?? '-';
    final total = (data['total'] ?? 0) as int;
    final items = data['items'] as List? ?? [];

    // Ambil tanggal dari paidAt
    String tanggal = '-';
    if (data['paidAt'] != null) {
      try {
        final ts = data['paidAt'] as dynamic;
        final dt = ts.toDate() as DateTime;
        tanggal =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          // =====================================
          // HEADER: NAMA + STATUS + TANGGAL
          // =====================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [

                // Avatar inisial
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Colors.brown.withValues(alpha: 0.12),
                  child: Text(
                    receiverName.isNotEmpty
                        ? receiverName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tanggal,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(status)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusLabel(status),
                    style: TextStyle(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =====================================
          // DIVIDER
          // =====================================
          Divider(
            height: 1,
            color: Colors.grey.shade100,
          ),

          // =====================================
          // DETAIL PRODUK YANG DIBELI
          // =====================================
          ...items.map((item) {
            final itemMap = item as Map<String, dynamic>;
            final name = itemMap['name']?.toString() ?? '-';
            final price = itemMap['price']?.toString() ?? '-';
            final category = itemMap['category']?.toString() ?? '-';
            final image = itemMap['image']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [

                  // Gambar produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // =====================================
          // DIVIDER
          // =====================================
          Divider(
            height: 1,
            color: Colors.grey.shade100,
          ),

          // =====================================
          // FOOTER: INFO PENGIRIMAN + TOTAL
          // =====================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Info pengiriman
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Total harga
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${formatRupiah(total)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // EMPTY STATE
  // =====================================
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data akan muncul setelah ada pembelian',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
