package com.acme.subs.catalog;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "catalog_services")
public class CatalogServiceEntity {
    @Id @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category;

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(name = "default_price_cents")
    private Integer defaultPriceCents;

    @Column(nullable = false)
    private String currency = "BRL";

    @Column(name = "popularity_rank", nullable = false)
    private int popularityRank = 9999;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    // getters/setters
}
