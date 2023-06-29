import 'dart:async';
import 'dart:io';
import 'package:attendance2/user.dart';
import 'package:attendance2/user_verification.dart';
import 'package:flutter/material.dart';
import 'google_sheets_api.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloading = false;
  User? user = User(
      name: "",
      email: "",
      gender: "",
      hostel: "",
      phone_no: "",
      team: "",
      roll_no: "");
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controller!.resumeCamera();
  //   }
  // }
  // collect user input

  // enter the new transaction into the spreadsheet

  // new transaction

  // wait for the data to be fetched from google sheets

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Attendance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderWidth: 10,
                    borderLength: 20,
                    borderRadius: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8),
              ),
            ),
            Container(
                child: isloading
                    ? CircularProgressIndicator()
                    : (result != null)
                        ? Text("data: ${result!.code}")
                        : Text("No information available")),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });
                  await markpresent();
                  setState(() {
                    isloading = false;
                  });
                  if (user != null) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                UserVerificationScreen(user: user!)),
                        (route) => false);
                  }
                },
                child: Text("MARK PRESENT"))
          ])),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    this.controller!.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  Future markpresent() async {
    await fetchUser();
    // await GoogleSheetsApi.insert(user);
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  fetchUser() async {
    var headers = {
      "Authorization": "Token 3f3c6554418b57a350b885fc35e0cb253f4c05dd",
    };
    final response =
        await http.get(Uri.parse(result!.code.toString()), headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      User userr = User.fromJson(jsonDecode(response.body));
      user = User(
          name: userr.name,
          email: userr.email,
          gender: userr.gender,
          hostel: userr.hostel,
          phone_no: userr.phone_no,
          team: userr.team,
          roll_no: userr.roll_no);
    } else if (response.statusCode == 423) {
      SnackBar snackBar;
      snackBar = SnackBar(content: Text("Already Scanned"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      user = null;
    } else {
      print(response.statusCode);
      SnackBar snackBar;
      snackBar = SnackBar(content: Text("Something went wrong"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      user = null;
    }
  }
}
