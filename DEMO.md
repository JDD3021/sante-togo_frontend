# Dekera - Guide de Démo

## 📋 Vue d'ensemble

Cette démo présente le frontend MVP de l'application Dekera, un Dossier Médical Électronique (DME) pour les centres de santé du Togo.

**Version:** 1.0.0 (MVP)
**Plateforme:** Web (Flutter)
**État:** Mock data (pas de backend connecté)

---

## 🚀 Comment Lancer la Démo

### Option 1: Build Web Local (Recommandé pour présentation)

```bash
# Le build est déjà créé dans le dossier build/web
# Pour héberger localement:
cd build/web
python -m http.server 8000
# Ou utiliser n'importe quel serveur web
```

Puis ouvrir: `http://localhost:8000`

### Option 2: Flutter Run (Développement)

```bash
flutter run -d chrome
```

### Option 3: Déploiement Web

Le dossier `build/web` peut être déployé sur:
- **Netlify**: Drag & drop du dossier
- **Vercel**: Importer le dossier
- **GitHub Pages**: Via gh-pages
- **Firebase Hosting**: `firebase deploy`
- **Tout serveur web statique**

---

## 📱 Scénario de Démo

### Étape 1: Connexion (Login)

1. **Écran de connexion** avec pavé numérique PIN
2. **Action:** Taper n'importe quel code PIN à 4 chiffres
3. **Résultat:** Navigation automatique vers l'écran d'accueil après le 4ème chiffre
4. **Note:** Pour MVP, n'importe quel PIN fonctionne (mock authentication)

### Étape 2: Écran d'Accueil (Home)

1. **Vue d'ensemble:** 4 tuiles de navigation
   - 🔍 **Rechercher Patient** - Accès rapide aux dossiers
   - ➕ **Nouveau Patient** - Création de dossier
   - 👥 **File d'Attente** - Gestion de la file
   - 📊 **Statistiques** - (non implémenté dans MVP)
2. **Action:** Cliquer sur "Rechercher Patient"

### Étape 3: Recherche de Patient

1. **Interface de recherche:**
   - Barre de recherche par nom/prénom
   - Bouton scan QR (mock)
   - Liste de 10 patients Togolais pré-chargés
2. **Données mockées:**
   - Noms authentiques (Koffi, Adjovi, Mensah, etc.)
   - Villages réels (Lomé, Sokodé, Kara, etc.)
   - Âges variés (18-65 ans)
   - Dates de naissance réalistes
3. **Action:** Cliquer sur un patient (ex: "Koffi Adjovi")

### Étape 4: Dossier Patient (Patient Record)

1. **Informations affichées:**
   - Photo profil (placeholder)
   - Nom complet et ID patient
   - Âge et date de naissance
   - Village/Commune
   - Téléphone
   - Groupe sanguin
   - Allergies (si présentes)
   - Conditions chroniques (si présentes)
   - Historique des consultations (3 dernières)
2. **Grille d'actions:**
   - 📝 **Nouvelle Consultation**
   - 📋 **Historique Complet**
   - 💊 **Ordonnances**
   - 📊 **Vitals**
   - ⚠️ **Alertes**
3. **Action:** Cliquer sur "Nouvelle Consultation"

### Étape 5: Nouvelle Consultation (Formulaire 4 étapes)

#### Étape 1: Raison de la visite
- Sélectionner le motif (consultation, urgence, suivi, vaccination)
- Champ de description libre
- Bouton "Suivant"

#### Étape 2: Signes Vitaux
- Température (°C)
- Pression systolique/diastolique (mmHg)
- Fréquence cardiaque (bpm)
- Saturation O2 (%)
- Poids (kg)
- Taille (cm)
- Bouton "Suivant"

#### Étape 3: Diagnostic
- Champ diagnostic principal
- Sévérité (légère, modérée, sévère)
- Notes cliniques
- Bouton "Suivant"

#### Étape 4: Prescription & Suivi
- Médicaments prescrits
- Dosage
- Instructions
- Date de retour
- Bouton "Enregistrer"

**Résultat:** Confirmation avec résumé de la consultation

### Étape 6: File d'Attente (Queue)

1. **Retour à l'accueil** et cliquer sur "File d'Attente"
2. **Vue de la file:**
   - Liste des patients en attente
   - Statuts (En attente, En cours, Terminé)
   - Heures d'arrivée
   - Badge hors ligne (simulé)
3. **Données mockées:** 5 patients en file avec statuts variés

---

## 🎯 Points Clés à Présenter

### Architecture
- **Feature-first:** Séparation claire domain/data/presentation
- **State Management:** Riverpod pour gestion d'état
- **Navigation:** go_router avec routes nommées
- **Thème:** Design system centralisé (couleurs, typographie)
- **Mock Layer:** Repositories mockées faciles à remplacer par API

### UX/UI
- **Accessibilité:** Police minimum 14px, cibles tactiles 48px
- **Couleurs:** Palette vert santé Togo (#1A6B54), orange accent (#E67E22)
- **Typographie:** Baloo 2 (titres), Inter (interface)
- **Responsive:** Adapté mobile et desktop

### Contexte Togolais
- **Données réalistes:** Noms, villages, contextes locaux
- **Langue:** Interface en français
- **Unités:** Métriques (kg, cm, °C)

---

## 📝 Notes Techniques

### Structure du Projet
```
lib/
├── core/                 # Thème, widgets, constants, router
├── features/
│   ├── auth/            # Login
│   ├── home/            # Écran d'accueil
│   ├── patient_search/  # Recherche patient
│   ├── patient_record/  # Dossier patient
│   ├── consultation/     # Consultations
│   └── queue/           # File d'attente
```

### Remplacement du Backend
Les repositories mockées sont dans `lib/features/*/data/mock_*.dart`. Pour connecter l'API:
1. Créer des implémentations réelles des interfaces repository
2. Remplacer les providers Riverpod
3. Garder les interfaces identiques pour compatibilité

### Limitations MVP
- ❌ Pas d'authentification réelle
- ❌ Pas de persistance locale
- ❌ Pas de synchronisation hors ligne
- ❌ QR scanner non fonctionnel
- ❌ Statistiques non implémentées

---

## 🛠️ Dépannage

### Le build web ne se charge pas
- Vérifier que vous utilisez un serveur HTTP (pas file://)
- Chrome bloque certaines fonctionnalités en local

### Les boutons ne répondent pas
- Vérifier la console pour erreurs JavaScript
- Essayer un autre navigateur (Chrome, Edge, Firefox)

### Performance lente
- Le premier chargement peut prendre 10-15 secondes
- Utiliser le mode release (--release) pour optimisation

---

## 📞 Support

Pour questions ou problèmes:
- Vérifier le README.md pour architecture détaillée
- Consulter les commentaires dans le code pour implémentation
- Les repositories mockées documentent les interfaces API attendues

---

## 🎓 Pour le Jury

**Ce démo démontre:**
1. ✅ Architecture Flutter moderne et scalable
2. ✅ UX/UI professionnelle avec design system
3. ✅ Navigation fluide entre 6 écrans
4. ✅ Données mockées réalistes pour contexte Togolais
5. ✅ Prêt pour intégration backend
6. ✅ Accessibilité et bonnes pratiques mobile

**Prochaines étapes (hors MVP):**
- Intégration API REST/GraphQL
- Authentification réelle (PIN + biométrie)
- Persistance locale (SQLite/Hive)
- Synchronisation hors ligne
- QR scanner fonctionnel
- Notifications push
- Export PDF des consultations
