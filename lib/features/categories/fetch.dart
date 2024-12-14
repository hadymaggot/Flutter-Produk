// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/constants/api_config.dart';
import 'package:myapp/features/categories/show.dart';
import 'package:myapp/features/products/store.dart';
import 'package:myapp/features/products/update.dart';
import 'package:myapp/widgets/filter_widget.dart';
import 'package:myapp/widgets/menu_widget.dart';
import 'package:myapp/widgets/refresh_widget.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List _listdata = [];
  List _filteredData = [];
  bool _loading = true;

  final TextEditingController _filterController = TextEditingController();

  Future<void> _fetch() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}categories/read.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listdata = data['data'] ?? [];
          _filteredData = _listdata;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  Future _delete(String id) async {
    try {
      final respon = await http
          .post(Uri.parse('${ApiConfig.baseUrl}categories/delete.php'), body: {
        "id": id,
      });
      if (respon.statusCode == 200) {
        return true;
      } else {
        setState(() {
          _loading = false;
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  void _filterList(String query) {
    setState(() {
      _filteredData = _listdata.where((product) {
        return product['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch();
    _filterController.addListener(() {
      _filterList(_filterController.text);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            SizedBox(width: 10),
            Text('Halaman Kategori'),
          ],
        ),
        // ignore: deprecated_member_use
        backgroundColor: Colors.orange.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahProduk(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PullToRefreshWidget(
        onRefresh: _fetch,
        child: Column(
          children: [
            FilterWidget(
              filterController: _filterController,
              onFilter: _filterList,
            ),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? const Center(child: Text('No category available'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _filteredData.length,
                          itemBuilder: (context, index) {
                            var product = _filteredData[index];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  if (product['id'] != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailKategori(
                                          listdata: {
                                            'id': product['id'] ?? '-',
                                            'name': product['name'] ?? '-',
                                            'updated_at':
                                                product['updated_at'] ?? '-',
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ListTile(
                                  leading: const Icon(Icons.category),
                                  title: Text(product['name'] ?? '-'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product['id'] != null) ...[
                                        const SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (String value) {
                                            if (value == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UbahProduk(
                                                    listdata: {
                                                      'id': product['id'],
                                                      'name': product['name'],
                                                    },
                                                  ),
                                                ),
                                              );
                                            } else if (value == 'delete') {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    content: Text(
                                                      'Yakin ingin menghapus produk ${product['name']}?',
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _delete(product['id'])
                                                              .then((value) {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {
                                                              _fetch();
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Data ${product['name']}(code:${product['id']}) berhasil dihapus!'),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          }).catchError(
                                                                  (error) {
                                                            Navigator.pop(
                                                                context);

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Gagal menghapus produk.'),
                                                                backgroundColor:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.orange
                                                                  .withValues(
                                                                      alpha:
                                                                          0.7),
                                                          foregroundColor:
                                                              Colors.white,
                                                          textStyle:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        child: const Text(
                                                            'Ya, Hapus Data.'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(),
                                                        child: const Text(
                                                          'Batal',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 8),
                                                  Text('Ubah'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Hapus'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      drawer: const HamburgerMenu(),
    );
  }
}
