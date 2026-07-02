import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:EduPlex/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

class EduplexPaymentPage extends StatefulWidget {
  final Map<String, dynamic>? course;

  const EduplexPaymentPage({super.key, this.course});

  @override
  State<EduplexPaymentPage> createState() => _EduplexPaymentPageState();
}

class _EduplexPaymentPageState extends State<EduplexPaymentPage>
    with SingleTickerProviderStateMixin {
  static const String baseUrl =
      'https://affection-reborn-cringe.ngrok-free.dev';

  Uint8List? qrBytes;
  String? md5;

  bool loading = true;
  bool isPaid = false;
  bool _isSavingOrSharing = false;

  Timer? timer;
  late AnimationController _controller;

  double get courseAmount {
    final price = widget.course?["price"];
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    generateQR();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _decodeJsonResponse(http.Response res) async {
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    final contentType = res.headers["content-type"] ?? "";

    if (!contentType.contains("application/json")) {
      return null;
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ================= GENERATE QR =================
  Future<void> generateQR() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        print("NO TOKEN FOUND");
        setState(() => loading = false);
        return;
      }

      final payload = {
        "course_id": widget.course?["id"],
        "amount": courseAmount,
        "currency": "USD",
        "billNumber": widget.course?["title"] ?? "Eduplex",
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      final data = await _decodeJsonResponse(res);

      if (data == null) {
        setState(() => loading = false);
        return;
      }

      if (data["success"] == true) {
        md5 = data["data"]["md5Hash"];

        final qrImage = data["data"]["qrCodeImage"];
        final base64Part = qrImage.split(',').last;

        qrBytes = base64Decode(base64Part);

        startChecking();
      } else {
        print("GENERATE FAILED: ${data["message"]}");
      }

      setState(() => loading = false);
    } catch (e) {
      print("GENERATE ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ================= CHECK PAYMENT =================
  void startChecking() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkPayment(),
    );
  }

  Future<void> checkPayment() async {
    try {
      if (md5 == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        print("NO TOKEN FOUND");
        timer?.cancel();
        return;
      }

      final res = await http.post(
        Uri.parse('$baseUrl/api/check'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "md5": md5,
          "course_id": widget.course?["id"],
        }),
      );

      final data = await _decodeJsonResponse(res);

      if (data == null) return;

      if (data["success"] == true && data["data"]?["paid"] == true) {
        timer?.cancel();

        setState(() {
          isPaid = true;
        });

        print("PAYMENT SUCCESS");
      }
    } catch (e) {
      print("CHECK ERROR: $e");
   }
  }

  // ================= SAVE QR CODE =================
  Future<void> _saveQRCode() async {
    if (qrBytes == null) return;

    setState(() => _isSavingOrSharing = true);

    try {
      final tempDir = await getTemporaryDirectory();

      final file = File(
        '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(qrBytes!);

      await Gal.putImage(file.path);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ QR Code saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingOrSharing = false);
      }
    }
  }

  // ================= SHARE QR CODE =================
  Future<void> _shareQRCode() async {
    if (qrBytes == null) return;
    
    setState(() => _isSavingOrSharing = true);
    try {
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'qr_code_${widget.course?["id"]}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(qrBytes!);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this QR code for ${widget.course?["title"] ?? "Eduplex"}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ QR code shared!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingOrSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isPaid ? _successUI() : _paymentUI();
  }

  Widget _paymentUI() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icon/logologin.png",
                  height: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Eduplex Payment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            if (loading)
              const CircularProgressIndicator()
            else if (qrBytes != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/icon/logologin.png",
                      height: 60,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Eduplex",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.course?["title"] ?? "Course",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "\$${courseAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "E-Learning App, Pay once learn everywhere.\nIgnite Your Learning Journey",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 20),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.memory(
                          qrBytes!,
                          height: 220,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (_isSavingOrSharing)
                      const SizedBox(
                        height: 40,
                        child: CircularProgressIndicator(),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveQRCode,
                            icon: const Icon(Icons.download),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _shareQRCode,
                            icon: const Icon(Icons.save_alt),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              )
            else
              const Text(
                "QR generation failed",
                style: TextStyle(color: Colors.red),
              ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel Payment",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _successUI() {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icon/logologin.png",
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Eduplex Payment",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Thank you!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Transaction Detail",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                "Transaction ID",
                md5 != null && md5!.length >= 10
                    ? md5!.substring(0, 10)
                    : "N/A",
              ),
              _detailRow(
                "Date",
                "${now.hour}:${now.minute} | ${now.day}/${now.month}/${now.year}",
              ),
              _detailRow("Type of transaction", "ABA BANK"),
              _detailRow(
                "Nominal",
                "\$${courseAmount.toStringAsFixed(2)}",
              ),
              _detailRow(
                "Bill Number",
                widget.course?["id"]?.toString() ?? "Edu-001",
              ),
              _detailRow("Status", "success", isSuccess: true),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.courseDetail,
                      arguments: widget.course,
                    );
                  },
                  child: const Text("Learn Now"),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
      String title,
      String value, {
        bool isSuccess = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          isSuccess
              ? Row(
            children: [
              const Icon(
                Icons.check,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.green),
              ),
            ],
          )
              : Text(value),
        ],
      ),
    );
  }
}