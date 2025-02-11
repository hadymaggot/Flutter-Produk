import 'dart:io';
import 'package:universal_io/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
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

  Null get kDebugMode => null;

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
      // ignore: use_build_context_synchronously
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
      // ignore: use_build_context_synchronously
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
      try {
        _filterList(_filterController.text);
      } catch (e) {
        // Tangani kesalahan di sini
        // ignore: avoid_print
        print("Error filtering list: $e");
      }
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> generateReport() async {
    try {
      // Buat dokumen PDF
      final pdf = pw.Document();

      // Ambil tanggal saat ini
      String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Tambahkan halaman ke PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(children: [
              pw.Text('Laporan Produk', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ['ID', 'Name', 'Price', 'Category'],
                data: _filteredData.map((product) {
                  return [
                    product['id'],
                    product['name'],
                    NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(double.parse(product['price'].toString())),
                    product['nm_kategori'],
                  ];
                }).toList(),
              ),
              // Menambahkan spasi agar tanggal berada di bawah
              pw.Spacer(),
              // Menambahkan tanggal cetak di kanan bawah
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text('Tanggal Cetak: $formattedDate',
                    style: pw.TextStyle(fontSize: 12)),
              ),
            ]);
          },
        ),
      );

      // Menyimpan PDF
      if (kIsWeb) {
        // Untuk web, kita bisa menggunakan Blob
        final bytes = await pdf.save();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        // ignore: unused_local_variable
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'products_report.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Untuk mobile dan desktop
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/products_report.pdf";
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        // ignore: avoid_print
        print('PDF berhasil disimpan di $path');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
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
        // ignore: deprecated_member_use
        backgroundColor: Colors.orange.withOpacity(0.7),
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
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              generateReport(); // Panggil fungsi untuk menghasilkan laporan PDF
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
                                            'idKategori':
                                                product['id_kategori'] ?? '-',
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
                                          color:
                                              // ignore: deprecated_member_use
                                              Colors.blueGrey.withOpacity(0.3),
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
                                            color:
                                                // ignore: deprecated_member_use
                                                Colors.orange.withOpacity(0.7),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    // ignore: deprecated_member_use
                                                    .withOpacity(0.2),
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
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            product['nm_kategori'] ?? '-',
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
                                                      'idKategori': product[
                                                          'id_kategori'],
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
                                                                // ignore: use_build_context_synchronously
                                                                context);
                                                            setState(() {
                                                              _fetch();
                                                            });

                                                            ScaffoldMessenger
                                                                    // ignore: use_build_context_synchronously
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
                                                                // ignore: use_build_context_synchronously
                                                                context);

                                                            ScaffoldMessenger
                                                                    // ignore: use_build_context_synchronously
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
                                                          backgroundColor: Colors
                                                              .orange
                                                              // ignore: deprecated_member_use
                                                              // ignore: deprecated_member_use
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
