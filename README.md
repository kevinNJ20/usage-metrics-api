# 🚀 Usage Metrics API - Backend Mulesoft

API Mulesoft 4 pour collecter, exposer et monitorer les métriques d'utilisation d'Anypoint Platform via l'API Usage Metering.

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation Rapide](#-installation-rapide)
- [Configuration](#-configuration)
- [Structure du projet](#-structure-du-projet)
- [API Reference](#-api-reference)
- [Monitoring & Alertes](#-monitoring--alertes)
- [Développement](#-développement)
- [Déploiement](#-déploiement)
- [Dépannage](#-dépannage)
- [Support](#-support)

## 🎯 Vue d'ensemble

### Objectif

Cette API sert de passerelle entre l'Anypoint Usage API et vos applications frontend/monitoring. Elle centralise la collecte des métriques de consommation pour :
- **Optimiser les coûts** en surveillant l'utilisation des ressources
- **Prévenir les dépassements** de limites contractuelles
- **Automatiser les alertes** via Slack pour une réactivité maximale
- **Fournir des dashboards** temps réel sur l'usage de la plateforme

### Cas d'usage principaux

1. **Dashboard de monitoring** : Visualisation temps réel de l'utilisation
2. **Alerting proactif** : Notifications Slack avant dépassement de limites
3. **Reporting mensuel** : Extraction des données pour facturation/analyse
4. **Capacity planning** : Anticipation des besoins en ressources

### Points Clés

- ✅ **Token Management automatique** avec cache Object Store (3500s TTL)
- ✅ **Monitoring horaire** avec alertes Slack multi-niveaux
- ✅ **Support CORS** pour intégration frontend sans proxy
- ✅ **Parallel processing** avec Scatter-Gather pour performance optimale
- ✅ **Classification automatique** par type d'environnement
- ✅ **Historique des alertes** conservé 30 jours

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Dashboard                       │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP/REST
┌────────────────────▼────────────────────────────────────────┐
│                   Usage Metrics API                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  HTTP Listener                       │    │
│  │                   (Port 8081)                        │    │
│  └──────────┬──────────────────────┬──────────────────┘    │
│             │                      │                         │
│  ┌──────────▼────────┐  ┌─────────▼──────────┐            │
│  │  API Endpoints    │  │  Scheduler Flow    │             │
│  │  • /api/meters    │  │  (Every Hour)      │             │
│  │  • /api/dashboard │  └─────────┬──────────┘             │
│  │  • /api/metrics/* │            │                         │
│  └──────────┬────────┘  ┌─────────▼──────────┐             │
│             │            │  Monitor Limits    │             │
│  ┌──────────▼────────┐  │  • Runtime Flows   │             │
│  │  Token Manager    │  │  • Governed APIs   │             │
│  │  OAuth2 + Cache   │  │  • Managed APIs    │             │
│  └──────────┬────────┘  └─────────┬──────────┘             │
│             │                      │                         │
└─────────────┼──────────────────────┼────────────────────────┘
              │                      │
    ┌─────────▼──────────┐ ┌────────▼─────────┐
    │  Anypoint Usage    │ │   Slack API      │
    │       API          │ │  Notifications   │
    └────────────────────┘ └──────────────────┘
```

### Composants principaux

| Composant | Description | Fichier |
|-----------|-------------|---------|
| **API Gateway** | Expose les endpoints REST avec CORS | `usage-metrics-api.xml` |
| **Token Manager** | Gestion automatique des tokens OAuth2 | `usage-metrics-api.xml` |
| **Monitor Scheduler** | Surveillance horaire avec alertes | `usage-monitor-scheduler.xml` |
| **Data Aggregator** | Consolidation parallèle des métriques | `usage-metrics-api.xml` |
| **Slack Notifier** | Envoi d'alertes structurées | `usage-monitor-scheduler.xml` |

## ✨ Fonctionnalités

### 1. Collecte de Métriques

- **Runtime Flows** : Nombre de flux Mule déployés par application
- **API Manager** : APIs managées par environnement (prod/preprod/unclassified)
- **Governed APIs** : APIs sous gouvernance Anypoint
- **Network Usage** : Bande passante consommée par application

### 2. Monitoring Automatique

- **Vérification horaire** des limites d'usage
- **Alertes à 2 niveaux** : WARNING (80%) et CRITICAL (100%)
- **Notifications Slack** enrichies avec graphiques
- **Historique conservé** 30 jours dans Object Store

### 3. API REST Complète

- **Endpoints granulaires** pour chaque type de métrique
- **Endpoint Dashboard** agrégé pour vue d'ensemble
- **Support des filtres** : orgId, envType, timeSeries
- **Formats TimeSeries** : P1D (jour), P1M (mois)

### 4. Gestion Intelligente des Environnements

Mapping automatique des environnements :
- **Production** : `242b6f0c-7f5c-4c31-92f1-4257e182e885`
- **Sandbox/Préproduction** : `1f157a54-15ca-491e-ac7f-77c662f71d9c`
- **Non-classifié** : Autres environnements

## 📦 Prérequis

| Composant | Version Minimum | Recommandé | Notes |
|-----------|----------------|------------|-------|
| **Mule Runtime** | 4.4.0 | 4.9.8 | Support Java 17 |
| **Java JDK** | 17 | 17 | Version LTS |
| **Maven** | 3.6.0 | 3.9.x | Pour build |
| **Anypoint Studio** | 7.15.0 | Latest | Optionnel |
| **Slack Workspace** | - | - | Pour alertes |

### Permissions Anypoint Requises

- ✅ **Usage API Reader** : Lecture des métriques
- ✅ **Organization Administrator** : Pour OAuth2 client credentials
- ✅ **Environment Access** : Sur les environnements à monitorer

## 🚀 Installation Rapide

### Option 1 : Démarrage Express (5 min)

```bash
# 1. Clone
git clone <votre-repo>
cd usage-metrics-api

# 2. Configuration minimale
echo "anypoint.client.id=YOUR_CLIENT_ID" >> src/main/resources/config.properties
echo "anypoint.client.secret=YOUR_SECRET" >> src/main/resources/config.properties

# 3. Build & Run
mvn clean package mule:run

# 4. Test
curl http://localhost:8081/api/meters
```

### Option 2 : Installation Complète avec Monitoring

```bash
# 1. Clone et configuration
git clone <votre-repo>
cd usage-metrics-api

# 2. Configuration complète
cp src/main/resources/config.properties.template src/main/resources/config.properties
# Éditer config.properties avec vos credentials

# 3. Build
mvn clean package

# 4. Configuration Slack (optionnel)
# Dans usage-monitor-scheduler.xml, configurer :
# - slack.channel
# - Limites d'alerte (limit.*.warning/critical)

# 5. Démarrage
mvn mule:run -Dmule.env=dev

# 6. Vérification
curl http://localhost:8081/api/test-monitor  # Test du monitoring
```

## ⚙️ Configuration

### 1. Configuration de Base (`config.properties`)

```properties
# === Configuration HTTP ===
http.port=8081                    # Port d'écoute de l'API

# === Credentials Anypoint (OBLIGATOIRE) ===
anypoint.client.id=YOUR_CLIENT_ID_HERE
anypoint.client.secret=YOUR_CLIENT_SECRET_HERE

# === Configuration Régionale ===
# US : https://anypoint.mulesoft.com
# EU : https://eu1.anypoint.mulesoft.com (défaut)
# GOV : https://gov.anypoint.mulesoft.com
anypoint.base.url=https://eu1.anypoint.mulesoft.com

# === Gestion des Tokens ===
token.ttl=3500                    # Durée de vie du token en secondes

# === Paramètres par défaut ===
default.timeseries=P1D             # P1D (jour), P1M (mois)
default.days.back=30               # Historique par défaut
```

### 2. Configuration du Monitoring (`usage-monitor-scheduler.xml`)

```xml
<!-- Limites pour les alertes -->
<global-property name="limit.flows.warning" value="250" />      <!-- 80% de 300 -->
<global-property name="limit.flows.critical" value="300" />     <!-- Limite max -->
<global-property name="limit.governed.warning" value="9" />     <!-- 75% de 12 -->
<global-property name="limit.governed.critical" value="12" />   <!-- Limite max -->
<global-property name="limit.managed.warning" value="9" />      <!-- Par env type -->
<global-property name="limit.managed.critical" value="12" />    

<!-- Organisation à monitorer -->
<global-property name="org.id" value="f22cd53d-c1ea-482e-a6e6-2d367ba7e48e" />
<global-property name="org.name" value="BNDE" />

<!-- Canal Slack pour les alertes -->
<global-property name="slack.channel" value="#bnde-alerts" />
```

### 3. Configuration Slack

1. **Créer une App Slack** : https://api.slack.com/apps
2. **Ajouter OAuth Scopes** : `chat:write`
3. **Installer dans votre workspace**
4. **Configurer dans l'API** :
   - Consumer Key : `917880024448.9410043447527`
   - Consumer Secret : `615fc735ba92562890cca25be24b6989`
   - Callback URL : `https://localhost:8081/callback`

## 📁 Structure du projet

```
usage-metrics-api/
├── 📁 src/
│   ├── 📁 main/
│   │   ├── 📁 mule/
│   │   │   ├── 📄 usage-metrics-api.xml         # API principale
│   │   │   └── 📄 usage-monitor-scheduler.xml   # Monitoring & alertes
│   │   └── 📁 resources/
│   │       ├── 📄 config.properties             # Configuration
│   │       └── 📄 log4j2.xml                    # Logs configuration
│   └── 📁 test/
│       └── 📁 resources/
│           └── 📄 log4j2-test.xml               # Logs tests
├── 📄 pom.xml                                    # Dépendances Maven
├── 📄 mule-artifact.json                         # Métadonnées Mule
├── 📄 .gitignore                                 # Git exclusions
└── 📄 README.md                                  # Documentation
```

## 📡 API Reference

### Endpoints Disponibles

| Méthode | Endpoint | Description | Authentification |
|---------|----------|-------------|------------------|
| GET | `/api/meters` | Liste des métriques disponibles | Non |
| POST | `/api/dashboard` | Dashboard agrégé complet | Non |
| POST | `/api/metrics/runtime-flows` | Flux runtime détaillés | Non |
| POST | `/api/metrics/api-manager` | APIs managées par env | Non |
| POST | `/api/metrics/governed-apis` | APIs gouvernées | Non |
| POST | `/api/metrics/network-usage` | Usage réseau | Non |
| GET | `/api/test-monitor` | Test manuel du monitoring | Non |
| OPTIONS | `/*` | Support CORS | Non |

### Exemples d'Utilisation

#### 1. Dashboard Complet

```bash
curl -X POST http://localhost:8081/api/dashboard \
  -H "Content-Type: application/json" \
  -d '{
    "startTime": 1704067200000,
    "endTime": 1706745599000,
    "timeSeries": "P1D",
    "orgId": "f22cd53d-c1ea-482e-a6e6-2d367ba7e48e",
    "envType": "production"
  }'
```

**Réponse** :
```json
{
  "success": true,
  "timestamp": "2024-01-31T12:00:00Z",
  "data": {
    "runtimeFlows": {
      "data": [
        {
          "org_id": "f22cd53d-c1ea-482e-a6e6-2d367ba7e48e",
          "env_name": "Production",
          "app_name": "order-api",
          "mule_flow_count": 45
        }
      ]
    },
    "apiManager": {
      "data": [
        {
          "env_type": "production",
          "managed_api_count": 12
        }
      ]
    },
    "summary": {
      "totalFlows": 1250,
      "totalManagedApis": 45,
      "totalGovernedApis": 38,
      "environments": ["Production", "Sandbox"],
      "applications": ["order-api", "customer-api"]
    }
  }
}
```

#### 2. Métriques Spécifiques

```bash
# Runtime Flows uniquement
curl -X POST http://localhost:8081/api/metrics/runtime-flows \
  -H "Content-Type: application/json" \
  -d '{
    "startTime": 1704067200000,
    "endTime": 1706745599000,
    "timeSeries": "P1M",
    "envType": "sandbox"
  }'
```

#### 3. Test du Monitoring

```bash
# Déclenche manuellement la vérification des limites
curl http://localhost:8081/api/test-monitor

# Réponse avec les alertes détectées
{
  "success": true,
  "message": "Test de monitoring terminé",
  "alertsSent": 2,
  "alerts": [
    {
      "level": "WARNING",
      "type": "Runtime Flows",
      "message": "⚠️ ATTENTION - Approche de la limite",
      "value": 280,
      "limit": 250
    }
  ]
}
```

### Paramètres de Requête

| Paramètre | Type | Obligatoire | Description | Valeurs |
|-----------|------|------------|-------------|---------|
| `startTime` | Number | Oui | Timestamp début (ms) | Ex: 1704067200000 |
| `endTime` | Number | Oui | Timestamp fin (ms) | Ex: 1706745599000 |
| `timeSeries` | String | Non | Granularité | P1D, P1M |
| `orgId` | String | Non | ID Organisation | UUID |
| `envType` | String | Non | Type environnement | production, sandbox, unclassified |

### Codes de Réponse

| Code | Description | Action Recommandée |
|------|-------------|-------------------|
| 200 | Succès | Traiter les données |
| 401 | Non autorisé | Vérifier les credentials |
| 500 | Erreur serveur | Vérifier les logs |
| 503 | Service indisponible | Réessayer plus tard |

## 🔔 Monitoring & Alertes

### Configuration des Alertes

Le système surveille automatiquement 3 types de métriques :

| Métrique | Warning | Critical | Fréquence |
|----------|---------|----------|-----------|
| **Runtime Flows** | 250 | 300 | Horaire |
| **Governed APIs** | 9 | 12 | Horaire |
| **Managed APIs** | 9 | 12 | Horaire |

### Format des Alertes Slack

Les alertes sont structurées avec :
- **Niveau** : 🚨 CRITICAL ou ⚠️ WARNING
- **Type** : Métrique concernée
- **Détails** : Valeur actuelle vs limite
- **Timestamp** : Heure de détection
- **Environnement** : Si applicable

Exemple d'alerte Slack :
```
🚨 ALERTE CRITIQUE - Anypoint Usage Monitor
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Runtime Flows
Limite de flux runtime dépassée!
• Valeur actuelle : 305 flux
• Limite : 300
• Environnement : PRODUCTION
• Timestamp : 2024-01-31 14:30:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Historique des Alertes

- Stocké dans Object Store pendant 30 jours
- Consultable via les logs
- Format JSON pour intégration externe

## 💻 Développement

### Environnement Local

```bash
# 1. Installation des dépendances
mvn clean install

# 2. Démarrage en mode debug
mvn mule:run -Dmule.env=dev -Dmule.debug=true

# 3. Attachement debugger (port 5005)
# Dans Studio ou IDE : Remote Debug Configuration
```

### Tests

```bash
# Tests unitaires MUnit
mvn test

# Tests avec coverage
mvn clean test munit:coverage-report

# Rapport disponible dans : target/site/munit/coverage/
```

### Bonnes Pratiques DataWeave

```dataweave
// Gestion des nulls avec valeur par défaut
payload.orgId default ""

// Formatage des dates
now() as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}

// Agrégation sécurisée
sum(payload.data.mule_flow_count default []) default 0

// Filtrage des doublons
(payload.data.env_name default []) distinctBy $

// Transformation conditionnelle
if (lower(payload.envType) == "production") 
  "PROD" 
else if (lower(payload.envType) == "sandbox") 
  "PREPROD"
else 
  "UNCLASSIFIED"
```

### Structure des Logs

```
# Niveau INFO - Opérations normales
INFO  2024-01-31 14:30:00 [MONITOR] Début de la vérification des limites
INFO  2024-01-31 14:30:05 [MONITOR] Nombre total de flux runtime: 280 / 300

# Niveau WARN - Approche des limites
WARN  2024-01-31 14:30:10 [MONITOR] Limite WARNING atteinte: Runtime Flows (280/250)

# Niveau ERROR - Erreurs techniques
ERROR 2024-01-31 14:30:15 [MONITOR] Erreur Slack API: Connection timeout
```

## 🚀 Déploiement

### CloudHub 2.0

```bash
# Déploiement via Maven
mvn clean deploy -DmuleDeploy \
  -Danypoint.uri=https://anypoint.mulesoft.com \
  -Danypoint.username=YOUR_USERNAME \
  -Danypoint.password=YOUR_PASSWORD \
  -Danypoint.environment=Production \
  -Danypoint.region=eu-central-1 \
  -Danypoint.workers=0.1 \
  -Danypoint.workerType=MICRO \
  -Danypoint.applicationName=usage-metrics-api-prod
```

### Configuration CloudHub

Propriétés à configurer dans Runtime Manager :
```properties
http.port=${http.port}
anypoint.client.id=${secure::anypoint.client.id}
anypoint.client.secret=${secure::anypoint.client.secret}
slack.webhook.url=${secure::slack.webhook.url}
```

### Docker (On-Premise)

```dockerfile
# Dockerfile
FROM mulesoft/mule-runtime:4.9.8-java17
COPY target/usage-metrics-api-*.jar /opt/mule/apps/
ENV MULE_ENV=prod
EXPOSE 8081
```

```bash
# Build et run
docker build -t usage-metrics-api:latest .
docker run -d \
  -p 8081:8081 \
  -e ANYPOINT_CLIENT_ID=xxx \
  -e ANYPOINT_CLIENT_SECRET=xxx \
  --name usage-metrics \
  usage-metrics-api:latest
```

## 🔧 Dépannage

### Problèmes Fréquents et Solutions

#### 1. Erreur 401 - Authentification

**Symptôme** : `HTTP:UNAUTHORIZED`

**Solutions** :
```bash
# Vérifier les credentials
curl -X POST https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token \
  -d "grant_type=client_credentials" \
  -d "client_id=YOUR_ID" \
  -d "client_secret=YOUR_SECRET"

# Vérifier les permissions dans Anypoint
# Access Management > Connected Apps > Votre App > Scopes
```

#### 2. Pas de Données Retournées

**Causes possibles** :
- Délai de 3 jours pour les données Usage API
- Mauvais Organization ID
- TimeSeries inapproprié

**Debug** :
```bash
# Vérifier l'org ID
curl http://localhost:8081/api/meters

# Tester avec une période plus large
{
  "startTime": 1672531200000,  # 1 Jan 2023
  "endTime": 1706745599000,    # 31 Jan 2024
  "timeSeries": "P1M"           # Mensuel pour grandes périodes
}
```

#### 3. Alertes Slack Non Reçues

**Vérifications** :
1. Token OAuth Slack valide
2. Bot ajouté au canal
3. Permissions `chat:write`
4. Canal correct dans config

**Test manuel** :
```bash
curl http://localhost:8081/api/test-monitor
```

#### 4. Performance Lente

**Optimisations** :
- Utiliser P1M pour périodes > 30 jours
- Réduire la période de requête
- Augmenter les workers CloudHub
- Vérifier la région (latence)

### Logs Utiles pour Debug

```bash
# Activer logs DEBUG
echo "AsyncLogger name=\"org.mule\" level=\"DEBUG\"/>" >> src/main/resources/log4j2.xml

# Suivre les logs en temps réel
tail -f logs/usage-metrics-api.log | grep -E "(ERROR|WARN|MONITOR)"

# Analyser les tokens
grep "bearer_token" logs/usage-metrics-api.log
```

## 📚 Ressources

### Documentation Officielle
- [Anypoint Usage API](https://anypoint.mulesoft.com/exchange/portals/anypoint-platform/usage-api/)
- [Mule 4 Documentation](https://docs.mulesoft.com/mule-runtime/4.4/)
- [DataWeave 2.0](https://docs.mulesoft.com/dataweave/2.4/)
- [Slack API](https://api.slack.com/messaging/sending)

### Exemples et Templates
- [MuleSoft Examples](https://github.com/mulesoft/examples)
- [DataWeave Playground](https://dataweave.mulesoft.com/)

## 👥 Support

| Canal | Usage | Réponse |
|-------|-------|---------|
| **GitHub Issues** | Bugs, feature requests | 48h |
| **MuleSoft Support** | Issues production | 24h (selon SLA) |
| **Community Forum** | Questions générales | Variable |
| **Stack Overflow** | Questions techniques | Variable |

### Contacts Techniques

- **Lead Developer** : knjundja@jasmineconseil.com
- **Slack Channel** : #bnde-alerts

## 📄 Licence

Propriétaire - © 2025 BNDE. Tous droits réservés.

## 🙏 Remerciements

Développé avec ❤️ pour optimiser l'utilisation d'Anypoint Platform et réduire les coûts opérationnels.

---

**Version** : 1.0.0-SNAPSHOT  
**Dernière mise à jour** : Aout 2025  
**Statut** : 🟢 Production Ready
