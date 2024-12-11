// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/config/api_config.dart';
import 'package:myapp/detail_produk.dart';
import 'package:myapp/edit_produk.dart';
import 'package:myapp/tambah_produk.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _fetch() async {
    try {
      final respon = await http.get(Uri.parse('${ApiConfig.baseUrl}read.php'));
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        setState(() {
          _listdata = data['data'] ?? [];
          _filteredData = _listdata;
          _loading = false;
        });
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
      final respon = await http.post(
          Uri.parse('${ApiConfig.baseUrl}delete.php'),
          body: {
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            SizedBox(width: 10),
            Text('Halaman Produk'),
          ],
        ),
        backgroundColor: Colors.orange.withOpacity(0.7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetch();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                hintText: 'Cari ..',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
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
                                          'last_update':
                                              product['last_update'] ?? '-',
                                          'image_urls':
                                              product['image_urls'] ?? '-',
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: ListTile(
                                leading: product['image_urls']?.isNotEmpty ==
                                        true
                                    ? Image.network(
                                        product['image_urls'],
                                        height: 40,
                                        width: 70,
                                      )
                                    : Icon(
                                        Icons.nearby_error_sharp,
                                        size: 40,
                                        color: Colors.blueGrey.withOpacity(0.3),
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
                                          color: Colors.orange.withOpacity(0.7),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
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
                                          style: TextStyle(
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

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Data ${product['name']}(code:${product['id']}) berhasil dihapus!'),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                        }).catchError((error) {
                                                          Navigator.pop(
                                                              context);

                                                          ScaffoldMessenger.of(
                                                                  context)
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
                                                        backgroundColor: Colors
                                                            .orange
                                                            .withOpacity(0.7),
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
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(),
                                                      child: const Text(
                                                        'Batal',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange),
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
                                                    color: Colors.blueGrey),
                                                SizedBox(width: 8),
                                                Text('Hapus'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 0,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.orange.withOpacity(0.7),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahProduk()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.7),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 10,
                    top: 10,
                    child: Text(
                      'Ahadizapto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Product'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HalamanProduk()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('Other Page'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
