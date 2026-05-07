class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta? pagination;

  const PaginatedResponse({
    this.data = const [],
    this.pagination,
  });

  /// Generic factory — requires a [fromJsonT] converter for item type [T].
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T value) toJsonT) {
    return {
      'data': data.map(toJsonT).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
    };
  }

  /// Whether more pages exist after current page.
  bool get hasMore =>
      pagination != null && pagination!.page < pagination!.totalPages;

  /// Whether the response is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the response has data.
  bool get isNotEmpty => data.isNotEmpty;

  /// Total items count from pagination meta.
  int get totalItems => pagination?.totalItems ?? data.length;

  @override
  String toString() =>
      'PaginatedResponse(items: ${data.length}, page: ${pagination?.page}, totalPages: ${pagination?.totalPages})';
}

class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginationMeta({
    this.page = 1,
    this.pageSize = 25,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? json['page_size'] as int? ?? 25,
      totalItems:
          json['totalItems'] as int? ?? json['total_items'] as int? ?? 0,
      totalPages:
          json['totalPages'] as int? ?? json['total_pages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }

  /// Whether this is the first page.
  bool get isFirstPage => page <= 1;

  /// Whether this is the last page.
  bool get isLastPage => page >= totalPages;

  /// Offset for query (zero-based).
  int get offset => (page - 1) * pageSize;

  @override
  String toString() =>
      'PaginationMeta(page: $page/$totalPages, items: $totalItems)';
}
