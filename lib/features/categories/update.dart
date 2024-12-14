import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/core/constants/api_config.dart';
import 'package:myapp/features/categories/fetch.dart';

class UbahKategori extends StatefulWidget {
  final Map listdata;
  const UbahKategori({super.key, required this.listdata});

  @override
  State<UbahKategori> createState() => _UbahKategoriState();
}

class _UbahKategoriState extends State<UbahKategori> {
  final formKey = GlobalKey<FormState>();
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    id.text = widget.listdata['id'];
    name.text = widget.listdata['name'];
  }

  Future<bool> _simpanData() async {
    final respon = await http.post(
      Uri.parse('${ApiConfig.baseUrl}categories/update.php'),
      body: {
        'id': id.text,
        'name': name.text,
      },
    );

    return respon.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Kategori'),
        backgroundColor: Colors.orange.withAlpha(180),
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
                              builder: (context) => Categories()),
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
                  backgroundColor: Colors.orange.withAlpha(180),
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