// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saptohadi/core/constants/api_config.dart';
import 'package:saptohadi/features/products/show.dart';
import 'package:saptohadi/features/products/store.dart';
import 'package:saptohadi/features/products/update.dart';
import 'package:saptohadi/widgets/filter_widget.dart';
import 'package:saptohadi/widgets/menu_widget.dart';
import 'package:saptohadi/widgets/refresh_widget.dart';

class HalamanProduk extends StatefulWidget {
  const HalamanProduk({super.key});

  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  List _listdata = [];
  List _filteredData = [];
  bool _loading = true;

  final TextEditingController _filterController = TextEditingController();

  Future<void> _fetch() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}products/read.php'));
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

  Future<bool> _delete(String id) async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}products/delete.php'),
        body: {"id": id},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
      return false;
    } finally {
      setState(() {
        _loading = false;
      });
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
            Text('Halaman Produk'),
          ],
        ),
        backgroundColor: Colors.orange.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahProduk()),
              ).then((_) {
                _fetch(); // refresh data setelah berhasil input data
              });
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
                    ? const Center(child: Text('No products available'))
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
                                        builder: (context) => DetailProduk(
                                          listdata: {
                                            'id': product['id'] ?? '-',
                                            'name': product['name'] ?? '-',
                                            'price': product['price'] ?? '-',
                                            'nmKategori':
                                                product['nm_kategori'] ?? '-',
                                            'image_urls':
                                                product['image_urls'] ?? '-',
                                            'updated_at':
                                                product['updated_at'] ?? '-',
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: ListTile(
                                  leading:
                                      product['image_urls']?.isNotEmpty == true
                                          ? Image.network(
                                              product['image_urls'],
                                              height: 40,
                                              width: 70,
                                            )
                                          : Icon(
                                              Icons.nearby_error_sharp,
                                              size: 40,
                                              color: Colors.blueGrey
                                                  .withValues(alpha: 0.3),
                                            ),
                                  title: Text(product['name'] ?? '-'),
                                  subtitle: Text(
                                    product['price'] != null
                                        ? NumberFormat.currency(
                                                locale: 'id_ID',
                                                symbol: 'Rp ',
                                                decimalDigits: 0)
                                            .format(double.parse(
                                                product['price'].toString()))
                                        : 'NaN',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product['id'] != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange
                                                .withValues(alpha: 0.7),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.2),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(
                                            product['id'] ?? '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
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
                                                      'price': product['price'],
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
