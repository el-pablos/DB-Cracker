/// External Link Enrichment — GARUDA, RAMA, SINTA
/// INI BUKAN API PROVIDER. Ini hanya deep-link builder.
/// Tidak ada scraping. Tidak ada fetch data otomatis.
/// Hanya membangun URL pencarian yang bisa dibuka user di browser.

import '../core/data_result.dart';

/// Model untuk tautan enrichment eksternal
class ExternalEnrichmentLink {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final Uri url;
  final String query;
  final DataSourceType sourceType;

  const ExternalEnrichmentLink({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.url,
    required this.query,
    this.sourceType = DataSourceType.externalLink,
  });
}

/// Builder untuk link GARUDA (publikasi ilmiah)
class GarudaLinkBuilder {
  static const _baseUrl = 'https://garuda.kemdiktisaintek.go.id';
  static const _providerId = 'garuda_link';

  /// Buat link pencarian publikasi berdasarkan nama dosen
  static ExternalEnrichmentLink searchByLecturer(String lecturerName) {
    final query = lecturerName.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'garuda_lecturer_$encodedQuery',
      providerId: _providerId,
      title: 'Cari Publikasi di GARUDA',
      description: 'Buka pencarian publikasi "$query" di portal GARUDA Kemdiktisaintek',
      url: Uri.parse('$_baseUrl/documents?q=$encodedQuery'),
      query: query,
    );
  }

  /// Buat link pencarian berdasarkan keyword
  static ExternalEnrichmentLink searchByKeyword(String keyword) {
    final query = keyword.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'garuda_keyword_$encodedQuery',
      providerId: _providerId,
      title: 'Cari di GARUDA',
      description: 'Buka pencarian "$query" di portal GARUDA',
      url: Uri.parse('$_baseUrl/documents?q=$encodedQuery'),
      query: query,
    );
  }
}

/// Builder untuk link RAMA (repository akademik)
class RamaLinkBuilder {
  static const _baseUrl = 'https://rama.kemdiktisaintek.go.id';
  static const _providerId = 'rama_link';

  /// Buat link pencarian repository berdasarkan nama PT
  static ExternalEnrichmentLink searchByInstitution(String institutionName) {
    final query = institutionName.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'rama_institution_$encodedQuery',
      providerId: _providerId,
      title: 'Cari Repository di RAMA',
      description: 'Buka pencarian repository "$query" di portal RAMA',
      url: Uri.parse('$_baseUrl/search?q=$encodedQuery'),
      query: query,
    );
  }

  /// Buat link pencarian tugas akhir/tesis
  static ExternalEnrichmentLink searchDocuments(String keyword) {
    final query = keyword.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'rama_docs_$encodedQuery',
      providerId: _providerId,
      title: 'Cari Tugas Akhir di RAMA',
      description: 'Buka pencarian dokumen "$query" di portal RAMA',
      url: Uri.parse('$_baseUrl/search?q=$encodedQuery'),
      query: query,
    );
  }
}

/// Builder untuk link SINTA (profil riset dosen)
class SintaLinkBuilder {
  static const _baseUrl = 'https://sinta.kemdikbud.go.id';
  static const _providerId = 'sinta_link';

  /// Buat link pencarian profil dosen di SINTA
  static ExternalEnrichmentLink searchLecturerProfile(String lecturerName) {
    final query = lecturerName.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'sinta_lecturer_$encodedQuery',
      providerId: _providerId,
      title: 'Cari Profil di SINTA',
      description: 'Buka pencarian profil "$query" di portal SINTA Kemdikbud',
      url: Uri.parse('$_baseUrl/authors?q=$encodedQuery'),
      query: query,
    );
  }

  /// Buat link pencarian institusi di SINTA
  static ExternalEnrichmentLink searchInstitution(String institutionName) {
    final query = institutionName.trim();
    final encodedQuery = Uri.encodeComponent(query);
    return ExternalEnrichmentLink(
      id: 'sinta_institution_$encodedQuery',
      providerId: _providerId,
      title: 'Cari Institusi di SINTA',
      description: 'Buka pencarian institusi "$query" di portal SINTA',
      url: Uri.parse('$_baseUrl/affiliations?q=$encodedQuery'),
      query: query,
    );
  }
}

/// Helper: ambil semua enrichment links untuk dosen
List<ExternalEnrichmentLink> getDosenEnrichmentLinks({
  required String dosenName,
  String? institutionName,
}) {
  final links = <ExternalEnrichmentLink>[
    GarudaLinkBuilder.searchByLecturer(dosenName),
    SintaLinkBuilder.searchLecturerProfile(dosenName),
  ];

  if (institutionName != null && institutionName.isNotEmpty) {
    links.add(RamaLinkBuilder.searchByInstitution(institutionName));
  }

  return links;
}

/// Helper: ambil semua enrichment links untuk PT
List<ExternalEnrichmentLink> getPtEnrichmentLinks({
  required String ptName,
}) {
  return [
    RamaLinkBuilder.searchByInstitution(ptName),
    SintaLinkBuilder.searchInstitution(ptName),
  ];
}
