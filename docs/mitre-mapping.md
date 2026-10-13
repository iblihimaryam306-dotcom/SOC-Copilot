# Référence MITRE ATT&CK — Techniques détectées par SOC-Copilot

> Base de connaissances des techniques d'attaque couvertes par le SOC.
> Pour chaque technique : tactique, description, comment on la détecte, et comment s'en défendre.

---

## T1190 — Exploit Public-Facing Application
- **Tactique :** Initial Access (Accès initial)
- **Description :** L'attaquant exploite une faille d'une application exposée sur internet (ici : injection SQL sur DVWA) pour obtenir un accès ou extraire des données.
- **Détection (notre SOC) :** Règle Wazuh 100200 sur les logs Apache (motifs `UNION SELECT`, `OR 1=1`). Enrichissement MISP/AbuseIPDB via n8n.
- **Défense :** Requêtes paramétrées, WAF, validation des entrées, mises à jour applicatives.

---

## T1110 — Brute Force
- **Tactique :** Credential Access (Accès aux identifiants)
- **Description :** L'attaquant tente de nombreux mots de passe pour deviner des identifiants valides (ici : SSH).
- **Détection :** Règle de corrélation Wazuh 100300 (5 échecs SSH en 120 s depuis la même IP).
- **Défense :** fail2ban, politique de mots de passe forts, MFA, authentification par clé SSH.

---

## T1078 — Valid Accounts
- **Tactique :** Defense Evasion / Persistence / Initial Access
- **Description :** L'attaquant utilise des identifiants **valides** (volés ou devinés) pour accéder au système en se fondant dans le trafic légitime.
- **Détection :** Règle Wazuh 100301 (connexion SSH réussie juste après une rafale d'échecs = compromission probable).
- **Défense :** MFA, surveillance des connexions anormales (heure, géolocalisation), rotation des mots de passe.

---

## T1204 — User Execution
- **Tactique :** Execution
- **Description :** Un utilisateur exécute un fichier/malware (volontairement ou par ingénierie sociale).
- **Détection :** Règle Wazuh 100211 via Sysmon (exécutable suspect dans Downloads, ex. EICAR). Enrichissement du hash dans MISP.
- **Défense :** Antivirus/EDR, filtrage des pièces jointes, sensibilisation, liste blanche d'applications.

---

## T1053.005 — Scheduled Task/Job: Scheduled Task
- **Tactique :** Persistence / Privilege Escalation / Execution
- **Description :** L'attaquant crée une tâche planifiée pour maintenir sa présence (relancer son malware).
- **Détection :** Sysmon / Wazuh sur la création de tâches planifiées suspectes.
- **Défense :** Surveillance des tâches planifiées, principe du moindre privilège.

---

## T1595 / T1046 — Active Scanning / Network Service Discovery
- **Tactique :** Reconnaissance / Discovery
- **Description :** L'attaquant scanne le réseau (nmap, nikto) pour cartographier les services avant d'attaquer.
- **Détection :** Pics de connexions / erreurs web multiples depuis une même IP.
- **Défense :** Segmentation réseau, réduction de la surface exposée, détection d'anomalies.

---

## T1048 — Exfiltration Over Alternative Protocol
- **Tactique :** Exfiltration
- **Description :** L'attaquant exfiltre des données via un canal détourné (DNS, ICMP).
- **Détection :** Analyse du volume/anomalies DNS et ICMP.
- **Défense :** Inspection DNS, limitation des protocoles sortants, DLP.

---

## Synthèse : matrice de couverture

| Tactique | Technique | Règle Wazuh | État |
|----------|-----------|-------------|------|
| Reconnaissance | T1595/T1046 | (pics d'erreurs) | Partiel |
| Initial Access | T1190 | 100200 | ✅ |
| Execution | T1204 | 100211 | ✅ |
| Persistence | T1053.005 | Sysmon | ✅ |
| Credential Access | T1110 | 100300 | ✅ |
| Defense Evasion | T1078 | 100301 | ✅ |
| Exfiltration | T1048 | — | À faire |
| Threat Intel match | — | 100400 | ✅ |
