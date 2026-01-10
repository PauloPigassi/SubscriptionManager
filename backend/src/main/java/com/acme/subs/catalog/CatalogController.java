package com.acme.subs.catalog;

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
    public List<CatalogServiceEntity> top() {
        return repo.findTop().stream().limit(50).toList();
    }
}
