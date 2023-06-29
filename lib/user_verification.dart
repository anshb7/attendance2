import 'package:attendance2/google_sheets_api.dart';
import 'package:attendance2/homepage.dart';
import 'package:attendance2/user.dart';
import 'package:flutter/material.dart';

class UserVerificationScreen extends StatefulWidget {
  const UserVerificationScreen({Key? key, required this.user})
      : super(key: key);
  final User user;
  @override
  State<UserVerificationScreen> createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends State<UserVerificationScreen> {
  
  String teamNo = '';
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: Column(
            children: [
              CustomWidget(
                widget: Text('${widget.user.name}'),
                heading: 'Name',
              ),
              CustomWidget(
                  widget: Text('${widget.user.email}'), heading: 'Email'),
              CustomWidget(
                  widget: Text('${widget.user.gender}'), heading: 'Gender'),
              CustomWidget(
                  widget: Text('${widget.user.hostel}'), heading: 'Hostel'),
              CustomWidget(
                  widget: Text('${widget.user.phone_no}'), heading: 'Phone No'),
              CustomWidget(
                  widget: Text('${widget.user.team}'), heading: 'Team'),
              CustomWidget(
                  widget: Text('${widget.user.roll_no}'), heading: 'Roll no'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Team Number'),
                  Container(
                    width: 200,
                    height: 40,
                    child: TextField(
                      onChanged: (value) {
                        teamNo = value;
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () async {
                  if (teamNo != '') {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      await GoogleSheetsApi.insert(widget.user, teamNo);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (ctx) => HomePage()));
                    } catch (e) {
                      SnackBar snackBar;
                      snackBar = SnackBar(content: Text("Try Again"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } finally {
                      isLoading = false;
                    }
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Container(
                        width: 120,
                        height: 50,
                        color: Colors.blueAccent,
                        child: Center(
                          child: Text(
                            'Submit',
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomWidget extends StatelessWidget {
  const CustomWidget({
    Key? key,
    required this.widget,
    required this.heading,
  }) : super(key: key);

  final Text widget;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(heading),
        widget,
      ],
    );
  }
}
