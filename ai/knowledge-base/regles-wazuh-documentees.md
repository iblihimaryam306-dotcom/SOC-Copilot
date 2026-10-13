# Règles Wazuh personnalisées — SOC-Copilot (documentation)

> Fichier : `/var/ossec/etc/rules/local_rules.xml` sur le manager Wazuh.
> Chaque règle est expliquée : rôle, logique, niveau, mapping MITRE.

---

## Règle 100200 — Détection d'injection SQL
```xml
<rule id="100200" level="12">
  <if_sid>31103</if_sid>
  <description>Multiple SQL injection attempts - web application attack</description>
  <mitre><id>T1190</id></mitre>
</rule>
```
- **Rôle :** détecter une injection SQL sur l'application web (DVWA).
- **Logique :** `if_sid 31103` = s'appuie sur la règle native Wazuh qui repère les motifs SQLi dans les logs Apache.
- **Niveau 12 :** critique → déclenche l'alerte vers n8n.
- **MITRE :** T1190 (Exploit Public-Facing Application).

---

## Règle 100211 — Exécutable malveillant dans Downloads
```xml
<rule id="100211" level="12">
  <if_sid>92203</if_sid>
  <description>Executable malveillant detecte dans Downloads</description>
  <mitre><id>T1204</id></mitre>
</rule>
```
- **Rôle :** détecter un malware déposé/exécuté sur le poste Windows.
- **Logique :** s'appuie sur Sysmon (création de processus/fichier). Testé avec EICAR.
- **MITRE :** T1204 (User Execution).

---

## Règles de corrélation 100300 / 100301 — Brute force SSH → compromission
```xml
<rule id="100300" level="10" frequency="5" timeframe="120">
  <if_matched_sid>5760</if_matched_sid>
  <same_source_ip />
  <description>Multiples echecs d'authentification SSH depuis la meme IP (brute force)</description>
  <mitre><id>T1110</id></mitre>
</rule>

<rule id="100301" level="12">
  <if_sid>5715</if_sid>
  <if_matched_sid>100300</if_matched_sid>
  <same_source_ip />
  <description>Connexion SSH reussie apres brute force - compromission probable</description>
  <mitre><id>T1110</id><id>T1078</id></mitre>
</rule>
```
- **100300 :** compte 5 échecs SSH (règle native 5760) en 120 s depuis la **même IP** → brute force.
- **100301 :** si une **connexion réussie** (5715) survient après ce brute force, depuis la même IP → **compromission probable**.
- **C'est de la corrélation multi-étapes** : on relie plusieurs événements pour détecter un scénario d'attaque, pas juste un événement isolé.
- **MITRE :** T1110 (Brute Force) + T1078 (Valid Accounts).

---

## Règle 100400 — Détection native d'IOC (Threat Intel)
```xml
<rule id="100400" level="12">
  <if_group>web</if_group>
  <list field="srcip" lookup="address_match_key">etc/lists/misp-malicious-ip</list>
  <description>Threat Intel - IP source presente dans MISP (IOC malveillant connu)</description>
  <mitre><id>T1190</id></mitre>
</rule>
```
- **Rôle :** lever une alerte dès qu'une IP source est présente dans la **liste noire synchronisée depuis MISP** (fichier CDB `misp-malicious-ip`, ~7400 IOC réels).
- **Logique :** `<list>` consulte la liste CDB ; `address_match_key` compare l'IP source du log aux IP de la liste.
- **C'est la fusion SIEM + Threat Intelligence** : Wazuh détecte « qui » est l'attaquant, pas seulement « ce qu'il fait ».
- **Synchro :** script `sync-misp-iocs.sh` (cron quotidien) qui interroge l'API MISP et régénère la liste.

---

## Concepts Wazuh importants (pour expliquer)
- **if_sid :** la règle se déclenche si une règle précise (SID) a matché.
- **if_group :** la règle s'évalue sur tous les événements d'un groupe (ex. `web`).
- **if_matched_sid + frequency + timeframe :** corrélation — compter N occurrences d'une règle dans une fenêtre de temps.
- **same_source_ip :** la corrélation ne compte que les événements venant de la **même IP**.
- **list / lookup :** consulter une liste CDB (base clé-valeur rapide) pour matcher IP/hash/domaines.
- **Niveaux :** 0–15 ; ≥ 10 = critique (déclenche l'intégration n8n chez nous).
