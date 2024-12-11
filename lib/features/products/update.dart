

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/core/constants/api_config.dart';
import 'package:myapp/features/products/fetch.dart';

class UbahProduk extends StatefulWidget {
  final Map listdata;
  const UbahProduk({super.key, required this.listdata});

  @override
  State<UbahProduk> createState() => _UbahProdukState();
}

class _UbahProdukState extends State<UbahProduk> {
  final formKey = GlobalKey<FormState>();
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();

  @override
  void initState() {
    super.initState();
    id.text = widget.listdata['id'];
    name.text = widget.listdata['name'];
    price.text =
        _formatPrice(double.parse(widget.listdata['price'].toString()));
  }

  
  String _formatPrice(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  
  TextInputFormatter _currencyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (newText.isEmpty) {
        return TextEditingValue(text: '');
      }

      final number = int.tryParse(newText);
      if (number != null) {
        final formattedText = _formatPrice(number.toDouble());

        return TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }

      return newValue;
    });
  }

  
  Future<bool> _simpanData() async {
    final priceValue =
        price.text.replaceAll(RegExp(r'[^0-9]'), ''); 

    final respon = await http.post(
      Uri.parse('${ApiConfig.baseUrl}update.php'),
      body: {
        'id': id.text,
        'name': name.text,
        'price': priceValue,
      },
    );

    return respon.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Produk'),
        backgroundColor: Colors.orange.withOpacity(0.7),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama Produk Tidak Boleh Kosong!' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: price,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  _currencyFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Harga Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Harga Produk Tidak Boleh Kosong!' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _simpanData().then((value) {
                      if (value) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data Berhasil Diubah')),
                        );

                        Navigator.pushAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: ((context) => HalamanProduk())),
                          (route) => false,
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal Mengubah Data')),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ubah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
