# 🛠️ Guide d'installation et résolution de problèmes

## ⚡ Démarrage rapide (recommandé)

**Sur Windows :** double-clique sur `fix_gradle.bat` à la racine du projet, puis lance `flutter run`.

**Sur Mac/Linux :** voir étapes manuelles ci-dessous.

---

## 📋 Étapes manuelles

### 1. Nettoyer complètement

```bash
# Arreter Gradle
cd android
./gradlew --stop
cd ..

# Nettoyer Flutter
flutter clean
```

### 2. Sur Windows uniquement : nettoyer le cache global

```cmd
rmdir /s /q "%USERPROFILE%\.gradle\caches\8.9"
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4"
```

### 3. Réinstaller les dépendances

```bash
flutter pub get
```

### 4. Lancer

```bash
flutter run
```

---

## 🚨 Erreurs courantes et solutions

### ❌ Erreur : "Could not serialize types map to a file" / "MergeInstrumentationAnalysisTransform"

**Cache Gradle corrompu** (Windows surtout). Solution :

```cmd
:: 1. Ferme VS Code et tout ce qui touche au projet
:: 2. Dans cmd :
cd C:\Users\user\Downloads\wallet_app
android\gradlew --stop
rmdir /s /q android\.gradle
rmdir /s /q "%USERPROFILE%\.gradle\caches\8.9"
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4"
flutter clean
flutter pub get
flutter run
```

### ❌ Erreur : "emulator-5554 is offline"

1. Ferme l'émulateur complètement
2. Android Studio → **Device Manager** → ⋮ sur le Pixel 6 → **Cold Boot Now**
3. Attends l'écran d'accueil Android complet (icône batterie verte)
4. Vérifie avec `adb devices` qu'il est "device" et pas "offline"

Si toujours offline :
```cmd
adb kill-server
adb start-server
adb devices
```

### ❌ Erreur : "Android Gradle Plugin version too low"

Déjà fixé dans cette version (AGP 8.7.0). Si l'erreur persiste, c'est le cache. Voir solution ci-dessus.

### ❌ Erreur : Dépendances incompatibles

```bash
flutter pub upgrade
flutter pub get
```

### ❌ La compilation prend très longtemps (>15min)

Normal au premier build : Gradle télécharge ~500MB. Les builds suivants prennent 1-2 min.

### ❌ Erreur SQLite "no such table"

Désinstalle l'app de l'émulateur :
- Long-press sur l'icône → Désinstaller
- Relance `flutter run` → la DB sera recréée

---

## 📦 Versions utilisées

| Outil               | Version |
| ------------------- | ------- |
| Flutter             | ≥ 3.19  |
| Dart                | ≥ 3.3   |
| Gradle              | 8.9     |
| Android Gradle Plug | 8.7.0   |
| Kotlin              | 1.9.0   |
| Min SDK Android     | 21 (Android 5.0) |
| Target SDK          | 34 (Android 14)  |

---

## 💡 Astuces

- **VS Code** : installe l'extension officielle Flutter pour le hot reload
- **Hot Reload** : appuie sur `r` dans le terminal pendant que l'app tourne
- **Hot Restart** : appuie sur `R` (majuscule)
- **Quitter** : `q`

