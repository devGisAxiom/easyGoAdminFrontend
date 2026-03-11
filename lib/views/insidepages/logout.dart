import 'package:flutter/material.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/home.dart';
import 'package:getbike_admin/views/login.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text("Sure Want to Log Out" , style: normalgrey,),
          SizedBox(height: 16,),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
          
//               Center(
//                 child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                             onPressed: (){
//                               Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen() ));
//                             }, child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text("Cancel" , style: normalred,),
//                             )),
//               ),
          
//               SizedBox(width: 20,),
          
//                             Center(
//                                     child: ElevatedButton(
//                                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                                                         onPressed: (){
//                                                               Navigator.pushAndRemoveUntil(
//   context,
//   MaterialPageRoute(builder: (context) => SignInPage()),
//   (Route<dynamic> route) => false, // Removes all previous routes
// );
//                                                         }, child: Padding(
//                                                           padding: const EdgeInsets.all(8.0),
//                                                           child: Text("LogOut" , style: normalwhite,),
//                                                         )),
//                                   ),
//             ],
//           ),
        ],
      ),
    ),
    );
  }
}