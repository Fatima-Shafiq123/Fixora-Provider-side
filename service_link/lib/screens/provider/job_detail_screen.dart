import 'package:flutter/material.dart';
import 'package:service_link/models/booking_model.dart';
import 'package:service_link/services/database/booking_service.dart';

class JobDetailArguments {
  final BookingModel booking;
  final Map<String, dynamic>? clientData;
  final Map<String, dynamic>? serviceData;

  JobDetailArguments({
    required this.booking,
    this.clientData,
    this.serviceData,
  });
}

class JobDetailScreen extends StatefulWidget {
  final JobDetailArguments args;

  const JobDetailScreen({super.key, required this.args});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final BookingService _bookingService = BookingService();
  bool _isUpdating = false;
  int _activeStep = 0;
  final List<String> _jobStages = const [
    'On the way',
    'Arrived',
    'Working',
    'Completed'
  ];

  Future<void> _updateStatus(BookingStatus status) async {
    if (widget.args.booking.bookingId == null) return;
    setState(() => _isUpdating = true);
    final success = await _bookingService.updateBookingStatus(
        widget.args.booking.bookingId!, status);
    if (!mounted) return;
    setState(() => _isUpdating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Status updated' : 'Failed to update status',
        ),
      ),
    );
    if (success && status == BookingStatus.completed) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildStageChips() {
    return Wrap(
      spacing: 8,
      children: List.generate(_jobStages.length, (index) {
        final isActive = _activeStep >= index;
        return ChoiceChip(
          label: Text(_jobStages[index]),
          selected: isActive,
          onSelected: (value) {
            setState(() => _activeStep = index);
          },
          selectedColor: Colors.green.shade100,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.args.booking;
    final client = widget.args.clientData;
    final service = widget.args.serviceData;
    final isPending = booking.status == BookingStatus.pending;
    final isActive = booking.status == BookingStatus.confirmed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoTile(
              title: service?['title'] ?? 'Service',
              subtitle: client?['fullName'] ?? 'Client',
              trailing: Text(
                'Rs ${booking.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Location',
              subtitle: booking.clientAddress,
              trailingIcon: Icons.map,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map integration coming soon.')),
              ),
            ),
            _InfoTile(
              title: 'Schedule',
              subtitle:
                  '${_bookingService.formatBookingDate(booking.scheduledDate)} • ${booking.scheduledTime}',
              trailingIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              booking.clientNotes?.isNotEmpty == true
                  ? booking.clientNotes!
                  : 'No special instructions',
            ),
            const SizedBox(height: 24),
            if (isActive) ...[
              Text(
                'Job Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildStageChips(),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Chat feature coming soon.')),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Calling ${client?['contactNumber'] ?? 'client'}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPending) ...[
              ElevatedButton(
                onPressed:
                    _isUpdating ? null : () => _updateStatus(BookingStatus.confirmed),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Accept Request'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isUpdating
                    ? null
                    : () => _updateStatus(BookingStatus.cancelled),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Reject Request'),
              ),
            ] else if (isActive) ...[
              ElevatedButton(
                onPressed:
                    _isUpdating ? null : () => _updateStatus(BookingStatus.completed),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Mark Job Complete'),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload job evidence on completion (photos, notes).',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ] else if (booking.status == BookingStatus.completed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Job completed. Payment under review.',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    this.trailingIcon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ??
          (trailingIcon != null
              ? Icon(trailingIcon, color: Theme.of(context).primaryColor)
              : null),
      onTap: onTap,
    );
  }
}

