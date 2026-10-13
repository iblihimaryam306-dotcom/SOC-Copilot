# Configuration Wazuh — SOC-Copilot

## 1. Règles de détection
Copier `custom-rules.xml` dans le manager Wazuh :
```bash
sudo cp custom-rules.xml /var/ossec/etc/rules/local_rules.xml
```

## 2. Intégration n8n (dans `ossec.conf`)
Ajouter dans la section `<ossec_config>` :
```xml
<integration>
  <name>custom-n8n</name>
  <hook_url>http://192.168.60.30:5678/webhook/wazuh</hook_url>
  <level>10</level>
  <alert_format>json</alert_format>
</integration>
```
> Seules les alertes de niveau ≥ 10 sont envoyées au SOAR.

## 3. Liste CDB (Threat Intel) dans `ossec.conf`
Dans la section `<ruleset>`, avant `</ruleset>` :
```xml
<list>etc/lists/misp-malicious-ip</list>
```

## 4. Redémarrage
```bash
sudo systemctl restart wazuh-manager
```

## 5. Test d'une règle
```bash
sudo /var/ossec/bin/wazuh-logtest
# puis coller une ligne de log pour vérifier le déclenchement
```
