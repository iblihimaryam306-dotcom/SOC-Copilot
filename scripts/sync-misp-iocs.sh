#!/bin/bash
# =============================================================
# SOC-Copilot — Synchronisation MISP -> liste CDB Wazuh
# Récupère les IOC (ip-src, to_ids=1) de MISP et génère la
# liste noire consultée par la règle Wazuh 100400.
# Cron conseillé :  0 3 * * *  /var/ossec/etc/lists/sync-misp-iocs.sh
# =============================================================

MISP_URL="https://192.168.60.30"          # <-- adapter à ton MISP
MISP_KEY="YOUR_MISP_API_KEY"               # <-- NE JAMAIS committer la vraie clé
LIST="/var/ossec/etc/lists/misp-malicious-ip"
TMP=$(mktemp)

# Récupère les IP malveillantes depuis MISP
curl -sk -X POST "$MISP_URL/attributes/restSearch" \
  -H "Authorization: $MISP_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"returnFormat":"json","type":"ip-src","to_ids":1}' \
  | jq -r '.response.Attribute[].value' | sort -u | sed 's/$/:malicious/' > "$TMP"

# Sécurité : ne remplace la liste que si on a reçu des données
if [ -s "$TMP" ]; then
    mv "$TMP" "$LIST"
    chown root:wazuh "$LIST"
    COUNT=$(wc -l < "$LIST")
    echo "$(date) - $COUNT IOC synchronises depuis MISP" >> /var/ossec/logs/misp-sync.log
    systemctl restart wazuh-manager
else
    echo "$(date) - ERREUR: aucune donnee MISP, liste inchangee" >> /var/ossec/logs/misp-sync.log
    rm -f "$TMP"
fi
