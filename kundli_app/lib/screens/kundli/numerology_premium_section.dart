import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NumerologyPremiumSection extends StatelessWidget {
  final Map<String, dynamic> personalDetails;
  final String name;

  const NumerologyPremiumSection({
    Key? key,
    required this.personalDetails,
    required this.name,
  }) : super(key: key);

  int _reduceToSingleDigit(int number) {
    if (number == 0) return 0;
    int res = number % 9;
    return res == 0 ? 9 : res;
  }

  int _sumDigits(String text) {
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      if (int.tryParse(text[i]) != null) {
        sum += int.parse(text[i]);
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    String dobStr = personalDetails['dob']?.toString() ?? '01/01/2000';
    List<String> parts = dobStr.split(RegExp(r'[/.\-]'));
    
    int day = 1;
    int month = 1;
    int year = 2000;

    if (parts.length >= 3) {
      if (parts[0].length == 4) { // YYYY-MM-DD
        year = int.tryParse(parts[0]) ?? 2000;
        month = int.tryParse(parts[1]) ?? 1;
        day = int.tryParse(parts[2]) ?? 1;
      } else { // DD-MM-YYYY
        day = int.tryParse(parts[0]) ?? 1;
        month = int.tryParse(parts[1]) ?? 1;
        year = int.tryParse(parts[2]) ?? 2000;
      }
    }
    
    // Mulank
    final int mulank = _reduceToSingleDigit(_sumDigits(day.toString()));
    
    // Bhagyank
    final int bhagyank = _reduceToSingleDigit(_sumDigits('$day$month$year'));
    
    // Kua Number (Defaulting Male: 11 - sum)
    final int yearSum = _reduceToSingleDigit(_sumDigits(year.toString()));
    int kuaNumber = _reduceToSingleDigit(11 - yearSum); // Assuming male for now if not available

    
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
    
    String firstLetter = cleanName.isNotEmpty ? cleanName[0] : '';
    int firstLetterNum = chaldeanMap[firstLetter] ?? 0;
    
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
    String hindiLetter = engToHindi[firstLetter] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Advanced Numerology', Icons.numbers_rounded),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildSimpleRow('Mulank (Root Number)', mulank.toString(), valueColor: Colors.amber.shade900),
            _buildSimpleRow('Bhagyank (Destiny Number)', bhagyank.toString(), valueColor: Colors.blue.shade800),
            _buildSimpleRow('Kua Number', kuaNumber.toString(), valueColor: Colors.green.shade800),
            _buildSimpleRow('First Letter', '$firstLetter / $hindiLetter', valueColor: Colors.deepOrange),
            _buildSimpleRow('First Letter Number', firstLetterNum.toString()),
            _buildSimpleRow('First Name (${nameParts.isNotEmpty ? nameParts[0] : ''})', '$firstNameTotal = ${_reduceToSingleDigit(firstNameTotal)}'),
            if (nameParts.length > 1)
              _buildSimpleRow('Second Name (${nameParts[1]})', '$secondNameTotal = ${_reduceToSingleDigit(secondNameTotal)}'),
            _buildSimpleRow('Full Name Total', '$fullNameTotal = $reducedFullName', isLast: true, valueColor: Colors.deepPurple),
          ],
        ),
        const SizedBox(height: 16),
        _buildHeader('Lo Shu Grid', Icons.grid_3x3_rounded),
        const SizedBox(height: 12),
        _buildLoShuGrid('$day$month$year$mulank$bhagyank$kuaNumber'),
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
                    fontSize: 11,
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

  Widget _buildLoShuGrid(String digits) {
    Map<int, int> counts = {};
    for (int i = 1; i <= 9; i++) counts[i] = 0;
    for (int i = 0; i < digits.length; i++) {
      int? d = int.tryParse(digits[i]);
      if (d != null && d >= 1 && d <= 9) {
        counts[d] = counts[d]! + 1;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              _gridCell(4, counts[4]!, Colors.green.shade50, Colors.green.shade700),
              _gridCell(9, counts[9]!, Colors.red.shade50, Colors.red.shade700),
              _gridCell(2, counts[2]!, Colors.brown.shade50, Colors.brown.shade700),
              
              _gridCell(3, counts[3]!, Colors.green.shade100, Colors.green.shade800),
              _gridCell(5, counts[5]!, Colors.orange.shade50, Colors.orange.shade800),
              _gridCell(7, counts[7]!, Colors.grey.shade200, Colors.grey.shade800),
              
              _gridCell(8, counts[8]!, Colors.brown.shade100, Colors.brown.shade800),
              _gridCell(1, counts[1]!, Colors.blue.shade50, Colors.blue.shade700),
              _gridCell(6, counts[6]!, Colors.grey.shade300, Colors.grey.shade800),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridCell(int baseNum, int count, Color bgColor, Color highlightColor) {
    bool isPresent = count > 0;
    String text = isPresent ? List.filled(count, baseNum.toString()).join('') : baseNum.toString();
    
    return Container(
      decoration: BoxDecoration(
        color: isPresent ? bgColor : Colors.white,
        border: Border.all(color: isPresent ? highlightColor.withOpacity(0.5) : Colors.black12, width: isPresent ? 1.5 : 1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isPresent ? [BoxShadow(color: highlightColor.withOpacity(0.1), blurRadius: 4)] : [],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isPresent ? 20 : 16,
            fontWeight: isPresent ? FontWeight.w900 : FontWeight.w400,
            color: isPresent ? highlightColor : Colors.black26,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
