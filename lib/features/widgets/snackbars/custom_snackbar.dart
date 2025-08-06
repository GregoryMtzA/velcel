import 'package:flutter/material.dart';

SnackBar CustomSnackbar({required Color color, required String title,
                         required String message, required IconData icon}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    width: 350,
    backgroundColor: Colors.transparent,
    content: Container(
        height: 75,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: color,),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${title}',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    '${message}',
                    style: TextStyle(
                        color: Colors.white, fontSize: 13
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        )
    ),
  );
}