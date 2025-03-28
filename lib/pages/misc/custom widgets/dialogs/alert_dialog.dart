import 'package:flutter/material.dart';

import '../../colors.dart';
/// CustomAlertDialog - A simple, reusable alert dialog for displaying messages.
///
/// This dialog is designed for cases where only one button is needed
/// (e.g., "OK" or "Confirm") without a cancel option.
///
/// Usage:
/// showAlertDialog(
///   context,
///   "assets/images/imagename.png",
///   "Title",
///   "Message",
///   "ButtonText", // Optional
///   () {
///     // Action when the button is clicked (optional)
///   }
/// );
///
/// Parameters:
/// - imagePath: The path of the image to display in the dialog.
/// - title: The title of the alert.
/// - message: The message content of the dialog.
/// - button1: (Optional) The text for the button, default is "OK".
/// - onConfirm: (Optional) Callback function for when the button is pressed.
///


class CustomAlertDialog extends StatelessWidget {
  final String imagePath, title,message,button1 ;
  final VoidCallback onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.message,
    required this.button1,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      contentPadding: const EdgeInsets.all(20) ,
      content:Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 190, fit: BoxFit.fill),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: DeckColors.primaryColor , fontSize: 25, fontFamily: 'Fraiche'),
              textAlign: TextAlign.center,),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(fontSize: 15, fontFamily: 'Nunito-Regular'),
              textAlign: TextAlign.center,),
            const SizedBox(height: 5),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DeckColors.primaryColor,
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: () {
                onConfirm();
              },
              child: Text(button1, style: const TextStyle(color: DeckColors.white)),
            ),
          ]
      ),
    );
  }
}

//Used to show the Dialog Box
void showAlertDialog(
    BuildContext context,
    String imagePath,
    String title,
    String message,
    { String button1 = "Ok",
      VoidCallback? onConfirm,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        imagePath:imagePath, //image of deck
        title: title, // title of alert
        message: message, //subtitle or detailed message
        button1: button1, //text of button, default is Ok
        onConfirm: onConfirm ?? () { Navigator.of(context).pop(); }, //when button is pressed perform action
      );
    },
  );
}
