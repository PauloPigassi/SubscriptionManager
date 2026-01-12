package com.acme.subs.catalog.dto;

import java.util.UUID;

public record CatalogServiceResponse(
        UUID id,
        String name,
        String category,
        String logoUrl,
        Integer defaultPriceCents,
        String currency,
        int popularityRank
) {}
