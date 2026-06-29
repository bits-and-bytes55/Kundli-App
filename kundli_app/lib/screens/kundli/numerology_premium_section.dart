import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NumerologyPremiumSection extends StatelessWidget {
  final Map<String, dynamic> personalDetails;
  final String name;
  final String dob;
  final Map<String, dynamic>? deathData;

  const NumerologyPremiumSection({
    Key? key,
    required this.personalDetails,
    required this.name,
    required this.dob,
    this.deathData,
  }) : super(key: key);

  int _reduceToSingleDigit(int n) {
    if (n == 0) return 0;
    int sum = n;
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  int _monthFromName(String text) {
    final l = text.toLowerCase();
    if (l.contains('jan')) return 1;
    if (l.contains('feb')) return 2;
    if (l.contains('mar')) return 3;
    if (l.contains('apr')) return 4;
    if (l.contains('may')) return 5;
    if (l.contains('jun')) return 6;
    if (l.contains('jul')) return 7;
    if (l.contains('aug')) return 8;
    if (l.contains('sep')) return 9;
    if (l.contains('oct')) return 10;
    if (l.contains('nov')) return 11;
    if (l.contains('dec')) return 12;
    return 1;
  }



  @override
  Widget build(BuildContext context) {
    String rawDob = dob.isEmpty ? '01/01/2000' : dob;
    
    // Robust parsing
    int day = 1;
    int month = 1;
    int year = 2000;
    
    try {
      final RegExp numRegExp = RegExp(r'\d+');
      final matches = numRegExp.allMatches(rawDob).map((m) => int.parse(m.group(0)!)).toList();
      
      if (matches.length >= 3) {
        if (matches[0] > 1000) {
          year = matches[0];
          month = matches[1];
          day = matches[2];
        } else {
          day = matches[0];
          month = matches[1];
          year = matches[2];
        }
      } else if (matches.length == 2) {
        if (matches[0] > 1000) {
          year = matches[0];
          day = matches[1];
        } else {
          day = matches[0];
          year = matches[1];
        }
        month = _monthFromName(rawDob);
      }
    } catch (e) {
      // Fallback stays at 1/1/2000
    }
    
    // Mulank
    final int mulank = _reduceToSingleDigit(day);
    
    // Bhagyank
    final digits = '$day$month$year'.split('').map(int.parse);
    final sum = digits.reduce((a, b) => a + b);
    final int bhagyank = _reduceToSingleDigit(sum);
    
    // Kua Number
    String gender = personalDetails['gender']?.toString().toLowerCase() ?? 'male';
    final int yearSum = year.toString().split('').map(int.parse).reduce((a, b) => a + b);
    final int yearRoot = _reduceToSingleDigit(yearSum);
    int result;
    if (gender == 'male') {
      result = 11 - yearRoot;
    } else {
      result = 4 + yearRoot;
    }
    int kuaNumber = _reduceToSingleDigit(result);
    if (kuaNumber == 5) {
      if (gender == 'male') {
        kuaNumber = 2;
      } else {
        kuaNumber = 8;
      }
    }

    
    // Name Numerology (Chaldean)
    final Map<String, int> chaldeanMap = {
      'A':1,'I':1,'J':1,'Q':1,'Y':1,
      'B':2,'K':2,'R':2,
      'C':3,'G':3,'L':3,'S':3,
      'D':4,'M':4,'T':4,
      'E':5,'H':5,'N':5,'X':5,
      'U':6,'V':6,'W':6,
      'O':7,'Z':7,
      'F':8,'P':8
    };

    String cleanName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z\s]'), '');
    List<String> nameParts = cleanName.split(' ').where((s) => s.isNotEmpty).toList();
    
    int firstNameTotal = 0;
    if (nameParts.isNotEmpty) {
      for (int i = 0; i < nameParts[0].length; i++) {
        firstNameTotal += chaldeanMap[nameParts[0][i]] ?? 0;
      }
    }
    
    int secondNameTotal = 0;
    if (nameParts.length > 1) {
      for (int i = 0; i < nameParts[1].length; i++) {
        secondNameTotal += chaldeanMap[nameParts[1][i]] ?? 0;
      }
    }
    
    int fullNameTotal = 0;
    for (int i = 0; i < cleanName.replaceAll(' ', '').length; i++) {
      fullNameTotal += chaldeanMap[cleanName.replaceAll(' ', '')[i]] ?? 0;
    }
    int reducedFullName = _reduceToSingleDigit(fullNameTotal);

    final Map<String, String> engToHindi = {
      'A': 'अ / आ', 'B': 'ब / भ', 'C': 'च / छ', 'D': 'द / ड', 'E': 'ए',
      'F': 'फ', 'G': 'ग / घ', 'H': 'ह', 'I': 'इ / ई', 'J': 'ज / झ',
      'K': 'क / ख', 'L': 'ल', 'M': 'म', 'N': 'न', 'O': 'ओ',
      'P': 'प', 'Q': 'क़', 'R': 'र', 'S': 'स / श', 'T': 'त / ट',
      'U': 'उ / ऊ', 'V': 'व', 'W': 'व', 'X': 'क्स', 'Y': 'य', 'Z': 'ज़'
    };
    String firstLetter = cleanName.isNotEmpty ? cleanName[0] : '';
    int firstLetterNum = chaldeanMap[firstLetter] ?? 0;
    String hindiLetter = engToHindi[firstLetter] ?? '';

    // Death Numerology
    int? deathMulank;
    int? deathBhagyank;
    int? dDay, dMonth, dYear;

    if (deathData != null && deathData!['date'] != null && deathData!['date'].toString().isNotEmpty) {
      String rawDeathDob = deathData!['date'].toString();
      try {
        final RegExp numRegExp = RegExp(r'\d+');
        final matches = numRegExp.allMatches(rawDeathDob).map((m) => int.parse(m.group(0)!)).toList();
        
        if (matches.length >= 3) {
          if (matches[0] > 1000) {
            dYear = matches[0];
            dMonth = matches[1];
            dDay = matches[2];
          } else {
            dDay = matches[0];
            dMonth = matches[1];
            dYear = matches[2];
          }
        }
      } catch (e) {}

      if (dDay != null && dMonth != null && dYear != null) {
        deathMulank = _reduceToSingleDigit(dDay);
        final dDigits = '$dDay$dMonth$dYear'.split('').map(int.parse);
        final dSum = dDigits.reduce((a, b) => a + b);
        deathBhagyank = _reduceToSingleDigit(dSum);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGoldHeader('DIVINE CORE NUMBERS'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildCoreNumberBox('Moolank', mulank.toString(), const Color(0xFF6B1B32))),
            const SizedBox(width: 12),
            Expanded(child: _buildCoreNumberBox('Bhagyank', bhagyank.toString(), const Color(0xFFC4A25C))),
            const SizedBox(width: 12),
            Expanded(child: _buildCoreNumberBox('Kulank', kuaNumber.toString(), const Color(0xFF3F4274))),
          ],
        ),
        if (deathMulank != null && deathBhagyank != null) ...[
          const SizedBox(height: 16),
          _buildGoldHeader('Death Numerology'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildCoreNumberBox('Death Mulank', deathMulank.toString(), Colors.blueGrey.shade800)),
              const SizedBox(width: 12),
              Expanded(child: _buildCoreNumberBox('Death Bhagyank', deathBhagyank.toString(), Colors.grey.shade800)),
              const SizedBox(width: 12),
              Expanded(child: const SizedBox()), // Empty slot for alignment
            ],
          ),
        ],
        const SizedBox(height: 16),
        Column(
          children: [
            _buildSimpleRow('First Letter', '$firstLetter → $firstLetterNum'),
            _buildNameRow('First Name Total', firstNameTotal, _reduceToSingleDigit(firstNameTotal)),
            if (nameParts.length > 1)
              _buildSimpleRow('Second Name Total', '$secondNameTotal → ${_reduceToSingleDigit(secondNameTotal)}'),
            _buildNameRow('Full Name Total', fullNameTotal, reducedFullName, isLast: true),
          ],
        ),
        const SizedBox(height: 16),
        _buildHeader('Lo Shu Grid', Icons.grid_3x3_rounded),
        const SizedBox(height: 12),
        if (deathMulank != null && deathBhagyank != null && dDay != null && dMonth != null && dYear != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Birth Grid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildLoShuGrid(day, month, year, mulank, bhagyank, kuaNumber),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    const Text('Death Grid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildLoShuGrid(dDay, dMonth, dYear, deathMulank, deathBhagyank, 0),
                  ],
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoShuGrid(day, month, year, mulank, bhagyank, kuaNumber),
            ],
          ),
      ],
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoldHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: Color(0xFFC4A25C),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildCoreNumberBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE3D5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBox(String label, String value, Color color, {double? width}) {
    return Container(
      width: width ?? 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value, {Color? valueColor, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.orange.shade200),
      ],
    );
  }

  Widget _buildNameRow(String label, int total, int reduced, {bool isLast = false}) {
    bool isBad = (reduced == 4 || reduced == 7);
    String symbol = isBad ? ' ❌' : ' ✔️';
    Color color = isBad ? Colors.red.shade700 : Colors.green.shade700;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$total → $reduced', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87)),
                      TextSpan(text: symbol, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 0.5, color: Colors.orange.shade200),
      ],
    );
  }

  Widget _buildLoShuGrid(int d, int m, int y, int mulank, int bhagyank, int k) {
    Map<int, int> counts = {};
    for (int i = 1; i <= 9; i++) counts[i] = 0;
    
    String cleanDob = '$d$m$y';
    
    // Add DOB digits
    for (int i = 0; i < cleanDob.length; i++) {
      int? val = int.tryParse(cleanDob[i]);
      if (val != null && val >= 1 && val <= 9) {
        counts[val] = counts[val]! + 1;
      }
    }
    
    // Add Core numbers
    for (int i = 0; i < '$mulank$bhagyank'.length; i++) {
      int? val = int.tryParse('$mulank$bhagyank'[i]);
      if (val != null && val >= 1 && val <= 9) {
        counts[val] = counts[val]! + 1;
      }
    }

    Widget grid = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: [4, 9, 2, 3, 5, 7, 8, 1, 6].map((num) {
        final count = counts[num] ?? 0;
        final isPresent = count > 0;
        
        String displayStr;
        if (isPresent) {
          displayStr = List.filled(count, '$num').join('');
        } else if (num == k) {
          displayStr = '$num';
        } else {
          displayStr = '$num';
        }

        final color = isPresent 
            ? (num == k ? const Color(0xFFFFF176) : const Color(0xFF6B1B32).withOpacity(0.8)) 
            : (num == k ? const Color(0xFFFFF9C4) : Colors.white);
            
        final textColor = isPresent
            ? (num == k ? Colors.black87 : Colors.white)
            : Colors.black87;

        return Container(
          color: color,
          child: Center(
            child: Text(
              displayStr,
              style: TextStyle(
                fontSize: isPresent ? (displayStr.length > 2 ? 14 : 18) : 20,
                fontWeight: isPresent ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4A25C).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(width: 160, height: 160, child: grid),
      ),
    );
  }
}
