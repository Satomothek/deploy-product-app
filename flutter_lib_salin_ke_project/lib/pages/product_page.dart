import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ApiService _api = ApiService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getProducts();
  }

  void _reload() => setState(() => _future = _api.getProducts());

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _openForm([Product? product]) async {
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price.toString() ?? '');
    final stock = TextEditingController(text: product?.stock.toString() ?? '0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Ubah Produk'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
          TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga')),
          TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final p = int.tryParse(price.text) ?? 0;
      final s = int.tryParse(stock.text) ?? 0;
      if (product == null) {
        await _api.createProduct(name.text, p, s);
        _snack('Produk ditambahkan');
      } else {
        await _api.updateProduct(product.id, name.text, p, s);
        _snack('Produk diperbarui');
      }
      _reload();
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _delete(Product p) async {
    try {
      await _api.deleteProduct(p.id);
      _snack('Produk dihapus');
      _reload();
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk (API Online)')),
      floatingActionButton:
          FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${snap.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _reload, child: const Text('Coba lagi')),
              ]),
            );
          }
          final items = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final p = items[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('Rp ${p.price}  •  Stok ${p.stock}'),
                  onTap: () => _openForm(p),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete), onPressed: () => _delete(p)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
