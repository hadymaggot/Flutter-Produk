// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:saptohadi/core/constants/api_config.dart';
import 'package:http_parser/http_parser.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}categories/read.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data['data']);
          // if (_categories.isEmpty) {
          //   _selectedCategory = '-';
          // }
          _loading = false;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  Future<bool> _submitData() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields!')),
      );
      return false;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}products/create.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = _name.text;
      request.fields['price'] = _price.text.replaceAll(RegExp(r'[^0-9]'), '');
      request.fields['id_kategori'] = _selectedCategory ?? '';

      if (_selectedImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            _selectedImageBytes!,
            filename: _selectedImageName ?? 'uploaded_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode == true) {
          // ignore: avoid_print
          print('Error uploading data: ${responseBody.body}');
        }
        throw Exception('Failed to submit data: ${responseBody.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $e')),
      );
      return false;
    }
  }

  TextInputFormatter _currencyFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (newText.isEmpty) return TextEditingValue(text: '');

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

  Widget _buildPhotoPicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: _selectedImage != null || _selectedImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload Foto',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = pickedFile.name;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.orange.withAlpha(180),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Nama Produk Tidak Boleh Kosong!'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_currencyFormatter()],
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Kategori harus dipilih!' : null,
                    ),
                    const SizedBox(height: 10),
                    _buildPhotoPicker(),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await _submitData();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Data Berhasil Disimpan')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Gagal Menyimpan Data')),
                            );
                          }
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
            ),
    );
  }
}
