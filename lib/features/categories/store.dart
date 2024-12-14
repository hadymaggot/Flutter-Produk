// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/constants/api_config.dart';

class TambahKategori extends StatefulWidget {
  const TambahKategori({super.key});

  @override
  State<TambahKategori> createState() => _TambahKategoriState();
}

class _TambahKategoriState extends State<TambahKategori> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();

  bool _loading = false;

  Future<bool> _submitData() async {
    if (_name.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a name for the category!')),
      );
      return false;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}categories/create.php');
      final response = await http.post(
        uri,
        body: {
          'name': _name.text,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          if (kDebugMode) {
            print('Error submitting data: ${response.body}');
          }
        }
        throw Exception('Failed to submit data: ${response.body}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kategori'),
        backgroundColor: Colors.orange.withAlpha(180),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama Kategori Tidak Boleh Kosong!' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });

                    final success = await _submitData();
                    setState(() {
                      _loading = false;
                    });

                    if (success) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Kategori Berhasil Disimpan')),
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gagal Menyimpan Kategori')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
