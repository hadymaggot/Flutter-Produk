import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailProduk extends StatefulWidget {
  final Map listdata;
  const DetailProduk({Key? key, required this.listdata});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final formKey = GlobalKey<FormState>();
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController nmKategori = TextEditingController();

  String formatPrice(String value) {
    double priceValue = double.tryParse(value) ?? 0;
    if (priceValue == priceValue.toInt()) {
      return NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(priceValue);
    } else {
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
          .format(priceValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    id.text = widget.listdata['id'];
    name.text = widget.listdata['name'];
    price.text = formatPrice(widget.listdata['price']);
    nmKategori.text = widget.listdata['nmKategori'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        title: const Text('Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Card(
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: widget.listdata['id'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'ID Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: widget.listdata['name'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: price.text,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Harga Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: nmKategori.text,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: widget.listdata['updated_at'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Update',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(6.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.network(
                    widget.listdata['image_urls'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.nearby_error_sharp,
                              color: Colors.blueGrey.withValues(alpha: 0.3),
                              size: 50.0,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.blueGrey.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
