import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> academicInfoList = [];
  List<dynamic> nonAcademicInfoList = [];
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  Future<void> fetchInfo() async {
    try {
      final response =
          await http.get(Uri.parse('https://hayy.my.id/ziqi_api/info.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          academicInfoList =
              data.where((info) => info['kategori'] == 'akademik').toList();
          nonAcademicInfoList =
              data.where((info) => info['kategori'] == 'non-akademik').toList();
        });
      } else {
        throw Exception('Gagal memuat data informasi');
      }
    } catch (e) {
      print('Error fetching info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void _showAddInfoDialog() {
    _judulController.clear();
    _isiController.clear();
    _statusController.clear();
    _kategoriController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Informasi Baru'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(hintText: "Judul Informasi"),
                ),
                TextField(
                  controller: _isiController,
                  decoration: InputDecoration(hintText: "Isi Informasi"),
                  maxLines: 3,
                ),
                TextField(
                  controller: _statusController,
                  decoration: InputDecoration(hintText: "Status"),
                ),
                TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                      hintText: "Kategori (akademik/non-akademik)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tambah'),
              onPressed: () {
                _addNewInfo(); // Tambahkan tanpa pilih tanggal manual
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewInfo() async {
    try {
      final response = await http.post(
        Uri.parse('https://hayy.my.id/ziqi_api/info.php'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded", // Penting untuk PHP
        },
        body: {
          'judul_info': _judulController.text,
          'isi_info': _isiController.text,
          'tgl_post_info': DateTime.now()
              .toLocal()
              .toString()
              .split(' ')[0], // Menggunakan waktu real-time
          'status_info': _statusController.text,
          'kategori': _kategoriController.text,
        },
      );

      if (response.statusCode == 200) {
        await fetchInfo(); // Refresh data setelah menambahkan info
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Informasi berhasil ditambahkan')),
        );
      } else {
        throw Exception('Gagal menambahkan informasi');
      }
    } catch (e) {
      print('Error adding info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan informasi: $e')),
      );
    }
  }

  void _showEditInfoDialog(String kdInfo, String currentJudul,
      String currentIsi, String currentKategori, String currentTanggal) {
    _judulController.text = currentJudul;
    _isiController.text = currentIsi;
    _kategoriController.text = currentKategori;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Informasi'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(hintText: "Judul Informasi"),
                ),
                TextField(
                  controller: _isiController,
                  decoration: InputDecoration(hintText: "Isi Informasi"),
                  maxLines: 3,
                ),
                TextField(
                  controller: _kategoriController,
                  decoration: InputDecoration(hintText: "Kategori"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                _editInfo(kdInfo); // Gunakan waktu real-time
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editInfo(String kdInfo) async {
    final response = await http.put(
      Uri.parse('https://hayy.my.id/ziqi_api/info.php'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // Penting untuk PHP
      },
      body: {
        'kd_info': kdInfo,
        'judul_info': _judulController.text,
        'isi_info': _isiController.text,
        'kategori': _kategoriController.text,
        'tgl_post_info': DateTime.now()
            .toLocal()
            .toString()
            .split(' ')[0], // Menggunakan waktu real-time untuk update
      },
    );

    if (response.statusCode == 200) {
      fetchInfo(); // Refresh data setelah memperbarui info
      Navigator.of(context).pop();
    } else {
      throw Exception('Gagal mengupdate informasi');
    }
  }

  void _showDeleteConfirmationDialog(String kdInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus informasi ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                _deleteInfo(kdInfo);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteInfo(String kdInfo) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/ziqi_api/info.php'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded", // Penting untuk PHP
      },
      body: {
        'kd_info': kdInfo,
      },
    );

    if (response.statusCode == 200) {
      fetchInfo(); // Refresh data setelah menghapus info
      Navigator.of(context).pop();
    } else {
      throw Exception('Gagal menghapus informasi');
    }
  }

  Widget _buildInfoSection(String title, List<dynamic> infoList) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: infoList.map((info) {
          return ListTile(
            title: Text(
              info['judul_info'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: ${info['tgl_post_info']}'),
                Text('Isi: ${info['isi_info']}'),
                Text('Status: ${info['status_info']}'),
                Text('Kategori: ${info['kategori'] ?? ''}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit,
                      color: const Color.fromARGB(255, 72, 76, 80)),
                  onPressed: () {
                    _showEditInfoDialog(
                      info['kd_info'],
                      info['judul_info'],
                      info['isi_info'],
                      info['kategori'] ?? '',
                      info['tgl_post_info'], // Pass current date to edit dialog
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Color.fromARGB(255, 52, 70, 74)),
                  onPressed: () {
                    _showDeleteConfirmationDialog(info['kd_info']);
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manajemen Informasi"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoSection('Informasi Akademik', academicInfoList),
            _buildInfoSection('Informasi Non-Akademik', nonAcademicInfoList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInfoDialog,
        backgroundColor: Color.fromARGB(255, 60, 63, 81),
        child: const Icon(Icons.add),
      ),
    );
  }
}
