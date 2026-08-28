# SANTÉ+ TOGO - Dossier Médical Électronique

Application Flutter de Dossier Médical Électronique (DME) pour les centres de santé du Togo.

## 📋 Description

SANTÉ+ TOGO est une application mobile conçue pour les agents de santé (infirmiers, médecins, agents communautaires) travaillant dans des zones à connectivité faible ou instable. L'interface est radicalement simple avec des gros boutons, des pictogrammes, et des parcours courts (3 clics max pour une action courante).

## 🎯 Public Cible

- Agents de santé peu formés à l'informatique
- Zones rurales avec connectivité faible
- Centres de santé du Togo

## 🏗️ Architecture

Le projet utilise une architecture **feature-first** avec une séparation claire entre UI, logique d'état et données :

```
lib/
├── core/
│   ├── theme/              # Couleurs, typographie, thème Flutter centralisé
│   ├── widgets/            # Composants réutilisables (boutons, cartes, badges…)
│   ├── router/             # Configuration go_router
│   └── constants/          # Icônes, tailles, constantes
├── features/
│   ├── auth/
│   │   └── presentation/   # Écran PIN (UI uniquement pour l'instant)
│   ├── home/
│   │   └── presentation/
│   ├── patient_search/
│   │   ├── presentation/
│   │   ├── domain/         # Entités Patient, interfaces repository
│   │   └── data/            # Implémentation mock du repository
│   ├── patient_record/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── consultation/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   └── queue/
│       ├── presentation/
│       ├── domain/
│       └── data/
└── main.dart
```

## 🛠️ Stack Technique

- **Framework**: Flutter
- **State Management**: Riverpod (flutter_riverpod)
- **Navigation**: go_router
- **Fonts**: google_fonts (Baloo 2, Inter)
- **QR Scanning**: mobile_scanner (optionnel)

## 🚀 Installation

### Prérequis

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)

### Étapes

1. Cloner le projet :
```bash
git clone <repository-url>
cd FRONTEND
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Lancer l'application :
```bash
flutter run
```

## 📱 Écrans de l'MVP

### 1. Écran de connexion (/login)
- Logo/marque centré
- Pavé numérique custom (grille 3x4)
- 4 points de progression du code PIN
- Bouton empreinte digitale (visuel uniquement)
- Navigation vers /home après saisie du PIN

### 2. Écran d'accueil (/home)
- Bandeau d'état de connexion (En ligne / Hors-ligne)
- 3 tuiles cliquables : Chercher, Nouveau patient, File d'attente
- Barre de navigation basse (Accueil / Chercher / Réglages)

### 3. Écran de recherche patient (/search)
- Zone "scanner un QR code"
- Champ de recherche texte (nom ou village)
- Liste "Récemment vus"
- Navigation vers /patient/:id

### 4. Écran fiche patient (/patient/:id)
- Carte d'en-tête (avatar, nom, âge, sexe, village)
- Bandeau d'alerte rouge si allergies
- Grille 2x2 d'actions : Historique, Traitements, Vaccinations, Nouvelle consultation

### 5. Écran nouvelle consultation (/patient/:id/consultation)
- Formulaire progressif en 4 étapes
- Barre de progression segmentée
- Étape 1 : Motif (6 cartes pictogrammes)
- Étape 2 : Constantes (température, tension, poids)
- Étape 3 : Diagnostic (liste illustrée + champ libre)
- Étape 4 : Prescription et rappel de suivi

### 6. Écran file d'attente (/queue)
- En-tête avec badge "X patients"
- Bandeau d'état hors-ligne si applicable
- Liste de cartes patient avec statut (En cours, Suivant, Attente)

## 🎨 Design System

### Couleurs

- **primary**: #1A6B54 (vert médical)
- **primaryDark**: #0F4A39
- **primaryLight**: #DCEDE6
- **accent**: #E67E22 (orange chaleureux)
- **accentLight**: #FCE9D2
- **red**: #B4362A (réservé EXCLUSIVEMENT aux alertes critiques)
- **redLight**: #F7E1DE
- **sand**: #EFE6D6
- **sandDark**: #D8C9A9
- **ink**: #20261F (texte principal)
- **inkSoft**: #5B6660 (texte secondaire)
- **line**: #E4DDCD (bordures)
- **screenBg**: #FBF8F2 (fond des écrans)
- **white**: #FFFFFF

### Typographie

- **Titres**: Baloo 2 (arrondie, chaleureuse), poids 700-800
- **Corps**: Inter (neutre, très lisible), min 16px
- **Minimum**: 12px nulle part

### Composants

- Boutons : hauteur minimum 48px, coins arrondis (16px)
- Cartes : coins arrondis (16px), elevation 2
- Badges : pour statuts et indicateurs

## 💾 Données Mockées

Le projet utilise des repositories mockés avec des données de démonstration réalistes :

- **10 patients** avec des profils variés (noms togolais, villages togolais)
- **Au moins 1 patient** avec allergies
- **Au moins 1 patient** avec maladie chronique
- **2-3 consultations** pour au moins 2 patients
- **File d'attente** avec 5-8 entrées et statuts variés

## 🔌 Remplacement des Mocks par l'API

Les repositories sont définis comme des interfaces abstraites dans `domain/`. Pour remplacer les mocks par de vrais appels API :

1. Créer une nouvelle implémentation (ex: `ApiPatientRepository`)
2. Implémenter l'interface `PatientRepository`
3. Appeler l'API REST dans les méthodes
4. Mettre à jour le provider pour utiliser la nouvelle implémentation

Exemple :
```dart
// Dans le fichier de providers
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return ApiPatientRepository(); // Au lieu de MockPatientRepository
});
```

## 📝 À Faire (Itérations Futures)

- [ ] Authentification réelle (PIN vérifié)
- [ ] Connexion à l'API REST/backend
- [ ] Mode hors-ligne réel (sync, SQLite chiffré)
- [ ] Écrans pharmacien et administrateur
- [ ] Support multilingue (Éwé, Kabiyè)
- [ ] Rappels SMS
- [ ] Formulaire nouveau patient complet

## 🤝 Contribution

Ce projet est actuellement en développement. Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add some AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

[À définir]

## 👥 Équipe

[À définir]

## 📞 Contact

[À définir]
