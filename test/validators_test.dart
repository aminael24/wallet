// Tests basiques pour l'application Wallet
// Exécuter avec : flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email valide', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name@ensa.ac.ma'), isNull);
    });

    test('email invalide', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
    });

    test('mot de passe valide', () {
      expect(Validators.validatePassword('abc123'), isNull);
      expect(Validators.validatePassword('Password1'), isNull);
    });

    test('mot de passe invalide', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('short'), isNotNull);
      expect(Validators.validatePassword('nochar'), isNotNull); // pas de chiffre
    });

    test('montant valide', () {
      expect(Validators.validateAmount('100'), isNull);
      expect(Validators.validateAmount('99,99'), isNull);
      expect(Validators.validateAmount('1234.56'), isNull);
    });

    test('montant invalide', () {
      expect(Validators.validateAmount(''), isNotNull);
      expect(Validators.validateAmount('abc'), isNotNull);
      expect(Validators.validateAmount('-10'), isNotNull);
      expect(Validators.validateAmount('0'), isNotNull);
    });

    test('confirmation mot de passe', () {
      expect(Validators.validateConfirmPassword('abc', 'abc'), isNull);
      expect(Validators.validateConfirmPassword('abc', 'xyz'), isNotNull);
    });
  });
}
