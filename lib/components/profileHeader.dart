import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/ApiConfig.dart';
import '../authentication/AuthService.dart';
import '../authentication/profile.dart'; // Import the ProfilePage

class ProfileHeader extends StatefulWidget {
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  Future<Map<String, dynamic>> _fetchProfileDetails() async {
    final String baseUrl = ApiConfig.baseUrl;
    final token = await AuthService.getToken() ?? '';
    final response = await http.get(
      Uri.parse('${baseUrl}auth/nav-profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchProfileDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final profileData = snapshot.data!['data'];
          final String profileImageUrl = profileData['profile_image'] ?? ''; // Assuming the API response key for profile image URL is 'profile_image'
          final String initials = profileData['initial'] ?? ''; // Assuming the API response key for initials is 'initial'
          final String firstName = profileData['first_name'] ?? '';
          final String lastName = profileData['last_name'] ?? '';
          final String investorId = profileData['investor_id'] ?? '';
          final List<dynamic> groupNames = profileData['group_names'] ?? [];

          return Container(
            height: 150, // Set the desired height here
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF7928CA), Color(0xFFFF0080)],
                stops: [0.0, 1.0],
                transform: GradientRotation(310 * 3.14 / 180),
              ),
            ),
            child: DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(token: AuthService.getToken()),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null, // If profile image URL is provided, show the image
                      child: profileImageUrl.isEmpty
                          ? Text(
                              initials,
                              style: TextStyle(color: Colors.white, fontSize: 24),
                            ) // If no profile image URL, show the initials
                          : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$investorId | ${groupNames.join(', ')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
