import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAdminPage extends StatelessWidget {
  const UserAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.brown,

        title: const Text(
          "Manajemen User",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),

        builder: (context, snapshot) {

          // ============================
          // LOADING
          // ============================
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ============================
          // EMPTY
          // ============================
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text("Belum ada user"),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: users.length,

            itemBuilder: (context, index) {

              final user = users[index];

              // ============================
              // SAFE DATA
              // ============================
              final data =
                  user.data()
                      as Map<String, dynamic>;

              final email =
                  data.containsKey('email')
                      ? data['email']
                      : 'No Email';

              final role =
                  data.containsKey('role')
                      ? data['role']
                      : 'user';

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 14,
                ),

                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.05),

                      blurRadius: 10,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ============================
                    // USER INFO
                    // ============================
                    Row(
                      children: [

                        CircleAvatar(
                          radius: 24,

                          backgroundColor:
                              Colors.brown
                                  .withValues(alpha: 0.15),

                          child: const Icon(
                            Icons.person,
                            color: Colors.brown,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                email,

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(
                                  height: 6),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color: role ==
                                          'admin'
                                      ? Colors.green
                                          .withValues(
                                              alpha: 0.15)
                                      : Colors.blue
                                          .withValues(
                                              alpha: 0.15),

                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                ),

                                child: Text(
                                  role
                                      .toString()
                                      .toUpperCase(),

                                  style: TextStyle(

                                    color: role ==
                                            'admin'
                                        ? Colors.green
                                        : Colors.blue,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ============================
                    // BUTTONS
                    // ============================
                    Row(
                      children: [

                        // ============================
                        // CHANGE ROLE
                        // ============================
                        Expanded(
                          child: ElevatedButton.icon(

                            onPressed: () async {

                              final newRole =
                                  role == 'admin'
                                      ? 'user'
                                      : 'admin';

                              await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(user.id)
                                  .set({

                                'role': newRole,

                              }, SetOptions(
                                merge: true,
                              ));

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                SnackBar(
                                  content: Text(
                                    "Role diubah menjadi $newRole",
                                  ),
                                ),
                              );
                            },

                            style:
                                ElevatedButton.styleFrom(

                              backgroundColor:
                                  Colors.orange,

                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),

                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                            ),

                            icon: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),

                            label: const Text(
                              "Ubah Role",

                              style: TextStyle(
                                color: Colors.white,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // ============================
                        // DELETE USER
                        // ============================
                        Expanded(
                          child: ElevatedButton.icon(

                            onPressed: () async {

                              final confirm =
                                  await showDialog(

                                context: context,

                                builder: (_) {

                                  return AlertDialog(

                                    title: const Text(
                                      "Hapus User",
                                    ),

                                    content: const Text(
                                      "Yakin ingin menghapus user ini?",
                                    ),

                                    actions: [

                                      TextButton(

                                        onPressed: () {

                                          Navigator.pop(
                                            context,
                                            false,
                                          );
                                        },

                                        child:
                                            const Text(
                                          "Batal",
                                        ),
                                      ),

                                      ElevatedButton(

                                        onPressed: () {

                                          Navigator.pop(
                                            context,
                                            true,
                                          );
                                        },

                                        style:
                                            ElevatedButton
                                                .styleFrom(

                                          backgroundColor:
                                              Colors.red,
                                        ),

                                        child:
                                            const Text(
                                          "Hapus",
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {

                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                        'users')
                                    .doc(user.id)
                                    .delete();

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(

                                  const SnackBar(
                                    content: Text(
                                      "User berhasil dihapus",
                                    ),
                                  ),
                                );
                              }
                            },

                            style:
                                ElevatedButton.styleFrom(

                              backgroundColor:
                                  Colors.red,

                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),

                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                            ),

                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),

                            label: const Text(
                              "Hapus",

                              style: TextStyle(
                                color: Colors.white,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
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
    );
  }
}