import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khatabook/providers/khata_provider.dart';
import 'package:khatabook/widgets/build_action_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/contact.dart';
import '../data/models/transaction.dart';
import '../widgets/add_tranasaction_bottom_sheet.dart';

class TransactionPage extends StatefulWidget {
  final Contact contact;


  const TransactionPage({super.key, required this.contact});




  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<AppTransaction> _transactions = [];
  bool _isLoading = true;
  double _totalBalance = 0;
  String _balanceType = '';
  @override
  void initState() {
    super.initState();
    _loadTransactions();

  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<KhataBookProvider>(context, listen: false);
      if (widget.contact.id != null) {
        final transactions = await provider.getTransactionsForContact(
            widget.contact.id!);

        final summary = await provider.getContactSummary(widget.contact.id!);

        setState(() {
          _transactions = transactions;
          if (summary['balance']! >= 0) {
            _balanceType = 'give';
            _totalBalance = summary['balance']!;
          }
          else {
            _balanceType = 'get';
            _totalBalance = summary['balance']!;
          }
        });
      }
    }

    catch (e) {
      print('Error loading transaction: $e');
    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction(String type) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionBottomSheet(
          contactName: widget.contact.name,
          transactionType: type,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<KhataBookProvider>(context, listen: false);

        final newTransaction = AppTransaction(
          contactId: widget.contact.id!,
          amount: result['amount'],
          type: type,
          description: result['description'] ?? '',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await provider.addTransaction(newTransaction);
        await _loadTransactions(); // Refresh transactions
        await provider.loadStats();

      } catch (e) {
        print('Error adding transaction: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getDateAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }




  @override
  Widget build(BuildContext context) {

    String initials = '';
    if (widget.contact.name.isNotEmpty) {
      final nameParts = widget.contact.name.split(' ');
      if (nameParts.length > 1) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else {
        initials = widget.contact.name[0].toUpperCase();
      }
    }
    void makePhoneCall(String? phoneNumber) async {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }


    return Scaffold(
     appBar: AppBar(
       foregroundColor: Colors.white,
        backgroundColor:  Color(0xFF0D47A1),
       title: Row(
         children: [
           CircleAvatar(
             backgroundColor: Colors.white,
             radius: 16,
             child: Text(initials,
             style: const TextStyle(
               color: Colors.black,
               fontWeight: FontWeight.bold,
               fontSize: 14
             ),),
           ),
           const SizedBox(width: 12,),
           Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(widget.contact.name,
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                   ),
                   const Text('View settings',
                   style: TextStyle(color: Colors.white,
                   fontSize: 14),)
                 ],
               )),
           
           InkWell(
             onTap: (){
               makePhoneCall(widget.contact.phone);
             },
               child: Icon(Icons.phone)
           )
           
         ],
       ),
     ),
      body:
      // _isLoading?
          // const Center(
          //   child: CircularProgressIndicator(),
          // )
          // :
      Column(
        children: [
          Container(
            width: double.infinity,
            margin:  const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_balanceType == 'give' ? 'You will give': 'You will get',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                ),
                Text(
                '₹ ${(_totalBalance.toInt()).abs()}',
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _balanceType == 'give' ? Colors.red : Colors.green,
                )
                )
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildActionButton(
                icon: Icons.picture_as_pdf,
                label: 'Report',
                color: Colors.blue[800]!,
                onTap: () {

                }
              ),
              buildActionButton(
                  icon: Icons.message,
                  label: 'Reminder',
                  color: Colors.blue[800]!,
                  onTap: () {

                  }
              ),
              buildActionButton(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  color: Colors.grey[400]!,
                  onTap: () {

                  }
              ),
            ],
          ),
          )
          ,
          const SizedBox( height: 5),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text('Entries',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  )
              ),
              Expanded(
                  child: Text(
                    "YOU GAVE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ),
              Expanded(
                child: Text(
                  'YOU GOT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),),
          const SizedBox( height: 10),
          Expanded(
              child: _transactions.isEmpty?
                  Text('Only you and ${widget.contact.name} can see these entries',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14
                    ),
                  ):
                  ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context,index){
                        final transactions = _transactions[index];
                        return _buildTransactionItem(transactions);
                      }
                      )
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _addTransaction('debit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              )
                            ),
                            child: const Text(
                              'YOU GAVE ₹',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            )
                        )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            )
                          ),
                            onPressed: ()=>  _addTransaction('credit'),
                            child: Text("YOU GOT ₹",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),)
                        )
                    )
                  ],
                ))
              ],
            ),
          )
        ],
      )


    );
  }
  Widget _buildTransactionItem(AppTransaction transaction) {
    final date = transaction.date;
    final time = transaction.createdAt;
    final formattedDate = DateFormat('dd MMM yy').format(date);
    final formattedTime = DateFormat('h:mm a').format(time);

    final isCredit = transaction.type == 'credit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date and transaction details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$formattedDate • $formattedTime',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bal. ₹ ${_totalBalance.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // You gave amount (or empty)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isCredit ? null : Colors.red[50],
              child: isCredit
                  ? const SizedBox()
                  : Text(
                '₹ ${transaction.amount.toInt()}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // You got amount (or empty)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isCredit ? Colors.green[50] : null,
              child: isCredit
                  ? Text(
                '₹ ${transaction.amount.toInt()}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }


}
