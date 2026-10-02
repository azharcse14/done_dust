import 'package:flutter_test/flutter_test.dart';
import 'package:physics_todo/l10n.dart';

void main() {
  test('Bangla uses Bangla digits and dates', () {
    const bn = SBn();
    expect(bn.n(2026), '২০২৬');
    expect(bn.archived(3), '৩টি কাজ আর্কাইভ হয়েছে');
    expect(bn.formatDay(DateTime(2026, 10, 2)), 'শুক্র, ২ অক্টো');
    expect(const S().jarFull(1),
        'Jar is full. Moved 1 oldest task to the archive.');
  });

  test('every language picks its own strings', () {
    for (final code in languageNames.keys) {
      final t = S.forLanguage(code);
      expect(t.code, code);
      if (code != 'en') expect(t.settings, isNot(const S().settings), reason: code);
      expect(t.starterTasks, hasLength(6), reason: code);
    }
  });
}
