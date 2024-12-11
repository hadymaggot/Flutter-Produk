// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/config/api_config.dart';
import 'package:myapp/halaman_produk.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();

  TextInputFormatter _currencyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (newText.isEmpty) {
        return TextEditingValue(text: '');
      }

      final number = int.tryParse(newText);
      if (number != null) {
        final formattedText = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(number);

        return TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }

      return newValue;
    });
  }

  Future<bool> _fetch() async {
    final respon =
        await http.post(Uri.parse('${ApiConfig.baseUrl}create.php'), body: {
      'name': name.text,
      'price': price.text.replaceAll(RegExp(r'[^0-9]'), ''),
    });

    if (respon.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Produk'),
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
                const SizedBox(height: 10),
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
                  validator: (value) => value!.isEmpty
                      ? 'Harga Produk Tidak Boleh Kosong!'
                      : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _fetch().then((value) {
                        if (value) {
                          final snackBar =
                              SnackBar(content: Text('Data Berhasil Disimpan'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => HalamanProduk())),
                              (route) => false);
                        } else {
                          final snackBar =
                              SnackBar(content: Text('Gagal Menyimpan Data'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ));
  }
}
