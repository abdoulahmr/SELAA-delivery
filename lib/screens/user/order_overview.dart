import 'package:flutter/material.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/backend_functions/load_data.dart';

class OrderOverview extends StatefulWidget {
  const OrderOverview({super.key, required this.orderID, required this.sellerID});
  final String orderID;
  final String sellerID;

  @override
  State<OrderOverview> createState() => _OrderOverviewState();
}

class _OrderOverviewState extends State<OrderOverview> {
  List<Map<String, dynamic>> orderItems = [];
  List<Map<String, dynamic>> sellerInfo = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrderData();
  }

  Future<void> loadOrderData() async {
    try {
      final items = await getOrderItems(widget.orderID);
      final seller = await loadSellerInfo(widget.sellerID);
      setState(() {
        orderItems = items;
        sellerInfo = seller;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Content"),
        backgroundColor: AppColors().secondaryColor,
      ),
      body: isLoading
      ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors().primaryColor),
        )
      )
      : Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: AppColors().secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            ),
            child: Column(
              children: [
                Text(
                  "${sellerInfo[0]['firstname']} ${sellerInfo[0]['lastname']}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sellerInfo[0]['address'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  sellerInfo[0]['phoneNumber'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: SizedBox(
                        width: 50,
                        child: Image.network(orderItems[index]['product']['imageUrls'][0]),
                      ),
                      title: Text(orderItems[index]['product']['title']),
                      subtitle: Text("${orderItems[index]['quantity']} pcs"),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
