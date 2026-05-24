# 🏗️ Architecture MVC — Documentation détaillée

Ce document explique en détail l'architecture **Modèle-Vue-Contrôleur (MVC)** adoptée dans l'application Wallet.

## Vue d'ensemble

L'application est organisée selon **4 couches** distinctes pour respecter le principe de séparation des préoccupations :

```
┌──────────────────────────────────────────┐
│   VIEW    (lib/views/)    — Présentation │
├──────────────────────────────────────────┤
│ CONTROLLER (lib/controllers/) — Logique  │
├──────────────────────────────────────────┤
│  SERVICE  (lib/services/)  — Accès données│
├──────────────────────────────────────────┤
│   MODEL   (lib/models/)   — Entités      │
└──────────────────────────────────────────┘
```

## 1. MODEL — Les entités

Les modèles sont des **classes Dart simples** représentant les entités du domaine. Chaque modèle expose :

- Un **constructeur** avec les champs requis
- Une méthode `toMap()` pour la sérialisation SQLite
- Un constructeur `fromMap()` pour la désérialisation
- Une méthode `copyWith()` pour créer des copies modifiées (immutabilité)

### Entités du projet

| Entité        | Description                                  |
| ------------- | -------------------------------------------- |
| `User`        | Utilisateur (id, nom, email, hash, créé le)  |
| `Category`    | Catégorie de transaction (revenus/dépenses)  |
| `Transaction` | Opération financière (montant, date, etc.)   |
| `Budget`      | Limite mensuelle pour une catégorie          |

## 2. SERVICE — Accès aux données (DAO)

Les services encapsulent **toute la logique d'accès aux données** :

- Requêtes SQL (CRUD et statistiques)
- Hashage des mots de passe (SHA-256)
- Gestion des préférences (SharedPreferences)

Ils sont **stateless** : ils ne maintiennent pas d'état entre les appels.

### Services principaux

- `DatabaseHelper` — Singleton SQLite, création des tables
- `AuthService` — Inscription, connexion, hash sécurisé
- `CategoryService` — CRUD catégories
- `TransactionService` — CRUD transactions + requêtes statistiques
- `BudgetService` — CRUD budgets avec calcul du montant dépensé

## 3. CONTROLLER — Logique métier et état

Les contrôleurs sont des **`ChangeNotifier`** qui :

1. **Reçoivent les actions** depuis la vue (ex: `login(email, password)`)
2. **Délèguent aux services** pour effectuer les opérations
3. **Maintiennent l'état** (utilisateur connecté, liste des transactions, ...)
4. **Notifient l'UI** via `notifyListeners()`

### Contrôleurs et responsabilités

| Contrôleur                | État géré                                |
| ------------------------- | ---------------------------------------- |
| `AuthController`          | Utilisateur courant, chargement, erreurs |
| `ThemeController`         | Mode clair/sombre                        |
| `TransactionController`   | Liste, totaux, statistiques              |
| `CategoryController`      | Catégories de l'utilisateur              |
| `BudgetController`        | Budgets du mois sélectionné              |

### Injection de dépendances

Les contrôleurs sont instanciés dans `main.dart` et injectés dans l'arbre via un `InheritedWidget` personnalisé : `AppProvider`.

```dart
// Dans n'importe quelle vue :
final auth = AppProvider.of(context).authController;
```

Cette approche évite la dépendance au package `provider` tout en respectant le pattern d'injection.

## 4. VIEW — Interface utilisateur

Les vues sont des **`StatelessWidget`** ou **`StatefulWidget`** Flutter qui :

- N'effectuent **AUCUN** appel direct à la base de données
- Délèguent toutes les actions aux contrôleurs
- Se reconstruisent automatiquement via `ListenableBuilder` quand l'état change

### Organisation des vues

```
views/
├── auth/        → Splash, Login, Register
├── home/        → MainScreen (nav), HomeScreen (dashboard)
├── transactions/→ Liste, Ajout/Édition, Détail
├── budgets/     → Liste, Ajout
├── statistics/  → Graphiques
└── profile/     → Profil utilisateur
```

## Flow type — Ajouter une transaction

```
Utilisateur clique sur +
     │
     ▼
[VIEW] AddTransactionScreen
   "Enregistrer" pressé
     │
     ▼
[CONTROLLER] TransactionController.addTransaction(...)
     │
     ▼
[SERVICE] TransactionService.createTransaction(t)
     │
     ▼
[DATABASE] INSERT INTO transactions ...
     │
     ▼
Controller appelle notifyListeners()
     │
     ▼
[VIEW] ListenableBuilder reconstruit la liste
```

## Avantages de cette architecture

✅ **Séparation des préoccupations** — chaque couche a une responsabilité unique
✅ **Testabilité** — les services et contrôleurs sont testables indépendamment de l'UI
✅ **Maintenabilité** — modifier une couche n'impacte pas les autres
✅ **Évolutivité** — ajouter une nouvelle fonctionnalité = créer un nouveau triplet (Model + Service + Controller)
✅ **Conformité au cahier des charges** — respect strict de l'architecture MVC exigée
