import 'package:flutter/material.dart';
import 'package:cafeubernet_app/controllers/sales_controller.dart';
import 'package:cafeubernet_app/models/sales_model.dart';

class SalesScreen extends StatefulWidget {
  final ValueNotifier<bool> updateNotifier;

  SalesScreen({required this.updateNotifier});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Future<List<Sales>> futuresales;
  final saleController _saleController = saleController();

  @override
  void initState() {
    super.initState();
    futuresales = _saleController.fetchsales();
    widget.updateNotifier.addListener(_fetchData);
  }

  @override
  void dispose() {
    widget.updateNotifier.removeListener(_fetchData);
    super.dispose();
  }

  void _fetchData() {
    setState(() {
      futuresales = _saleController.fetchsales();
    });
  }

  void _deletesale(String id) async {
    try {
      await _saleController.deletesale(id);
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus stok: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditDialog(Sales sale) {
    final TextEditingController _buyerController =
        TextEditingController(text: sale.buyer);
    final TextEditingController _phoneController =
        TextEditingController(text: sale.phone);
    final TextEditingController _dateController =
        TextEditingController(text: sale.date);
    String? _selectedStatus = sale.status;

    Future<void> _selectDate(BuildContext context) async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          _dateController.text = "${picked.toLocal()}".split(' ')[0];
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Edit Sale'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _buyerController,
                  decoration: InputDecoration(labelText: 'Pembeli'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: 'Tanggal'),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                  ),
                  items: ['Pending', 'Done'].map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green[200]),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              onPressed: () async {
                try {
                  await _saleController.updatesale(
                    id: sale.id,
                    buyer: _buyerController.text,
                    phone: _phoneController.text,
                    date: _dateController.text,
                    status: _selectedStatus ?? '',
                    issuer: sale.issuer,
                  );
                  Navigator.of(context).pop();
                  _fetchData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal memperbarui stok: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.updateNotifier,
      builder: (context, value, child) {
        return Container(
          color: Colors.green[200],
          child: Center(
            child: FutureBuilder<List<Sales>>(
              future: futuresales,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Sales> sales = snapshot.data!;
                  List<Sales> filteredsales =
                      sales.where((sale) => sale.issuer == 'Danih').toList();
                  if (filteredsales.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredsales.length,
                      itemBuilder: (context, index) {
                        Sales sale = filteredsales[index];
                        return Container(
                          margin: EdgeInsets.only(
                              top: 10.0, left: 16.0, right: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            title: Text(sale.buyer),
                            subtitle: Text('${sale.date} || ${sale.status}'),
                            trailing: IconButton(
                              onPressed: () => _deletesale(sale.id),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.only(right: 5, left: 15),
                            onTap: () => _showEditDialog(sale),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text('Tidak ada data');
                  }
                }
                return Text('Tidak ada data');
              },
            ),
          ),
        );
      },
    );
  }
}
