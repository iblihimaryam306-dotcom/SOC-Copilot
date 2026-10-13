# Workflow n8n (SOAR) — SOC-Copilot

## Import
1. Ouvrir n8n → menu **⋯** (en haut à droite) → **Import from File**
2. Sélectionner `workflow.json`

## Nœuds du workflow
| Nœud | Rôle |
|------|------|
| **Webhook** | Reçoit l'alerte Wazuh (POST JSON) |
| **IF** | Tri : ne garde que les alertes de gravité ≥ 10 |
| **Edit Fields** | Construit la fiche d'incident (incident, machine, IP, gravité) |
| **AbuseIPDB** | Threat Intel externe (réputation IP) |
| **MISP** | Threat Intel interne (IOC connu ?) |
| **Agent IA** | Appel à Ollama (résumé + recommandation) |
| **Telegram** | Notification à l'analyste |
| **TheHive** | Création automatique d'un cas |
| **MISP-AddIOC** | Ré-injection de l'IP dans MISP (boucle fermée) |

## Secrets à configurer (jamais committer)
- Clé API **AbuseIPDB**
- Clé API **MISP**
- Clé API **TheHive**
- Token & chat ID **Telegram**
- URL **Ollama** (ex. `http://192.168.60.1:11434/api/generate`)

> ⚠️ Exporter le workflow **sans credentials** (n8n ne les inclut pas par défaut dans l'export).

## Placez ici
Déposez votre export `workflow.json` dans ce dossier.
