import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uasremidi/service/firebase_service.dart';
import 'package:uasremidi/service/img_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:uasremidi/component/CustomDropdown.dart';
import 'package:uasremidi/component/CustomFormField.dart';

class FormPage extends StatefulWidget {
  final String id;
  final bool isUpdate;

  const FormPage({super.key, required this.isUpdate, this.id = ""});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final FirebaseHttpService _firebaseService = FirebaseHttpService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _title = TextEditingController() ;
  final TextEditingController _jenis = TextEditingController();
  final TextEditingController _tanggal = TextEditingController() ;
  final TextEditingController _jumlah = TextEditingController() ;
  final TextEditingController _deskripsi = TextEditingController() ;
  File? _image;
  String imgUrl = "";

  final List<String> jenis = [
    'Pengeluaran',
    'Pemasukan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.id.isNotEmpty) {
      _firebaseService.getDataById(widget.id).then((data) {
        setState(() {
          _title.text = data['title'] ?? '';
          _jenis.text = data['jenis'] ?? '';
          _tanggal.text = data['tanggal'] ?? '';
          _jumlah.text = data['jumlah'] ?? '';
          _deskripsi.text = data['deskripsi'] ?? '';
          imgUrl = data['imageUrl'] ?? '';
        });
      });
    }
  }

  final ImagePicker picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    bool permissionGranted = false;
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();
    permissionGranted = status.isGranted;

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Izin diperlukan untuk mengakses gambar.")),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void submitData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // final imageFile;
      // final cloudinary;
      // final imageUrl;
      // if (imgUrl == "") {
      //   if (_image == null) {
      //     Navigator.pop(context);
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Upload gambar dulu')),
      //     );
      //     return;
      //   }
      //   imageFile = File(_image!.path);
      //   cloudinary = CloudinaryService();
      //   imageUrl = await cloudinary.uploadImageToCloudinary(imageFile);
      // } else {
      //   if (_image != null) {
      //     imageFile = File(_image!.path);
      //     cloudinary = CloudinaryService();
      //     imgUrl = await cloudinary.uploadImageToCloudinary(imageFile);
      //   }
      //   imageUrl = imgUrl;
      // }
      final imageUrl = null;

      final data = {
        'title': _title.text,
        'jenis': _jenis.text,
        'tanggal': _tanggal.text,
        'jumlah': _jumlah.text,
        'deskripsi': _deskripsi.text,
        'imageUrl': imgUrl,
      };

      if (widget.isUpdate) {
        await _firebaseService.updateData(widget.id, data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data berhasil diperbarui")));
      } else {
        await _firebaseService.createData(data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data berhasil ditambahkan")));
      }

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Tambah Data',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageSourceOptions();
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF201E43),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                  ? SizedBox(
                    width: double.infinity,
                    child: Image.file( _image!, fit: BoxFit.contain),
                  )
                  : imgUrl != ""
                  ? SizedBox(
                    width: double.infinity,
                    child: Image.network( imgUrl, fit: BoxFit.contain),
                  )
                  : SizedBox(
                    height: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.white),
                        SizedBox(height: 10),
                        Text('Upload Image', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                ),
              ),
              SizedBox(height: 20),
              CustomFormField(
                label: 'Title',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Wisata tidak boleh kosong';
                  }
                  return null;
                },
                controller: _title,
                onSaved: (value) => _title.text = value!,
              ),
              CustomDropdown<String>(
                  label: "Gender",
                  items: jenis.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  value: _jenis.text.isEmpty ? null : _jenis.text,
                  onChanged: (value) => setState(() => _jenis.text = value ?? ""),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis kelamin harus dipilih';
                    }
                    return null;
                  },
                  isUpdate: widget.isUpdate,
                ),
              CustomFormField(
                label: 'Tanggal',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi Wisata tidak boleh kosong';
                  }
                  return null;
                },
                controller: _tanggal,
                onSaved: (value) => _tanggal.text = value!,
              ),
              CustomFormField(
                label: 'Jumlah',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga Tiket tidak boleh kosong';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Harga Tiket harus berupa angka';
                  } 
                  return null;
                },
                controller: _jumlah,
                onSaved: (value) => _jumlah.text = value!,
              ),
              CustomFormField(
                label: 'Deskripsi',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
                controller: _deskripsi,
                onSaved: (value) => _deskripsi.text = value!,
                maxLines: 4
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF201E43),
                ),
                child: Text('Simpan', style: TextStyle(color: Colors.white),),
              ),
              TextButton(
                onPressed: () {
                  _formKey.currentState!.reset();
                  setState(() {
                    _title.text = '';
                    _jenis.text = '';
                    _tanggal.text = '';
                    _jumlah.text = '';
                    _deskripsi.text = '';
                  });
                },
                child: Text('Reset'),
              )
            ],
          ),
        ),
      ),
    );
  }
}