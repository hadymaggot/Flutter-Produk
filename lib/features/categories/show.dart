import 'package:flutter/material.dart';

class DetailKategori extends StatefulWidget {
  final Map listdata;
  const DetailKategori({Key? key, required this.listdata});

  @override
  State<DetailKategori> createState() => _DetailKategoriState();
}

class _DetailKategoriState extends State<DetailKategori> {
  final formKey = GlobalKey<FormState>();
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController nmKategori = TextEditingController();

  @override
  Widget build(BuildContext context) {
    id.text = widget.listdata['id'];
    name.text = widget.listdata['name'];
    nmKategori.text = widget.listdata['nmKategori'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        title: const Text('Detail Kategori'),
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
                    labelText: 'ID Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: widget.listdata['name'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
