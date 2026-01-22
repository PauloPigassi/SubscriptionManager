# Ícones das assinaturas

O app usa ícones para exibir as **categorias** das assinaturas (ex.: streaming, música, jogos). O ícone é definido por categoria, não por assinatura.

---

## 1. Onde o ícone é definido

O mapeamento **categoria → ícone** está em:

```
lib/utils/category_icons.dart
```

- `CategoryIcons.getIcon(String? category)` → `IconData`
- `CategoryIcons.builtIn` → lista de categorias predefinidas
- `CategoryIcons.displayName(String)` → nome para exibição (primeira letra maiúscula)

---

## 2. Como adicionar ícone a uma categoria nova

1. Abra `lib/utils/category_icons.dart`.

2. Se quiser que a categoria apareça na lista fixa do formulário "Adicionar assinatura", adicione em `builtIn`:

   ```dart
   static const List<String> builtIn = [
     'streaming',
     'music',
     // ...
     'sua_categoria',  // nova
   ];
   ```

3. Em `getIcon`, adicione um `case` para a nova categoria:

   ```dart
   static IconData getIcon(String? category) {
     switch (category?.toLowerCase()) {
       // ... casos existentes ...
       case 'sua_categoria':
         return Icons.um_icone_qualquer_outlined;  // ou .rounded, etc.
       default:
         return Icons.receipt_long_outlined;
     }
   }
   ```

4. Categorias que **não** estão no `switch` usam o ícone padrão: `Icons.receipt_long_outlined`.

---

## 3. Ícones do Flutter (Material)

Os nomes vêm de `Icons` do `package:flutter/material.dart`. Exemplos:

- `Icons.movie_filter_outlined`
- `Icons.headphones_outlined`
- `Icons.cloud_outlined`
- `Icons.sports_esports_outlined`
- `Icons.code_outlined`
- `Icons.favorite_outline`
- `Icons.school_outlined`
- `Icons.receipt_long_outlined`
- `Icons.shopping_bag_outlined`
- `Icons.directions_car_outlined`

Para ver a lista completa: [Material Icons](https://fonts.google.com/icons?selected=Material+Icons). Use o nome em camelCase, por exemplo `local_cafe` → `Icons.local_cafe_outlined`.

---

## 4. Ícone por assinatura (futuro)

Hoje o ícone depende só da **categoria**. Para ter ícone **por assinatura**:

1. **Backend**  
   - Adicionar em `Subscription` um campo opcional, por exemplo:  
     `icon_name` (String, ex. `"movie_filter"`).

2. **Flutter**  
   - No modelo `Subscription`, incluir `iconName`.  
   - Criar um mapa de `String` → `IconData` (ex. `"movie_filter"` → `Icons.movie_filter_outlined`).  
   - Na hora de exibir:  
     - se `subscription.iconName != null`, usar o ícone correspondente;  
     - senão, usar `CategoryIcons.getIcon(subscription.category)` como hoje.

3. **UI**  
   - Na tela de adicionar/editar assinatura, um seletor de ícone (lista ou grid de ícones) que grava `icon_name` ao salvar.

---

## 5. Resumo

| Onde                      | O que fazer                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| Nova **categoria**        | Incluir em `builtIn` e em `getIcon` em `lib/utils/category_icons.dart`.     |
| Ícone **padrão**          | Alterar o `default` em `getIcon` em `category_icons.dart`.                  |
| Ícone **por assinatura**  | Campo `icon_name` no backend e no modelo; mapa e seletor no Flutter (4.).   |
