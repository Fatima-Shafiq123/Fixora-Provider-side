import 'package:flutter/material.dart';

class ServiceAvailabilityScreen extends StatefulWidget {
  const ServiceAvailabilityScreen({super.key});

  @override
  State<ServiceAvailabilityScreen> createState() =>
      _ServiceAvailabilityScreenState();
}

class _ServiceAvailabilityScreenState
    extends State<ServiceAvailabilityScreen> {
  final Map<String, bool> _dayAvailability = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  RangeValues _workingHours = const RangeValues(9, 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _dayAvailability.keys.map((day) {
                final enabled = _dayAvailability[day]!;
                return FilterChip(
                  label: Text(day),
                  selected: enabled,
                  onSelected: (value) {
                    setState(() => _dayAvailability[day] = value);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Time Slots',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RangeSlider(
              values: _workingHours,
              min: 0,
              max: 24,
              divisions: 24,
              labels: RangeLabels(
                '${_workingHours.start.round()}:00',
                '${_workingHours.end.round()}:00',
              ),
              onChanged: (values) {
                setState(() => _workingHours = values);
              },
            ),
            Text(
              'Active hours ${_workingHours.start.round()}:00 - ${_workingHours.end.round()}:00',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Text(
              'Special Dates Off',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_busy),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Add special off days or vacations'),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calendar picker coming soon.'),
                        ),
                      );
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Availability preferences saved.'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

