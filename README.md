
# Basic-fit-planning# 💪 Planning Basic-Fit

Site pour noter ses séances à la salle avec ses amis : planning, calendrier, classement (séances, streak, pré-workout), PR (squat / bench / deadlift) et photos de progression avec commentaires.

Tout le site tient dans un seul fichier : `index.html` (aucune dépendance à installer).

## Mettre le site en ligne avec GitHub Pages

1. Crée un dépôt sur GitHub et envoie-y `index.html` et `README.md`.
2. Va dans **Settings → Pages**.
3. Dans « Build and deployment », choisis **Deploy from a branch**, la branche `main` et le dossier `/ (root)`.
4. Après une minute, le site est disponible sur `https://TON-PSEUDO.github.io/NOM-DU-DEPOT/`.

## ⚠️ Données partagées

Le partage du planning entre amis (planning, PR, photos, commentaires) repose sur la base de données de Claude (`window.claude` / `db`). Elle n'existe que dans la version hébergée par Claude.

Hébergé sur GitHub Pages, le site s'ouvre en **mode local** :
- le planning fonctionne mais n'est visible que sur ton appareil et disparaît au rechargement ;
- les onglets PR et Photos affichent « Disponible en mode partagé ».

Pour avoir un vrai planning partagé sur GitHub Pages, il faut brancher un service de base de données (Firebase, Supabase…) à la place de `claude.use("db")`.
