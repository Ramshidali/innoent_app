import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/ApiConfig.dart';
import '../authentication/AuthService.dart';

class ProfilePage extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final Future<String?> token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await widget.token ?? '';
      final response = await http.get(
        Uri.parse('${ProfilePage.baseUrl}auth/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profileData = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity, // Ensures the container takes full width
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7928CA), Color(0xFFFF0080)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity, // Ensures the circle takes full width
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.25, // Adjust this value as needed
                                backgroundImage: _profileData!['profile_image'] != null
                                    ? NetworkImage(_profileData!['profile_image'])
                                    : null,
                                child: _profileData!['profile_image'] == null
                                    ? Text(
                                        _profileData!['initial'] ?? '',
                                        style: TextStyle(color: Colors.white, fontSize: 40),
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${_profileData!['first_name']} ${_profileData!['last_name']}',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${_profileData!['group_names'].join(', ') ?? []}', // Assuming 'group_names' key is available
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileInfo('EMAIL', _profileData!['email']),
                            _buildProfileInfo('PHONE', _profileData!['phone']),
                            _buildProfileInfo('CITY, STATE', '${_profileData!['state']}, ${_profileData!['country']}'),
                            _buildProfileInfo('COUNTRY', _profileData!['country']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
