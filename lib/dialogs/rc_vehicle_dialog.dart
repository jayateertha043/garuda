import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pointer_interceptor/pointer_interceptor.dart';

Future<void> showRCVehicleDialog(BuildContext context) {
  final rcController = TextEditingController();
  final tokenController = TextEditingController();
  
  return showDialog(
    context: context,
    builder: (builder) {
      return StatefulBuilder(
        builder: (context, setState) {
          return PointerInterceptor(
            child: AlertDialog(
              title: Row(
                children: [
                  Transform.flip(
                    flipX: true,
                    child: const Text('🦅', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 8),
                  const Text('RC Vehicle Data'),
                ],
              ),
              content: _RCVehicleDialogContent(
                rcController: rcController,
                tokenController: tokenController,
              ),
            ),
          );
        },
      );
    },
  );
}

class _RCVehicleDialogContent extends StatefulWidget {
  final TextEditingController rcController;
  final TextEditingController tokenController;

  const _RCVehicleDialogContent({
    required this.rcController,
    required this.tokenController,
  });

  @override
  State<_RCVehicleDialogContent> createState() => _RCVehicleDialogContentState();
}

class _RCVehicleDialogContentState extends State<_RCVehicleDialogContent> {
  bool isLoading = false;
  Map<String, dynamic>? vehicleData;
  String? errorMessage;
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicleData() async {
    final rcNumber = widget.rcController.text.trim();
    final token = widget.tokenController.text.trim();

    if (rcNumber.isEmpty || token.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both RC Number and Token';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      vehicleData = null;
    });

    try {
      final url = Uri.parse(
        'https://garuda-osint-bot.vercel.app/vehicle?rc_number=$rcNumber&token=$token',
      );
      final response = await http.get(url);

      if (response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0]['status'] == 'completed') {
          setState(() {
            vehicleData = data[0]['result']['extraction_output'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to retrieve vehicle data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'An error occurred. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.rcController,
              decoration: InputDecoration(
                labelText: 'RC Number',
                hintText: 'Enter vehicle RC number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.tokenController,
              decoration: InputDecoration(
                labelText: 'Token',
                hintText: 'Enter your token',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: isLoading ? null : _fetchVehicleData,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Close'),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            if (vehicleData != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Vehicle Information:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                    scrollbars: true,
                  ),
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    interactive: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        interactive: true,
                        trackVisibility: true,
                        notificationPredicate: (notification) => notification.depth == 0,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Field', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: vehicleData!.entries.map((entry) {
                              return DataRow(cells: [
                                DataCell(SelectableText(_formatFieldName(entry.key))),
                                DataCell(SelectableText(entry.value?.toString() ?? 'N/A')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
