import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ============================================================
/// SERVICE : DatabaseHelper (Singleton)
/// Gère la connexion SQLite et la création des tables
/// ============================================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Récupère l'instance de la base (lazy init)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wallet_app.db');
    return _database!;
  }

  /// Initialise la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Création des tables au premier lancement
  Future<void> _createTables(Database db, int version) async {
    // Table USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Table CATEGORIES
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        icon_code_point INTEGER NOT NULL,
        color_index INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table TRANSACTIONS
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        title TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Table BUDGETS
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        limit_amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, category_id, month, year),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Index pour optimiser les requêtes
    await db.execute('CREATE INDEX idx_transactions_user_date ON transactions(user_id, date)');
    await db.execute('CREATE INDEX idx_categories_user_type ON categories(user_id, type)');
    await db.execute('CREATE INDEX idx_budgets_user_month ON budgets(user_id, year, month)');
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
