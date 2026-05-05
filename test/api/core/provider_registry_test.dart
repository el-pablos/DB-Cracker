import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/core/provider_registry.dart';

void main() {
  group('ProviderRegistry', () {
    test('byKind returns correct providers filtered by kind', () {
      final pddikti = ProviderRegistry.byKind(ProviderKind.pddikti);
      expect(pddikti.isNotEmpty, true);
      expect(pddikti.every((p) => p.kind == ProviderKind.pddikti), true);
    });

    test('byKind sorts by priority ascending', () {
      final pddikti = ProviderRegistry.byKind(ProviderKind.pddikti);
      for (int i = 1; i < pddikti.length; i++) {
        expect(pddikti[i].priority, greaterThanOrEqualTo(pddikti[i - 1].priority));
      }
    });

    test('byKind excludes disabled providers', () {
      final all = ProviderRegistry.byKind(ProviderKind.pddikti);
      expect(all.every((p) => p.enabled), true);
    });

    test('byId returns correct provider for valid ID', () {
      final provider = ProviderRegistry.byId('pddikti_fastapicloud');
      expect(provider, isNotNull);
      expect(provider!.name, contains('FastAPI'));
    });

    test('byId returns null for non-existent ID', () {
      final provider = ProviderRegistry.byId('nonexistent_provider');
      expect(provider, isNull);
    });

    test('coreProviders only returns authMode none', () {
      final core = ProviderRegistry.coreProviders;
      expect(core.every((p) => p.authMode == ProviderAuthMode.none), true);
    });

    test('externalLinkProviders returns GARUDA RAMA SINTA', () {
      final links = ProviderRegistry.externalLinkProviders;
      expect(links.length, 3);
      expect(links.any((p) => p.id == 'garuda_link'), true);
      expect(links.any((p) => p.id == 'rama_link'), true);
      expect(links.any((p) => p.id == 'sinta_link'), true);
    });

    test('all providers have unique IDs', () {
      final ids = ProviderRegistry.allProviders.map((p) => p.id).toSet();
      expect(ids.length, ProviderRegistry.allProviders.length);
    });

    test('all providers have valid HTTPS baseUrl', () {
      for (final p in ProviderRegistry.allProviders) {
        expect(p.baseUrl.startsWith('https://'), true, reason: '${p.id} baseUrl must be HTTPS');
      }
    });
  });
}
