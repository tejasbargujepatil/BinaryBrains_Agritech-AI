import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Bar Chart Widget for displaying data like NPK levels, yield, etc.
class CustomBarChart extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final double height;
  final Color? primaryColor;
  
  const CustomBarChart({
    super.key,
    required this.data,
    this.title,
    this.height = 200,
    this.primaryColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final color = primaryColor ?? AppTheme.primaryGreen;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final barHeight = (item.value / maxValue) * height;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == data.length - 1 ? 0 : 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          item.value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.7),
                                color,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Line Chart Widget for trends and time-series data
class CustomLineChart extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final double height;
  final Color? lineColor;
  
  const CustomLineChart({
    super.key,
    required this.data,
    this.title,
    this.height = 200,
    this.lineColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = lineColor ?? AppTheme.accentGreen;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          SizedBox(
            height: height,
            child: CustomPaint(
              painter: LineChartPainter(
                data: data,
                lineColor: color,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((item) {
              return Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color lineColor;
  
  LineChartPainter({
    required this.data,
    required this.lineColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withOpacity(0.3),
          lineColor.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i].value - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = Colors.white,
      );
    }
    
    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    // Draw fill
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Progress circular indicator with percentage
class CustomCircularProgress extends StatelessWidget {
  final double percentage;
  final String? label;
  final Color? color;
  final double size;
  
  const CustomCircularProgress({
    super.key,
    required this.percentage,
    this.label,
    this.color,
    this.size = 100,
  });
  
  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? AppTheme.primaryGreen;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: AppTheme.veryLightGreen,
              valueColor: AlwaysStoppedAnimation(indicatorColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Linear progress bar with label
class LinearProgressBar extends StatelessWidget {
  final double percentage;
  final String? label;
  final Color? color;
  final double height;
  
  const LinearProgressBar({
    super.key,
    required this.percentage,
    this.label,
    this.color,
    this.height = 8,
  });
  
  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppTheme.primaryGreen;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${percentage.toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.veryLightGreen,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: (percentage / 100) * MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor.withOpacity(0.8), barColor],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// NPK Level Indicator (specialized progress indicator)
class NPKIndicator extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  
  const NPKIndicator({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue) * 100;
    final level = _getLevel(percentage);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: AppTheme.smallRadius,
              ),
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        LinearProgressBar(
          percentage: percentage.clamp(0, 100),
          color: color,
          height: 6,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} / ${maxValue.toStringAsFixed(1)} kg/ha',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  String _getLevel(double percentage) {
    if (percentage >= 75) return 'High';
    if (percentage >= 40) return 'Medium';
    return 'Low';
  }
}

/// Data class for charts
class ChartData {
  final String label;
  final double value;
  
  ChartData({
    required this.label,
    required this.value,
  });
}
