import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.merchantIdentifier = 'testMode';
  Stripe.publishableKey =
      'pk_test_51KP9GBHc6vjRGOHz1XmLawkP2s4nv0i4qWDZCd0OJ1GuIRYGrVaxKwGm8ZFRK2Blv8lxYk31JGfJFb3YuVIUwd7D00j4doskav';
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Stripe Payment'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  await makePayment(context);
                },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text('Pay'),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Future<void> makePayment(BuildContext x) async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: true,
              googlePay: true,
              style: ThemeMode.dark,
              merchantCountryCode: 'US',
              merchantDisplayName: 'GOKHAN'));

      displayPaymentShee(x);
    } catch (e) {
      print('exception1' + e.toString());
    }
  }

  displayPaymentShee(BuildContext x) async {
    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ));
      setState(() {
        paymentIntentData = null;
      });

      ScaffoldMessenger.of(x)
          .showSnackBar(SnackBar(content: Text('paid successfully')));
    } on StripeException catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmunt(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51KP9GBHc6vjRGOHzpKS4Sccyc2ld828gAYFuWXtH2d2Cpo5UgGXCqs3U7s571E5lqbKzpXQ0j3ZRhUcy25g4KenO00w7z9m2a5',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body.toString());
    } catch (e) {
      print('exception2' + e.toString());
    }
  }

  calculateAmunt(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
