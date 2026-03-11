import 'package:flutter/material.dart';
import 'package:getbike_admin/utils/utilities.dart';

class SettingsPage extends StatelessWidget {
   SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Settings' ,  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading:  Icon(Icons.person),
            title:  Text('Account' , style: mediumblack,),
            subtitle:  Text('Manage your account'),
            onTap: () {
              // Navigate to account settings
            },
          ),
           Divider(),
          ListTile(
            leading:  Icon(Icons.notifications),
            title:  Text('Notifications', style: mediumblack,),
            subtitle:  Text('Notification preferences'),
            onTap: () {
              // Navigate to notification settings
            },
          ),
           Divider(),
          ListTile(
            leading:  Icon(Icons.lock),
            title:  Text('Privacy', style: mediumblack,),
            subtitle:  Text('Privacy and security'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
           Divider(),
          ListTile(
            leading:  Icon(Icons.info),
            title:  Text('About', style: mediumblack,),
            subtitle:  Text('App information'),
            onTap: () {
              // Navigate to about page
            },
          ),
           Divider(),
          ListTile(
            leading:  Icon(Icons.logout),
            title:  Text('Logout', style: mediumblack,),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}