# 💪 Gym Crew · Planning Basic-Fit

Site pour s'organiser à la salle entre amis : planning, agenda, classement, PR (squat / bench / deadlift) avec courbes de progression, photos de progression, messages, check-in « je suis à la salle », défi du mois et panel admin de modération.

Le site est statique (aucune installation) et s'appuie sur :
- **Supabase** pour la base de données (table `docs`) ;
- **Firebase Authentication** pour les comptes (email + mot de passe).

Les clés se trouvent dans `config.js`.

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | Tout le site |
| `config.js` | Clés Supabase / Firebase, admin, mode sécurisé |
| `manifest.webmanifest`, `sw.js`, `icon-*.png`, `apple-touch-icon.png` | Installation comme une app sur le téléphone |
| `supabase-securite.sql` | Règles de sécurité de la base (à exécuter une fois dans Supabase) |

## Mettre le site en ligne (GitHub Pages)

**Settings → Pages → Deploy from a branch**, branche `main`, dossier `/ (root)`. Le site est disponible sur `https://TON-PSEUDO.github.io/NOM-DU-DEPOT/`.

## Fonctionnalités

- **Planning / Agenda / Top** : séances, créneaux communs, classement du mois, streaks, team pré-workout.
- **🎯 Défi du mois** : 12 séances dans le mois → badge 🏅 visible sur le profil.
- **🟢 Check-in** : bouton « Je suis à la salle » sur l'accueil (s'efface tout seul après 3 h).
- **🔔 Notifications** sur l'accueil : commentaires et 🔥 sur tes photos, nouveaux abonnés, quelqu'un qui vient au même créneau, PR battu, ami à la salle. Le téléphone peut aussi afficher une notification quand l'app est ouverte en arrière-plan (pas quand elle est complètement fermée : il faudrait un serveur d'envoi pour ça).
- **📈 PR** : chaque nouveau record est enregistré et affiché en courbe (onglet PR et profils).
- **📲 App installable** : Android propose « Installer l'app » ; sur iPhone, Safari → Partager → « Sur l'écran d'accueil ».
- **Temps réel et économie de données** : les changements arrivent instantanément par le temps réel Supabase (activé par `supabase-securite.sql`). Une seule requête groupée resynchronise tout toutes les 5 minutes (45 s si le temps réel ne marche pas), et un cache sur l'appareil évite de retélécharger les photos à chaque ouverture.

### Entraînement et team (tuiles de l'accueil)

- **📝 Journal** : exercices, séries (kg × reps), volume total, historique ; **⏱️ minuteur de repos** (1:00 à 3:00) qui sonne et vibre, lancé automatiquement à chaque série ajoutée.
- **📚 Programmes** : programmes partagés par la team (un exercice par ligne, ex. `Squat 4x8`) ; « Faire cette séance » pré-remplit le journal.
- **🤝 Team** : fil « qui est chaud pour… » avec bouton 🙋 Je viens, et **groupes de discussion**.
- **⚔️ Défis** : niveau et XP, 12 badges à débloquer, **duels 1 contre 1** (qui fait le plus de séances dans le mois, lancés depuis le profil d'un ami), classement XP.
- **⚖️ Mon corps** : poids et mensurations avec courbes (visibles seulement par toi en mode sécurisé).
- **📊 Affluence** : heures où la team va le plus à la salle, par jour de la semaine.
- **🗓️ Récap de la semaine** (onglet Top) à partager sur WhatsApp, **🧮 calcul du 1RM** (onglet PR), **↔️ avant / après** sur les profils (2 photos ou plus), **⏰ rappel** 1 h avant ta séance, **🎨 thème** clair / sombre / auto (onglet Profil).

## Modération

- **Filtre automatique** des insultes dans les pseudos, commentaires, notes, légendes et messages (la liste `BAD` est dans `index.html`).
- **🚩 Signaler** : bouton sur les photos et commentaires des autres.
- **🛡️ Panel admin** (onglet Profil, visible seulement pour l'admin) : signalements, photos, commentaires, séances, PR, profils ; suppression, retrait de photo de profil, **🚫 bannissement** (un membre banni ne peut plus rien publier).
- L'admin est reconnu par l'empreinte SHA-256 de son email (`ADMIN_HASH` dans `config.js`), l'email n'apparaît pas en clair.

## 🔒 Sécuriser la base (recommandé)

Sans cette étape, la clé publique de `config.js` permet à quelqu'un de technique de modifier ou supprimer n'importe quelle donnée, et de lire les messages privés. Le panel admin ne fait que cacher les boutons.

1. **Récupère l'ID du projet Firebase** : console Firebase → ⚙️ Paramètres du projet → « ID du projet ».
2. **Branche Firebase dans Supabase** : tableau de bord Supabase → Authentication → Sign In / Providers → **Third-party Auth** → *Add provider* → **Firebase** → colle l'ID du projet → enregistre.
3. **Exécute le script** : Supabase → **SQL Editor** → colle le contenu de `supabase-securite.sql`, remplace `TON_EMAIL_ADMIN` par ton email de connexion au site, puis *Run*.
4. **Active le mode sécurisé** : dans `config.js`, passe `const SB_SECURE=false;` à `true` et publie.

Ensuite :
- tout le monde peut voir les publications, mais **il faut être connecté pour publier** ;
- chacun ne peut modifier/supprimer que ce qu'il a publié ; l'admin peut tout supprimer et bannir ;
- les messages privés ne sont lisibles que par les deux personnes concernées.

**En cas de problème** : remets `SB_SECURE=false` dans `config.js` et exécute la partie « RETOUR ARRIÈRE » en bas de `supabase-securite.sql`.

> Les séances publiées avant la sécurisation par des personnes **non connectées** ne pourront plus être modifiées par elles (seul l'admin pourra les supprimer).

## Mises à jour de l'app installée

L'app installée sur l'écran d'accueil vérifie s'il existe une nouvelle version quand on revient dessus (et toutes les 15 min) et affiche un bandeau « Mettre à jour ».
**À chaque modification du site, change `APP_VERSION` dans `index.html`** (ex. `2026-10-13.3` → `2026-10-13.4`), sinon le bandeau ne s'affiche pas.
En cas de souci : Profil → « Forcer la mise à jour de l'app ».
