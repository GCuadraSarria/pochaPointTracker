import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pocha_points_tracker/theme/theme.dart';

class DetailSpectateChart extends StatefulWidget {
  final Map<String, dynamic> gameData;
  const DetailSpectateChart({super.key, required this.gameData});

  @override
  State<DetailSpectateChart> createState() => _DetailSpectateChartState();
}

class _DetailSpectateChartState extends State<DetailSpectateChart> {
  double animationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Espera un frame y luego activa la animación
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          animationProgress = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> totalScore =
        Map<String, dynamic>.from(widget.gameData['totalScore'] ?? {});
    final List<String> players =
        List<String>.from(widget.gameData['players'] ?? []);

    // Calcular el máximo número de rondas
    int maxRonda = 0;
    List<double> allScores = [];
    for (final player in players) {
      final List<dynamic> scores = List<dynamic>.from(totalScore[player] ?? []);
      maxRonda = scores.length > maxRonda ? scores.length : maxRonda;
      allScores.addAll(scores.map((e) => (e as num).toDouble()));
    }
    int numRondas = 0;
    for (final scores in totalScore.values) {
      if (scores is List && scores.length > numRondas) {
        numRondas = scores.length;
      }
    }

    // Calcular el mínimo y máximo de puntos (incluyendo negativos)
    double minY =
        allScores.isEmpty ? 0 : allScores.reduce((a, b) => a < b ? a : b);
    double maxY =
        allScores.isEmpty ? 100 : allScores.reduce((a, b) => a > b ? a : b);

    // Redondear a decenas
    int minYInt = (minY ~/ 10) * 10;
    if (minYInt > minY) minYInt -= 10;
    int maxYInt = ((maxY.ceil() + 9) ~/ 10) * 10;

    // Calcular número de decenas y altura dinámica
    int numDecenas = ((maxYInt - minYInt) ~/ 10);
    const double decenaHeight = 20; // Puedes ajustar este valor
    final double chartHeight = numDecenas * decenaHeight;
    const double minHeight = 200; // Altura mínima opcional

    List<LineChartBarData> lines = [];
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final List<dynamic> scores = List<dynamic>.from(totalScore[player] ?? []);
      final List<double> playerScores = [
        0,
        ...scores.map((e) => (e as num).toDouble())
      ];
      lines.add(
        LineChartBarData(
          spots: List.generate(
            playerScores.length,
            (x) => FlSpot(
              (x).toDouble(),
              playerScores[x],
            ),
          ),
          isCurved: true,
          color: CustomColors.lineColors[i % CustomColors.lineColors.length],
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3,
              color: bar.color ?? Colors.blue,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            ),
          ),
        ),
      );
    }

    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 5000),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: chartHeight > minHeight ? chartHeight : minHeight,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (touchedSpot) =>
                          CustomColors.backgroundColor,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final player = players[spot.barIndex];
                          return LineTooltipItem(
                            '',
                            const TextStyle(),
                            children: [
                              TextSpan(
                                text: '$player: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.whiteColor,
                                  fontSize: 18.0,
                                ),
                              ),
                              TextSpan(
                                text: spot.y.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: CustomColors.whiteColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  minX: 0,
                  maxX: numRondas.toDouble(),
                  minY: minYInt.toDouble(),
                  maxY: maxYInt.toDouble(),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      // Destaca la línea del eje Y en 0
                      if (value == 0) {
                        return const FlLine(
                          color: Color.fromARGB(200, 255, 193, 7),
                          strokeWidth: 1,
                          dashArray: [8, 4],
                        );
                      }
                      return const FlLine(
                        color: Colors.white24,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: lines.map((line) {
                    final progressX = value * numRondas;
                    final originalSpots = line.spots;
                    final visibleSpots = <FlSpot>[];

                    for (int i = 0; i < originalSpots.length; i++) {
                      final spot = originalSpots[i];
                      if (spot.x <= progressX) {
                        visibleSpots.add(spot);
                      } else {
                        if (i > 0) {
                          final prev = originalSpots[i - 1];
                          final t = (progressX - prev.x) / (spot.x - prev.x);
                          final interpolatedY = prev.y + (spot.y - prev.y) * t;
                          visibleSpots.add(FlSpot(progressX, interpolatedY));
                        }
                        break;
                      }
                    }

                    return line.copyWith(spots: visibleSpots);
                  }).toList(),
                  clipData: const FlClipData.all(),
                ),
              ),
            ),
          );
        });
  }
}
