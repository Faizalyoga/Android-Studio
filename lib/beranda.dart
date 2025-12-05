import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Halaman_Utama extends StatefulWidget {
  const Halaman_Utama({super.key});

  @override
  State<Halaman_Utama> createState() => _Halaman_UtamaState();
}

class _Halaman_UtamaState extends State<Halaman_Utama> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();

  final List<String> _prodiList = ['Informatika', 'Mesin', 'Sipil', 'Arsitek'];
  final List<String> _kelasList = ['A', 'B', 'C', 'D', 'E'];

  String? _selectedKelas;
  String? _selectedProdi;
  String _jenisKelamin = 'Pria';

  int? _editingIndex;

  List<Map<String, dynamic>> _items = [];
  static const String _prefsKey = 'submissions';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw != null) {
      setState(() {
        _items = raw.map((v) => jsonDecode(v) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _items.map((e) => jsonEncode(e)).toList(),
    );
  }

  // ============================ SUBMIT / UPDATE =============================
  void _addOrUpdateItem() {
    final nama = _namaController.text.trim();
    final alamat = _alamatController.text.trim();
    final npm = _npmController.text.trim();

    if (nama.isEmpty || npm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama & NPM wajib diisi")));
      return;
    }

    if (_editingIndex == null) {
      setState(() {
        _items.insert(0, {
          "nama": nama,
          "alamat": alamat,
          "npm": npm,
          "kelas": _selectedKelas ?? "-",
          "prodi": _selectedProdi ?? "-",
          "jk": _jenisKelamin,
          "createdAt": DateTime.now().toIso8601String(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil ditambahkan")),
      );
    } else {
      final oldCreate = _items[_editingIndex!]["createdAt"];

      setState(() {
        _items[_editingIndex!] = {
          "nama": nama,
          "alamat": alamat,
          "npm": npm,
          "kelas": _selectedKelas ?? "-",
          "prodi": _selectedProdi ?? "-",
          "jk": _jenisKelamin,
          "createdAt": oldCreate,
          "updatedAt": DateTime.now().toIso8601String(),
        };

        _editingIndex = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil diperbarui")));
    }

    _saveAll();
    _clearForm();
  }

  void _clearForm() {
    _namaController.clear();
    _alamatController.clear();
    _npmController.clear();

    setState(() {
      _selectedKelas = null;
      _selectedProdi = null;
      _jenisKelamin = "Pria";
      _editingIndex = null;
    });
  }

  // ============================ DETAIL POPUP =============================
  void _showDetail(Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Detail Mahasiswa",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Nama: ${item['nama']}\n"
          "Alamat: ${item['alamat']}\n"
          "NPM: ${item['npm']}\n"
          "Kelas: ${item['kelas']}\n"
          "Prodi: ${item['prodi']}\n"
          "Jenis Kelamin: ${item['jk']}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _editingIndex = index;
                _namaController.text = item['nama'];
                _alamatController.text = item['alamat'];
                _npmController.text = item['npm'];
                _selectedKelas = item['kelas'];
                _selectedProdi = item['prodi'];
                _jenisKelamin = item['jk'];
              });
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _items.removeAt(index);
              });
              _saveAll();
            },
            child: const Text("Hapus"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // ============================ UI BUILD =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ============================ APPBAR =============================
      appBar: AppBar(
        title: const Text(
          "Data Mahasiswa",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // ============================ BACKGROUND GRADIENT =============================
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6328FF), Color(0xFF4E6BFF), Color(0xFF29D0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 110, 16, 40),
          child: Column(
            children: [
              // ============================ FORM GLASS CARD =============================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _inputField(_namaController, Icons.person, "Nama"),
                    const SizedBox(height: 12),
                    _inputField(_alamatController, Icons.home, "Alamat"),
                    const SizedBox(height: 12),
                    _inputField(
                      _npmController,
                      Icons.confirmation_number,
                      "NPM",
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField(
                      value: _selectedKelas,
                      decoration: _dropStyle("Pilih Kelas"),
                      items: _kelasList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedKelas = v),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField(
                      value: _selectedProdi,
                      decoration: _dropStyle("Pilih Prodi"),
                      items: _prodiList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedProdi = v),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text("Jenis Kelamin:"),
                        Radio(
                          value: "Pria",
                          groupValue: _jenisKelamin,
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text("Pria"),
                        Radio(
                          value: "Perempuan",
                          groupValue: _jenisKelamin,
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text("Perempuan"),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ============================ GRADIENT BUTTON =============================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8C4BFF),
                            Color(0xFF5564FF),
                            Color(0xFF18E1FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: _addOrUpdateItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _editingIndex == null ? "Submit" : "Update",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ============================ LIST TITLE =============================
              const Text(
                "Daftar Mahasiswa",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                ),
              ),

              const SizedBox(height: 16),

              // ============================ LIST CARD =============================
              ..._items.map((item) {
                int index = _items.indexOf(item);

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      item["nama"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("${item['npm']} • ${item['prodi']}"),
                    trailing: Text(
                      item["kelas"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () => _showDetail(item, index),
                  ),
                );
              }),

              if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Belum ada data",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================================

  Widget _inputField(controller, icon, label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  InputDecoration _dropStyle(String text) {
    return InputDecoration(
      labelText: text,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
