import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusTimeline extends StatelessWidget {
  final int currentStep;

  const StatusTimeline({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        DummyData.statusSteps.length,
        (index) => _buildTimelineItem(
          index,
          DummyData.statusSteps[index],
          index <= currentStep,
          index == DummyData.statusSteps.length - 1,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(int index, String title, bool isCompleted, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryGreen : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.primaryGreen : AppColors.darkGrey,
                  width: 3,
                ),
                boxShadow: [
                  if (isCompleted)
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primaryGreen : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.primaryGreen : AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                if (isCompleted)
                  Text(
                    'Completed at ${_getCompletionTime(index)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey.withOpacity(0.7),
                    ),
                  )
                else if (index == currentStep + 1)
                  const Text(
                    'In progress...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryOrange,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGrey.withOpacity(0.5),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCompletionTime(int index) {
    final now = DateTime.now();
    final completionTime = now.subtract(Duration(hours: (3 - index) * 2));
    return '${completionTime.day}/${completionTime.month} ${completionTime.hour.toString().padLeft(2, '0')}:${completionTime.minute.toString().padLeft(2, '0')}';
  }
}
