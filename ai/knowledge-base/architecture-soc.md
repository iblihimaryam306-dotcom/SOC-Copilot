# Architecture du SOC-Copilot (résumé pour l'IA)

## Objectif
SOC open-source complet : détecter, enrichir, corréler, répondre et apprendre, de façon automatisée.

## Les machines (lab VMware)
| Machine | Rôle | Réseau |
|---------|------|--------|
| WAZUH | Manager SIEM (indexer + dashboard) | 192.168.60.x (SOC) |
| SRV-WEB | Cible web DVWA + agent Wazuh | 192.168.30.40 / 192.168.50.40 |
| Windows 11 | Poste utilisateur Sysmon + agent | SOC |
| SOC_TOOLS | n8n, MISP, TheHive | 192.168.60.30 |
| Kali | Attaquant | 192.168.50.10 |

## Les outils et leur rôle
- **Wazuh** (SIEM) : détection sur les logs. « Une attaque a-t-elle eu lieu ? »
- **n8n** (SOAR) : orchestration automatique des alertes.
- **AbuseIPDB** (TI externe) : réputation mondiale d'une IP.
- **MISP** (TI interne) : base d'IOC connus (+7400 via feeds). « Est-ce déjà connu ? »
- **TheHive** (gestion d'incident) : cas, observables, playbooks, métriques.
- **Agent IA local** (Ollama + qwen2.5) : résume et conseille sur chaque alerte, 100% local.

## Le flux complet
```
Kali (attaque)
   ↓
Agents Wazuh (SRV-WEB, Windows) → Manager Wazuh (détection, règles custom + corrélation)
   ↓
n8n : tri (niveau ≥ 10) → fiche
   ├─ AbuseIPDB (réputation externe)
   ├─ MISP (IOC connu ? → menace confirmée)
   ├─ Agent IA (résumé + recommandation)
   ↓
Telegram (notif + analyse IA) + TheHive (cas auto) + MISP (nouvel IOC = boucle fermée)
   ↓
Script sync MISP → liste CDB Wazuh (détection native d'IOC, règle 100400)
```

## Les boucles qui rendent le SOC « intelligent »
1. **Boucle fermée** : chaque IP attaquante est ré-injectée dans MISP → le SOC capitalise le renseignement.
2. **Fusion SIEM + TI** : les IOC de MISP sont exportés vers Wazuh (liste CDB) → détection native.
3. **IA locale** : chaque alerte est analysée et résumée par une IA sur site (souveraineté des données).

## Compétences démontrées (CV Blue Team)
- Detection Engineering (règles + corrélation + MITRE ATT&CK)
- Threat Intelligence (MISP, AbuseIPDB, feeds, TLP)
- SOAR / automatisation (n8n)
- Gestion d'incident (TheHive, MTTD/MTTR)
- IA appliquée à la cybersécurité (LLM local)
