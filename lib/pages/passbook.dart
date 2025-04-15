import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/khata_provider.dart';
import '../data/models/transaction.dart';
import '../data/models/contact.dart';

class Passbook extends StatefulWidget {
  const Passbook({Key? key}) : super(key: key);

  @override
  State<Passbook> createState() => _PassbookState();
}

class _PassbookState extends State<Passbook> {
  late Future<List<AppTransaction>> _futureTransactions;
  Map<int, Contact> _contactMap = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<KhataBookProvider>(context, listen: false);
    _futureTransactions = provider.getOverallPassbook();

    // Build a quick map of contact ID to Contact
    final allContacts = [...provider.customers, ...provider.suppliers];
    _contactMap = {for (var c in allContacts) c.id!: c};
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
          title: const Text('All Transactions'),
              backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,

      ),
      body: FutureBuilder<List<AppTransaction>>(
        future: _futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              final contact = _contactMap[txn.contactId];
              final txnDate = txn.date;
              final isCredit = txn.type == 'credit';
              final txnTime = txn.createdAt;

              return Card(
                color: Colors.grey.shade100,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCredit ? Colors.green : Colors.red,
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    contact?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.description ?? ''),
                      const SizedBox(height: 4),
                      Text('${dateFormatter.format(txnDate)} • ${timeFormatter.format(txnTime)}'),
                    ],
                  ),
                  trailing: Text(
                    (isCredit ? '+ ₹' : '- ₹') + txn.amount.toStringAsFixed(2),
                    style: TextStyle(
                      color: isCredit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
