package com.acme.subs.catalog;

import com.acme.subs.catalog.dto.CatalogServiceResponse;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/catalog")
public class CatalogController {

    private final CatalogRepository repo;

    public CatalogController(CatalogRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/top")
    public List<CatalogServiceResponse> top() {
        return repo.findTop().stream()
                .limit(50)
                .map(this::toDto)
                .toList();
    }

    private CatalogServiceResponse toDto(CatalogServiceEntity entity) {
        return new CatalogServiceResponse(
                entity.getId(),
                entity.getName(),
                entity.getCategory(),
                entity.getLogoUrl(),
                entity.getDefaultPriceCents(),
                entity.getCurrency(),
                entity.getPopularityRank()
        );
    }
}
