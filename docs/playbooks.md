# Playbooks de réponse à incident — SOC-Copilot

> Base de connaissances pour l'analyste SOC et l'agent IA.
> Chaque playbook suit le cycle NIST : Détection → Analyse → Containment → Éradication → Récupération → Leçons apprises.
> Environnement : Wazuh (SIEM) + n8n (SOAR) + MISP/AbuseIPDB (Threat Intel) + TheHive (gestion d'incident).

---

## Playbook 1 — Injection SQL sur serveur web (MITRE T1190)

**Déclencheur :** Règle Wazuh 100200 « Multiple SQL injection attempts », niveau 12, sur l'agent SRV-WEB.

### 1. Détection
- Source : logs d'accès Apache de DVWA lus par l'agent Wazuh.
- Signature : présence de motifs SQL malveillants dans l'URL (`UNION SELECT`, `OR 1=1`, `-- -`).

### 2. Analyse (triage)
- Vérifier si c'est un **vrai positif** : l'IP source est-elle légitime ?
- Enrichir l'IP :
  - **AbuseIPDB** → réputation publique (score 0–100).
  - **MISP** → est-ce un IOC déjà connu ? Si oui → **menace confirmée**.
- Vérifier le code de réponse HTTP : un `200` sur une requête d'injection = risque d'exfiltration réussie.

### 3. Containment (endiguement)
- Bloquer l'IP source au pare-feu (Active Response Wazuh ou règle manuelle).
- Isoler le serveur web si compromission confirmée.

### 4. Éradication
- Corriger la vulnérabilité (requêtes paramétrées, WAF, validation des entrées).
- Vérifier l'intégrité de la base de données (données modifiées/exfiltrées ?).

### 5. Récupération
- Restaurer les données depuis une sauvegarde saine si nécessaire.
- Remettre le service en production après validation.

### 6. Leçons apprises
- Ajouter l'IP attaquante dans MISP (capitalisation du renseignement).
- Documenter l'incident dans TheHive (observables + timeline).

---

## Playbook 2 — Brute force SSH puis connexion réussie (MITRE T1110 + T1078)

**Déclencheur :** Règles Wazuh 100300 (5 échecs SSH / 120 s, même IP) puis 100301 (connexion réussie après brute force).

### 1. Détection
- Multiples échecs d'authentification SSH (règle native 5760) corrélés par 100300.
- Une connexion réussie (5715) après la rafale d'échecs = compromission probable (100301).

### 2. Analyse
- Identifier le compte ciblé et l'IP source.
- Enrichir l'IP (AbuseIPDB + MISP).
- Vérifier l'historique de connexions de ce compte (comportement inhabituel ?).

### 3. Containment
- Bloquer l'IP source.
- Désactiver / forcer le changement du mot de passe du compte compromis.
- Terminer les sessions actives suspectes.

### 4. Éradication
- Rechercher une persistance (clés SSH ajoutées, tâches planifiées, nouveaux comptes).
- Supprimer tout accès non autorisé.

### 5. Récupération
- Réactiver le compte avec un mot de passe fort + MFA si possible.
- Renforcer la politique SSH (fail2ban, clés only, port non standard).

### 6. Leçons apprises
- Ajouter l'IP dans MISP.
- Mettre à jour les règles de corrélation si nécessaire.

---

## Playbook 3 — Malware téléchargé / exécuté (MITRE T1204)

**Déclencheur :** Règle Wazuh 100211 « Exécutable malveillant dans Downloads », niveau élevé, sur le poste Windows (Sysmon).

### 1. Détection
- Sysmon détecte la création/exécution d'un exécutable suspect (ex. EICAR).

### 2. Analyse
- Calculer le hash du fichier (MD5/SHA256).
- Enrichir le hash dans **MISP** → IOC connu ?
- Identifier l'utilisateur et le processus parent (comment est-il arrivé ?).

### 3. Containment
- Isoler le poste du réseau.
- Tuer le processus malveillant.

### 4. Éradication
- Supprimer le fichier et tout artefact de persistance (tâches planifiées T1053, clés de registre Run).
- Scan antivirus complet.

### 5. Récupération
- Restaurer le poste depuis une image saine si nécessaire.
- Rendre l'accès réseau après validation.

### 6. Leçons apprises
- Ajouter le hash dans MISP.
- Sensibiliser l'utilisateur (vecteur d'entrée).

---

## Playbook 4 — Match IOC Threat Intelligence (IP/hash connu)

**Déclencheur :** Règle Wazuh 100400 « Threat Intel - IP source présente dans MISP », niveau 12.

### 1. Détection
- Une IP/hash observé dans les logs correspond à un IOC de la liste CDB synchronisée depuis MISP.

### 2. Analyse
- Consulter la fiche MISP de l'IOC (campagne, acteur, TLP).
- Évaluer l'exposition : quelles machines ont communiqué avec cet IOC ?

### 3. Containment
- Bloquer l'IOC (IP au pare-feu, hash en liste de blocage EDR).

### 4. Éradication / Récupération
- Chasser (threat hunting) toute trace de l'IOC sur le parc.
- Nettoyer les systèmes affectés.

### 6. Leçons apprises
- Confirmer/enrichir la fiche MISP.
- Partager l'IOC avec les partenaires (TLP approprié).

---

## Règles de priorisation (triage rapide)

| Situation | Criticité | Action |
|-----------|-----------|--------|
| IOC connu dans MISP + attaque active | **Critique** | Réponse immédiate, blocage |
| Attaque détectée, IP inconnue mais score AbuseIPDB élevé | **Haute** | Investigation prioritaire |
| Attaque détectée, IP interne / score faible | **Moyenne** | Vérifier faux positif |
| Événement isolé, non corrélé | **Basse** | Surveillance |

## Métriques à suivre (performance SOC)
- **MTTD** (Mean Time To Detect) : délai détection.
- **MTTR** (Mean Time To Respond) : délai de réponse.
- **Taux de faux positifs** : qualité des règles.
