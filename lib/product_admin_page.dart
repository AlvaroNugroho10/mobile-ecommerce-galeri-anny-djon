import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAdminPage extends StatefulWidget {
  const ProductAdminPage({super.key});

  @override
  State<ProductAdminPage> createState() =>
      _ProductAdminPageState();
}

class _ProductAdminPageState
    extends State<ProductAdminPage> {

  final nameController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final imageController =
      TextEditingController();

  final sizeController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  String selectedCategory = "Lukisan";

  bool isLoading = false;

  // =====================================
  // ADD PRODUCT
  // =====================================
  Future<void> addProduct() async {

    if (
      nameController.text.isEmpty ||
      priceController.text.isEmpty ||
      imageController.text.isEmpty ||
      descriptionController.text.isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Semua field wajib diisi",
          ),
        ),
      );

      return;
    }

    // =====================================
    // SIZE LOGIC
    // =====================================
    String finalSize = "";

    if (
      selectedCategory == "Lukisan" ||
      selectedCategory == "Tas"
    ) {

      if (sizeController.text.isEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Ukuran wajib diisi",
            ),
          ),
        );

        return;
      }

      finalSize =
          sizeController.text.trim();

    } else {

      finalSize = "One Size Fits All";
    }

    setState(() {
      isLoading = true;
    });

    try {

      await FirebaseFirestore.instance
          .collection("products")
          .add({

        "name":
            nameController.text.trim(),

        "name_lower":
            nameController.text
                .trim()
                .toLowerCase(),

        "price":
            priceController.text.trim(),

        "image":
            imageController.text.trim(),

        "category":
            selectedCategory,

        "size":
            finalSize,

        "description":
            descriptionController.text.trim(),

        "createdAt":
            FieldValue.serverTimestamp(),
      });

      // CLEAR
      nameController.clear();
      priceController.clear();
      imageController.clear();
      sizeController.clear();
      descriptionController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Produk berhasil ditambahkan",
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {

    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    sizeController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(

        backgroundColor: Colors.brown,

        title: const Text(

          "Kelola Produk",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =====================================
            // FORM
            // =====================================
            Container(

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(24),

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

                children: [

                  buildTextField(
                    controller: nameController,
                    hint: "Nama Produk",
                    icon: Icons.shopping_bag,
                  ),

                  const SizedBox(height: 14),

                  buildTextField(
                    controller: priceController,
                    hint: "Harga",
                    icon: Icons.payments,
                  ),

                  const SizedBox(height: 14),

                  buildTextField(
                    controller: imageController,
                    hint: "Path Gambar",
                    icon: Icons.image,
                  ),

                  const SizedBox(height: 14),

                  // =====================================
                  // CATEGORY DROPDOWN
                  // =====================================
                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),

                    decoration: BoxDecoration(

                      color:
                          const Color(0xFFF7F7F7),

                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: DropdownButtonHideUnderline(

                      child: DropdownButton<String>(

                        value: selectedCategory,

                        isExpanded: true,

                        items: const [

                          DropdownMenuItem(
                            value: "Lukisan",
                            child: Text("Lukisan"),
                          ),

                          DropdownMenuItem(
                            value: "Tas",
                            child: Text("Tas"),
                          ),

                          DropdownMenuItem(
                            value: "Baju",
                            child: Text("Baju"),
                          ),
                        ],

                        onChanged: (value) {

                          setState(() {

                            selectedCategory =
                                value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =====================================
                  // SIZE FIELD
                  // =====================================
                  if (
                    selectedCategory ==
                        "Lukisan" ||

                    selectedCategory ==
                        "Tas"
                  )

                    buildTextField(

                      controller:
                          sizeController,

                      hint:
                          "Ukuran (contoh 40x50 cm)",

                      icon:
                          Icons.straighten,
                    ),

                  if (
                    selectedCategory ==
                        "Lukisan" ||

                    selectedCategory ==
                        "Tas"
                  )

                    const SizedBox(height: 14),

                  // =====================================
                  // DESCRIPTION
                  // =====================================
                  TextField(

                    controller:
                        descriptionController,

                    maxLines: 4,

                    decoration: InputDecoration(

                      hintText:
                          "Deskripsi Produk",

                      filled: true,

                      fillColor:
                          const Color(0xFFF7F7F7),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(16),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =====================================
                  // BUTTON
                  // =====================================
                  SizedBox(

                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(

                      onPressed:
                          isLoading
                              ? null
                              : addProduct,

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.brown,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),

                      child: isLoading

                          ? const SizedBox(

                              height: 22,
                              width: 22,

                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )

                          : const Text(

                              "Tambah Produk",

                              style: TextStyle(

                                color: Colors.white,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(

              "Daftar Produk",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // =====================================
            // PRODUCT LIST
            // =====================================
            StreamBuilder<QuerySnapshot>(

              stream:
                  FirebaseFirestore.instance
                      .collection("products")
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

                return ListView.builder(

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      products.length,

                  itemBuilder:
                      (context, index) {

                    final product =
                        products[index];

                    // Akses aman via Map agar field
                    // soldOut yang belum ada di dokumen
                    // lama tidak throw Bad State error
                    final productMap = product.data()
                        as Map<String, dynamic>;

                    return Container(

                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding:
                          const EdgeInsets.all(14),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(22),

                        boxShadow: [

                          BoxShadow(

                            color: Colors.black
                                .withValues(alpha: 0.03),

                            blurRadius: 8,

                            offset:
                                const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(

                        children: [

                          // IMAGE
                          ClipRRect(

                            borderRadius:
                                BorderRadius.circular(14),

                            child: Image.asset(

                              product['image'] ?? '',

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

                                  color:
                                      Colors.grey[300],

                                  child: const Icon(
                                    Icons.image,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 14),

                          // INFO
                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(

                                  product['name'] ?? '',

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow.ellipsis,

                                  style:
                                      const TextStyle(

                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  product['price'] ?? '',
                                ),

                                const SizedBox(height: 4),

                                Text(

                                  product['category'] ?? '',

                                  style: TextStyle(

                                    color:
                                        Colors.grey[600],

                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(

                                  product['size'] ?? '',

                                  style: const TextStyle(

                                    color: Colors.brown,

                                    fontSize: 12,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // =============================
                                // SOLD OUT BADGE
                                // =============================
                                if (productMap['soldOut'] == true)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(
                                        6,
                                      ),
                                    ),
                                    child: const Text(
                                      "SOLD OUT",
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // ACTION
                          Column(

                            children: [

                              IconButton(

                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),

                                onPressed: () {

                                  showEditDialog(
                                    product,
                                  );
                                },
                              ),

                              IconButton(

                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () async {

                                  await FirebaseFirestore
                                      .instance
                                      .collection("products")
                                      .doc(product.id)
                                      .delete();
                                },
                              ),

                              // =============================
                              // AKTIFKAN KEMBALI
                              // =============================
                              if (productMap['soldOut'] == true)
                                IconButton(

                                  tooltip:
                                      "Aktifkan Kembali",

                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.green,
                                  ),

                                  onPressed:
                                      () async {

                                    await FirebaseFirestore
                                        .instance
                                        .collection(
                                            "products")
                                        .doc(product.id)
                                        .update({
                                      'soldOut':
                                          false,
                                    });

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(

                                      const SnackBar(
                                        content: Text(
                                          "Produk diaktifkan kembali",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // EDIT DIALOG
  // =====================================
  void showEditDialog(
    QueryDocumentSnapshot product,
  ) {

    final editName =
        TextEditingController(
      text: product['name'],
    );

    final editPrice =
        TextEditingController(
      text: product['price'],
    );

    final editImage =
        TextEditingController(
      text: product['image'],
    );

    final editDescription =
        TextEditingController(
      text: product['description'],
    );

    final editSize =
        TextEditingController(
      text: product['size'],
    );

    String editCategory =
        product['category'];

    showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setModalState) {

            return AlertDialog(

              title:
                  const Text("Edit Produk"),

              content:
                  SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    TextField(
                      controller: editName,
                      decoration:
                          const InputDecoration(
                        labelText: "Nama",
                      ),
                    ),

                    TextField(
                      controller: editPrice,
                      decoration:
                          const InputDecoration(
                        labelText: "Harga",
                      ),
                    ),

                    TextField(
                      controller: editImage,
                      decoration:
                          const InputDecoration(
                        labelText: "Image",
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(

                      value: editCategory,

                      isExpanded: true,

                      items: const [

                        DropdownMenuItem(
                          value: "Lukisan",
                          child: Text("Lukisan"),
                        ),

                        DropdownMenuItem(
                          value: "Tas",
                          child: Text("Tas"),
                        ),

                        DropdownMenuItem(
                          value: "Baju",
                          child: Text("Baju"),
                        ),
                      ],

                      onChanged: (value) {

                        setModalState(() {

                          editCategory =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    if (
                      editCategory ==
                          "Lukisan" ||

                      editCategory ==
                          "Tas"
                    )

                      TextField(

                        controller:
                            editSize,

                        decoration:
                            const InputDecoration(
                          labelText:
                              "Ukuran",
                        ),
                      ),

                    TextField(

                      controller:
                          editDescription,

                      maxLines: 3,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Deskripsi",
                      ),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Batal",
                  ),
                ),

                ElevatedButton(

                  onPressed: () async {

                    String finalSize = "";

                    if (
                      editCategory ==
                          "Lukisan" ||

                      editCategory ==
                          "Tas"
                    ) {

                      finalSize =
                          editSize.text.trim();

                    } else {

                      finalSize =
                          "One Size Fits All";
                    }

                    await FirebaseFirestore
                        .instance
                        .collection("products")
                        .doc(product.id)
                        .update({

                      "name":
                          editName.text.trim(),

                      "name_lower":
                          editName.text
                              .trim()
                              .toLowerCase(),

                      "price":
                          editPrice.text.trim(),

                      "image":
                          editImage.text.trim(),

                      "category":
                          editCategory,

                      "size":
                          finalSize,

                      "description":
                          editDescription.text.trim(),
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Simpan",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================
  // TEXT FIELD
  // =====================================
  Widget buildTextField({

    required TextEditingController controller,
    required String hint,
    required IconData icon,

  }) {

    return TextField(

      controller: controller,

      decoration: InputDecoration(

        hintText: hint,

        prefixIcon: Icon(icon),

        filled: true,

        fillColor:
            const Color(0xFFF7F7F7),

        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}