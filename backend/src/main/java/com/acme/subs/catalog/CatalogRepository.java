package com.acme.subs.catalog;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;

public interface CatalogRepository extends JpaRepository<CatalogServiceEntity, UUID> {

    @Query("""
    select c from CatalogServiceEntity c
    order by c.popularityRank asc
  """)
    List<CatalogServiceEntity> findTop();
}
