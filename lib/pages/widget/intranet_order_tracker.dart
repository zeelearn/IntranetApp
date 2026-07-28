import 'package:flutter/material.dart';
import 'package:order_tracker_zen/order_tracker_zen.dart';

class IntranetOrderTrackerZen extends StatelessWidget {
  final List<TrackerData> tracker_data;
  final bool isShrinked;
  final Color? success_color;
  final Color? background_color;
  final Color? text_primary_color;
  final Color? text_secondary_color;

  const IntranetOrderTrackerZen({
    super.key,
    required this.tracker_data,
    this.isShrinked = false,
    this.success_color,
    this.background_color,
    this.text_primary_color,
    this.text_secondary_color,
  });

  @override
  Widget build(BuildContext context) {
    if (tracker_data.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tracker_data.length, (index) {
        final data = tracker_data[index];
        final isLast = index == tracker_data.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Dot & Line
              Column(
                children: [
                  // Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: success_color ?? Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  // Line (if not last item)
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: success_color ?? Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              // Right Column: Title, Date, Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Date Row/Column
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: isShrinked ? 0 : 8,
                        top: 0,
                      ),
                      child: isShrinked
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title,
                                  style: TextStyle(
                                    color: text_primary_color ?? Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data.date,
                                  style: TextStyle(
                                    color: text_secondary_color ?? Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  data.title,
                                  style: TextStyle(
                                    color: text_primary_color ?? Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  data.date,
                                  style: TextStyle(
                                    color: text_secondary_color ?? Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // Details (if not shrinked)
                    if (!isShrinked)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.tracker_details.map((detail) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.title,
                                  style: TextStyle(
                                    color: text_primary_color ?? Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (detail.datetime.isNotEmpty)
                                  Text(
                                    detail.datetime,
                                    style: TextStyle(
                                      color: text_secondary_color ?? Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
