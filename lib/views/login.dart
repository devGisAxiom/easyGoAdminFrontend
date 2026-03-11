import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Add this function to check if running on web
bool get isWeb {
  return identical(0, 0.0);
}

// Helper function to check if token exists
Future<bool> checkAndRefreshToken() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ Token not found in SharedPreferences");
      return false;
    }

    print("✅ Token found: ${token.substring(0, min(20, token.length))}...");
    return true;
  } catch (e) {
    print("Error checking token: $e");
    return false;
  }
}

// Enhanced HTTP client with Auth and CORS handling
Future<http.Response> httpPostWithAuth(
  String url,
  Map<String, dynamic> data, {
  Duration timeout = const Duration(seconds: 30),
  bool includeAuth = true,
}) async {
  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // Add Authorization header if needed
  if (includeAuth) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      print("🔑 Adding bearer token to request");
    } else {
      print("⚠️ No token available for auth request");
    }
  }

  // For web, add additional headers to handle CORS
  if (isWeb) {
    headers["Access-Control-Allow-Origin"] = "*";
    headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS";
    headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization";
  }

  print("🌐 Sending POST request to: $url");
  print("📤 Request headers: $headers");
  print("📤 Request body: $data");

  try {
    final response = await http
        .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
        .timeout(timeout);

    print("📥 Response status: ${response.statusCode}");
    print(
      "📥 Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}",
    );

    // Check for authentication errors
    if (response.statusCode == 401) {
      print("🔒 Unauthorized - Token might be expired or invalid");
      // You could trigger token refresh or logout here
    }

    return response;
  } catch (e) {
    print("❌ HTTP request error: $e");
    // For web, try alternative approach if regular HTTP fails
    if (isWeb) {
      return await _httpPostWebFallback(
        url,
        data,
        headers: headers,
        timeout: timeout,
      );
    }
    rethrow;
  }
}

// Fallback method for web
Future<http.Response> _httpPostWebFallback(
  String url,
  Map<String, dynamic> data, {
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 30),
}) async {
  try {
    final request = http.Request('POST', Uri.parse(url));

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    request.body = jsonEncode(data);

    print("🌐 Using web fallback for: $url");
    final streamedResponse = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);

    print("🌐 Web fallback response status: ${response.statusCode}");

    return response;
  } catch (e) {
    print("❌ Web fallback error: $e");
    throw Exception('Web request failed: $e');
  }
}

// Legacy function for non-auth requests
Future<http.Response> httpPostWithCors(
  String url,
  Map<String, dynamic> data, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  return await httpPostWithAuth(
    url,
    data,
    timeout: timeout,
    includeAuth: false,
  );
}

// API Functions

void forgotpassword(
  BuildContext context,
  String email,
  VoidCallback onStart,
  VoidCallback onFinish,
) async {
  onStart();

  var data = {"email": email, "u_role": "admin"};
  var url = "$forgotPasswordAPI";

  print('url ::::::: $url');

  try {
    var response = await httpPostWithCors(url, data);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? "OTP sent successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
        _showOtpDialog(context, email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request timeout"),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Network Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    onFinish();
  }
}

void verifyOtp(
  BuildContext context,
  String email,
  String otp,
  VoidCallback onStart,
  VoidCallback onFinish,
) async {
  onStart();

  var data = {"email": email, "otp": otp};
  var url = "$verifyOtpAPI";

  try {
    var response = await httpPostWithCors(url, data);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? "OTP Verified"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
        _showResetPasswordDialog(context, email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? "OTP verification failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server Error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request timeout"),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Network Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    onFinish();
  }
}

void resetPassword(
  BuildContext context,
  String email,
  String password,
  String pagename,
  VoidCallback onStart,
  VoidCallback onFinish,
) async {
  onStart();

  var data = {"email": email, "password": password};
  var url = changePasswordAPI;

  try {
    var response = await httpPostWithCors(url, data);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonData['message'] ?? "Password changed successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
        Navigations.pushAndRemoveUntil(const SignInPage(), context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? "Password change failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server Error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request timeout"),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Network Error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    onFinish();
  }
}

void loginUser(
  BuildContext context,
  String emailorpassword,
  String password,
  bool keeplogin,
  VoidCallback onStart,
  VoidCallback onFinish,
) async {
  onStart();

  try {
    var data = {
      "emailorphone_number": emailorpassword,
      "password": password,
      "role": "admin",
    };

    print("====================================");
    print("🚀 Login API Request");
    print("====================================");
    print("Login API URL: $loginAPI");
    print("Login request data: $data");

    var response = await httpPostWithCors(loginAPI, data);

    // Print full response for debugging
    print("====================================");
    print("📨 Login API Response");
    print("====================================");
    print("Response status code: ${response.statusCode}");
    print("Full response body:");
    print(response.body);
    print("====================================");

    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (jsonData['result'] == true) {
        var user = jsonData['user'];

        // CRITICAL FIX: Token is inside user object, not at root
        String? token =
            user['token'] ??
            jsonData['token'] ??
            jsonData['access_token'] ??
            jsonData['auth_token'];

        print("✅ Login successful!");
        print("📋 User data: $user");
        print(
          "🔐 Token found in user object: ${user['token'] != null ? 'Yes' : 'No'}",
        );

        if (token != null) {
          print(
            "✅ Token extracted: ${token.substring(0, min(20, token.length))}...",
          );
          print("Token full length: ${token.length} characters");
        } else {
          print("❌ ERROR: Token not found anywhere in response!");
          print("User object keys: ${user.keys}");
          print("Root object keys: ${jsonData.keys}");
        }

        // Store data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        print("💾 Saving data to SharedPreferences...");

        // Store user details
        await prefs.setString("user_id", user['id']?.toString() ?? "");
        await prefs.setString("user_name", user['name']?.toString() ?? "");
        await prefs.setString("user_email", user['email']?.toString() ?? "");
        await prefs.setString("user_role", user['role']?.toString() ?? "");
        await prefs.setBool("isloggedin", true);
        await prefs.setBool("keeplogin", keeplogin);

        // CRITICAL: Store the token if it exists
        if (token != null && token.isNotEmpty) {
          await prefs.setString("token", token);
          print("✅ Token saved to SharedPreferences");

          // Verify token was saved
          String? savedToken = prefs.getString("token");
          if (savedToken != null && savedToken.isNotEmpty) {
            print("✅ Token verified from SharedPreferences");
            print(
              "Saved token preview: ${savedToken.substring(0, min(20, savedToken.length))}...",
            );
            print("Saved token length: ${savedToken.length}");

            // Print all stored values for debugging
            print("📋 All stored values:");
            print("user_id: ${prefs.getString("user_id")}");
            print("user_name: ${prefs.getString("user_name")}");
            print("user_email: ${prefs.getString("user_email")}");
            print("user_role: ${prefs.getString("user_role")}");
            print("isloggedin: ${prefs.getBool("isloggedin")}");
            print("keeplogin: ${prefs.getBool("keeplogin")}");
          } else {
            print("❌ ERROR: Token not saved to SharedPreferences!");
          }
        } else {
          print("❌ CRITICAL: No token to save!");
        }

        // Test token retrieval immediately
        print("🔍 Testing token retrieval...");
        bool hasToken = await checkAndRefreshToken();
        print("Token check result: ${hasToken ? '✅ Success' : '❌ Failed'}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? 'Login successful'),
            backgroundColor: Colors.green,
          ),
        );

        print("🔄 Navigating to HomeScreen...");
        Navigations.pushAndRemoveUntil(const HomeScreen(), context);
      } else {
        print("❌ Login failed: ${jsonData['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print("❌ Server error: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on TimeoutException {
    print("⏰ Login timeout");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request timeout - Please try again'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    print("❌ Login error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    print("Stack trace: ${e.toString()}");
  } finally {
    onFinish();
  }
}

// OTP Input Dialog
void _showOtpDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => OtpInputDialog(email: email),
  );
}

// Reset Password Dialog
void _showResetPasswordDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ResetPasswordDialog(email: email),
  );
}

// Email Input Dialog
class EmailInputDialog extends StatefulWidget {
  final Function(String) onEmailSubmitted;

  const EmailInputDialog({super.key, required this.onEmailSubmitted});

  @override
  State<EmailInputDialog> createState() => _EmailInputDialogState();
}

class _EmailInputDialogState extends State<EmailInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _submitEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      widget.onEmailSubmitted(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forgot Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive OTP', style: mediumblack),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'admin@example.com',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitEmail,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Send OTP'),
        ),
      ],
    );
  }
}

// OTP Input Dialog
class OtpInputDialog extends StatefulWidget {
  final String email;

  const OtpInputDialog({super.key, required this.email});

  @override
  State<OtpInputDialog> createState() => _OtpInputDialogState();
}

class _OtpInputDialogState extends State<OtpInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      verifyOtp(
        context,
        widget.email,
        _otpController.text.trim(),
        () => setState(() {
          _isLoading = true;
        }),
        () => setState(() {
          _isLoading = false;
        }),
      );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      setState(() {
        _isLoading = true;
      });
      forgotpassword(
        context,
        widget.email,
        () => setState(() {
          _isLoading = true;
        }),
        () => setState(() {
          _isLoading = false;
        }),
      );
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify OTP'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit OTP sent to ${widget.email}',
              style: mediumblack,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                hintText: 'Enter 6-digit OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter OTP';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'OTP must contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive OTP?", style: mediumblack),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? 'Resend OTP' : 'Resend in $_resendTimer s',
                    style: colortextmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Verify OTP'),
        ),
      ],
    );
  }
}

// Reset Password Dialog
class ResetPasswordDialog extends StatefulWidget {
  final String email;

  const ResetPasswordDialog({super.key, required this.email});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      resetPassword(
        context,
        widget.email,
        _passwordController.text.trim(),
        "loginpage",
        () => setState(() {
          _isLoading = true;
        }),
        () => setState(() {
          _isLoading = false;
        }),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create new password for ${widget.email}', style: mediumblack),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter new password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your new password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Reset Password'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Main SignIn Page
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _onStartLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _onFinishLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      loginUser(
        context,
        _emailController.text,
        _passwordController.text,
        _rememberMe,
        _onStartLoading,
        _onFinishLoading,
      );
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder:
          (context) => EmailInputDialog(
            onEmailSubmitted: (email) {
              forgotpassword(context, email, _onStartLoading, _onFinishLoading);
            },
          ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  void _checkExistingToken() async {
    print("🔍 Checking for existing token...");
    bool hasToken = await checkAndRefreshToken();
    if (hasToken) {
      print("✅ Token found! User might be already logged in.");
    } else {
      print("❌ No token found. User needs to login.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back',
                        style: intercaps,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your admin account',
                        style: mediumblack,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          'admin@example.com',
                          Icons.email_outlined,
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill out this field.';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Password Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          '••••••••',
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill out this field.';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged:
                                    _isLoading
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                              ),
                              const SizedBox(width: 4),
                              Text('Remember me', style: smalltextgrey),
                            ],
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _forgotPassword,
                            child: Text(
                              'Forgot password?',
                              style: colortextmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sign In Button
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text('Sign in', style: normalwhite),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Helper function to clear token (for logout)
Future<void> clearAuthData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("token");
  await prefs.setBool("isloggedin", false);
  print("🗑️ Auth data cleared");
}

// Function to manually check token in console
void debugTokenStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");
  final bool isLoggedIn = prefs.getBool("isloggedin") ?? false;

  print("🔍 DEBUG Token Status:");
  print("Is logged in: $isLoggedIn");
  print("Token exists: ${token != null}");
  print("Token length: ${token?.length ?? 0}");
  if (token != null) {
    print("Token preview: ${token.substring(0, min(20, token.length))}...");
  }
}
