import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/enrichment/external_links.dart';

void main() {
  group('ExternalEnrichmentLinks', () {
    test('1. GARUDA link encode keyword dengan benar', () {
      final link = GarudaLinkBuilder.searchByLecturer('Dr. Bambang Supriadi');
      expect(link.url.toString(), contains('Dr.%20Bambang%20Supriadi'));
      expect(link.providerId, 'garuda_link');
      expect(link.title, contains('GARUDA'));
    });

    test('2. keyword kosong tidak membuat URL rusak', () {
      final link = GarudaLinkBuilder.searchByKeyword('');
      expect(link.url.toString(), isNotEmpty);
      expect(link.query, '');
    });

    test('3. RAMA link terbentuk dari nama PT', () {
      final link = RamaLinkBuilder.searchByInstitution('Universitas Indonesia');
      expect(link.url.toString(), contains('Universitas%20Indonesia'));
      expect(link.providerId, 'rama_link');
    });

    test('4. SINTA link terbentuk dari nama dosen', () {
      final link = SintaLinkBuilder.searchLecturerProfile('Ichmi Yani');
      expect(link.url.toString(), contains('Ichmi%20Yani'));
      expect(link.providerId, 'sinta_link');
    });

    test('5. SINTA institution link terbentuk', () {
      final link = SintaLinkBuilder.searchInstitution('ITB');
      expect(link.url.toString(), contains('affiliations'));
      expect(link.url.toString(), contains('ITB'));
    });

    test('6. getDosenEnrichmentLinks returns multiple links', () {
      final links = getDosenEnrichmentLinks(
        dosenName: 'Dr. Test',
        institutionName: 'Universitas Test',
      );
      expect(links.length, 3); // GARUDA + SINTA + RAMA
      expect(links.any((l) => l.providerId == 'garuda_link'), true);
      expect(links.any((l) => l.providerId == 'sinta_link'), true);
      expect(links.any((l) => l.providerId == 'rama_link'), true);
    });

    test('7. getPtEnrichmentLinks returns RAMA + SINTA', () {
      final links = getPtEnrichmentLinks(ptName: 'UI');
      expect(links.length, 2);
    });

    test('8. semua link menggunakan https scheme', () {
      final links = getDosenEnrichmentLinks(dosenName: 'Test', institutionName: 'UI');
      for (final link in links) {
        expect(link.url.scheme, 'https');
      }
    });
  });
}
