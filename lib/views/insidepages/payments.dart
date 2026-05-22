// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentList extends StatefulWidget {
  const PaymentList({super.key});

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  bool _loading = false;
  bool _downloading = false;
  List<dynamic> _rows = [];
  String? _error;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String _fmt(DateTime? d) =>
      d == null ? '' : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime? d) =>
      d == null ? 'Select' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await _getToken();
      final dio = Dio();
      final resp = await dio.post(
        PaymentReportAPI,
        data: {
          if (_fromDate != null) 'from_date': _fmt(_fromDate),
          if (_toDate != null) 'to_date': _fmt(_toDate),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = resp.data;
      if (body['result'] == true) {
        setState(() => _rows = body['list'] ?? []);
      } else {
        setState(() => _error = body['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _downloadExcel() async {
    setState(() => _downloading = true);
    try {
      final token = await _getToken();
      final dio = Dio();
      final resp = await dio.post(
        PaymentReportExcelAPI,
        data: {
          if (_fromDate != null) 'from_date': _fmt(_fromDate),
          if (_toDate != null) 'to_date': _fmt(_toDate),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );
      final bytes = Uint8List.fromList(resp.data as List<int>);
      final blob = html.Blob(
        [bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      final url = html.Url.createObjectUrlFromBlob(blob);
      final from = _fromDate != null ? _fmt(_fromDate) : 'all';
      final to   = _toDate   != null ? _fmt(_toDate)   : 'all';
      html.AnchorElement(href: url)
        ..setAttribute('download', 'EasyGo_Report_${from}_to_$to.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _downloading = false);
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() { if (isFrom) { _fromDate = picked; } else { _toDate = picked; } });
  }

  void _clearFilter() {
    setState(() { _fromDate = null; _toDate = null; });
    _fetchData();
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    Color bg; Color fg;
    if (s == 'paid') { bg = const Color(0xFFDCFCE7); fg = const Color(0xFF16A34A); }
    else if (s == 'pending') { bg = const Color(0xFFFEF9C3); fg = const Color(0xFFD97706); }
    else { bg = const Color(0xFFFFE4E6); fg = const Color(0xFFDC2626); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _bookingStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFE0F2FE); Color fg = const Color(0xFF0369A1);
    if (s == 'completed') { bg = const Color(0xFFDCFCE7); fg = const Color(0xFF16A34A); }
    else if (s == 'cancelled') { bg = const Color(0xFFFFE4E6); fg = const Color(0xFFDC2626); }
    else if (s == 'onride') { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF15803D); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  String _cell(dynamic v) => (v == null || v.toString().isEmpty) ? '—' : v.toString();

  Widget _summaryCards() {
    if (_rows.isEmpty) return const SizedBox.shrink();
    double totalRent = 0, totalFine = 0, grandTotal = 0; int paidCount = 0;
    for (final r in _rows) {
      totalRent  += double.tryParse(r['b_rent_amount']?.toString() ?? '0') ?? 0;
      totalFine  += double.tryParse(r['b_fine_amount']?.toString()  ?? '0') ?? 0;
      grandTotal += double.tryParse(r['b_total_amount']?.toString() ?? '0') ?? 0;
      if ((r['b_payment_status'] ?? '').toString().toLowerCase() == 'paid') paidCount++;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: [
          _card('Total Bookings', '${_rows.length}',     Icons.receipt_long,          const Color(0xFF2563EB)),
          _card('Paid',           '$paidCount',           Icons.check_circle_outline,  const Color(0xFF16A34A)),
          _card('Total Rent',     '₹${totalRent.toStringAsFixed(2)}',   Icons.currency_rupee, primaryColor),
          _card('Total Fine',     '₹${totalFine.toStringAsFixed(2)}',   Icons.warning_amber,  const Color(0xFFD97706)),
          _card('Grand Total',    '₹${grandTotal.toStringAsFixed(2)}',  Icons.account_balance_wallet, const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        )),
      ]),
    );
  }

  Widget _datePicker(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(_fmtDisplay(value), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTable() {
    const cols = [
      'Booking ID', 'Booking Date', 'Customer', 'Mobile', 'Vehicle No.',
      'Bike', 'Duration', 'Pickup Date', 'Drop Date',
      'Rent (₹)', 'GST (₹)', 'Deposit (₹)', 'Fine (₹)', 'Total (₹)',
      'Payment', 'Status',
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF374151)),
            dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            columnSpacing: 20,
            horizontalMargin: 16,
            columns: cols.map((c) => DataColumn(label: Text(c))).toList(),
            rows: _rows.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final rent = double.tryParse(r['b_rent_amount']?.toString() ?? '0') ?? 0;
              final gst  = rent * 0.05;
              return DataRow(
                color: WidgetStateProperty.resolveWith(
                  (s) => i % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                ),
                cells: [
                  DataCell(Text('#${_cell(r['b_id'])}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(_cell(r['booking_date']))),
                  DataCell(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_cell(r['u_name']), style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(_cell(r['u_email']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ])),
                  DataCell(Text(_cell(r['u_mobile']))),
                  DataCell(Text(_cell(r['vehicle_number']))),
                  DataCell(Text(_cell(r['bike_name']))),
                  DataCell(Text(_cell(r['rent_duration_text']))),
                  DataCell(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_cell(r['b_pickup_date'])),
                    Text(_cell(r['b_picup_time']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ])),
                  DataCell(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_cell(r['b_drop_date'])),
                    Text(_cell(r['b_drop_time']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ])),
                  DataCell(Text('₹${rent.toStringAsFixed(0)}')),
                  DataCell(Text('₹${gst.toStringAsFixed(0)}')),
                  DataCell(Text('₹${_cell(r['rent_deposit'])}')),
                  DataCell(Text('₹${_cell(r['b_fine_amount'])}')),
                  DataCell(Text('₹${_cell(r['b_total_amount'])}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(_statusBadge(_cell(r['b_payment_status']))),
                  DataCell(_bookingStatusBadge(_cell(r['b_status']))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Reports', style: intercaps),
            const SizedBox(height: 4),
            Text('View and export booking payment data',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 20),

            // Filter bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
              ),
              child: Row(children: [
                _datePicker('From Date', _fromDate, () => _pickDate(true)),
                const SizedBox(width: 12),
                _datePicker('To Date', _toDate, () => _pickDate(false)),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.filter_alt, size: 18),
                  label: const Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearFilter,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _rows.isEmpty || _downloading ? null : _downloadExcel,
                  icon: _downloading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Summary cards
            _summaryCards(),

            // Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                        : _rows.isEmpty
                            ? const Center(
                                child: Text('No records found', style: TextStyle(color: Colors.grey)))
                            : _buildTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
