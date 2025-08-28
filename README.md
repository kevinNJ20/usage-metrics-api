# 🚀 Usage Metrics API - Backend Mulesoft

API Mulesoft 4 pour collecter et exposer les métriques d'utilisation d'Anypoint Platform via l'API Usage Metering.

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Structure du projet](#-structure-du-projet)
- [Flux et Endpoints](#-flux-et-endpoints)
- [Métriques Disponibles](#-métriques-disponibles)
- [Développement](#-développement)
- [Déploiement](#-déploiement)
- [Monitoring](#-monitoring)
- [Dépannage](#-dépannage)
- [Contribution](#-contribution)

## 🎯 Vue d'ensemble

Cette API Mulesoft sert d'interface entre l'Anypoint Usage API et le dashboard frontend. Elle gère :
- **Authentification OAuth2** : Génération et cache automatique des tokens
- **Collecte de métriques** : Flux runtime, APIs managées, APIs gouvernées, utilisation réseau
- **Agrégation de données** : Endpoint dashboard combinant toutes les métriques
- **Classification par environnement** : Production, Sandbox/Préproduction, Non-classifié

### Points Clés

- ✅ **Gestion automatique des tokens** avec Object Store
- ✅ **Support CORS** pour intégration frontend
- ✅ **Parallel processing** avec Scatter-Gather
- ✅ **Error handling** global
- ✅ **Support des TimeSeries** (P1D journalier, P1M mensuel)

## 🏗 Architecture

```
API Mulesoft 4
    │
    ├── HTTP Listener (port 8081)
    │   └── Routes API REST
    │
    ├── Token Management
    │   ├── OAuth2 Client Credentials
    │   └── Object Store (cache 3500s)
    │
    ├── Anypoint Usage API
    │   ├── Meters endpoints
    │   └── Search endpoints
    │
    └── Data Processing
        ├── DataWeave transformations
        └── Scatter-Gather aggregation
```

### Flux Principaux

1. **Token Management** : Sous-flux réutilisable pour l'authentification
2. **Meters Discovery** : Découverte des métriques disponibles
3. **Metrics Collection** : Collecte par type de métrique
4. **Dashboard Aggregation** : Agrégation parallèle de toutes les métriques

## 📦 Prérequis

- **Mule Runtime** : 4.4.0 ou supérieur (testé avec 4.9.8)
- **Java** : JDK 17
- **Maven** : 3.6.0 ou supérieur
- **Anypoint Studio** : 7.15.0 ou supérieur (optionnel)
- **Anypoint Account** : 
  - Client ID et Secret avec accès Usage API
  - Permissions : Usage API Reader minimum

## 🚀 Installation

### 1. Cloner le projet

```bash
git clone <votre-repo>
cd usage-metrics-api
```

### 2. Configuration des credentials

```bash
# Éditer le fichier de configuration
nano src/main/resources/config.properties
```

```properties
# HTTP Configuration
http.port=8081

# Anypoint Platform Credentials (OBLIGATOIRE)
anypoint.client.id=65dbfe82af0b4e3eb7c745f1d6d8e3db
anypoint.client.secret=E1cD10e3895C4e37a24261d850faD91F

# API Base URL (EU region par défaut)
anypoint.base.url=https://eu1.anypoint.mulesoft.com

# Token TTL (en secondes)
token.ttl=3500

# Default Query Parameters
default.timeseries=P1D
default.days.back=30
```

### 3. Build du projet

```bash
# Build avec Maven
mvn clean package

# Ou dans Anypoint Studio
# Import > Anypoint Studio > Packaged mule application (.jar)
```

### 4. Démarrage local

```bash
# Avec Maven
mvn mule:run

# Ou dans Studio
# Run As > Mule Application
```

### 5. Vérification

```bash
# Test de santé
curl http://localhost:8081/api/meters

# Devrait retourner la liste des meters disponibles
```

## ⚙️ Configuration

### Configuration Properties

Le fichier `src/main/resources/config.properties` contient :

| Propriété | Description | Valeur par défaut |
|-----------|-------------|-------------------|
| `http.port` | Port d'écoute HTTP | 8081 |
| `anypoint.client.id` | Client ID Anypoint | (requis) |
| `anypoint.client.secret` | Client Secret Anypoint | (requis) |
| `anypoint.base.url` | URL base Anypoint | https://eu1.anypoint.mulesoft.com |
| `token.ttl` | Durée de vie du token (sec) | 3500 |
| `default.timeseries` | TimeSeries par défaut | P1D |
| `default.days.back` | Jours historique par défaut | 30 |

### Régions Anypoint

Pour changer de région, modifier `anypoint.base.url` :
- **US** : `https://anypoint.mulesoft.com`
- **EU** : `https://eu1.anypoint.mulesoft.com`
- **GOV** : `https://gov.anypoint.mulesoft.com`

### Object Store Configuration

L'Object Store pour le cache de token est configuré avec :
- **Persistant** : Non (mémoire)
- **Max Entries** : 10
- **Entry TTL** : 3500 secondes
- **TTL Unit** : SECONDS

## 📁 Structure du projet

```
usage-metrics-api/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   └── usage-metrics-api.xml    # Configuration des flux
│   │   └── resources/
│   │       ├── config.properties        # Configuration
│   │       └── log4j2.xml              # Configuration logs
│   └── test/
│       └── resources/
│           └── log4j2-test.xml         # Logs pour tests
├── pom.xml                              # Configuration Maven
├── mule-artifact.json                   # Métadonnées Mule
├── exchange-docs/                       # Documentation Exchange
└── README.md                           # Cette documentation
```

## 📡 Flux et Endpoints

### 1. Token Management

**Sub-flow: `get-access-token`**
- Vérifie le cache Object Store
- Génère un nouveau token si nécessaire
- Stocke le token pour réutilisation

**Sub-flow: `generate-new-token`**
- Appel OAuth2 Client Credentials
- Parse et stocke le token
- TTL: 3500 secondes

### 2. Endpoints API

#### GET /api/meters
**Description** : Liste tous les meters disponibles

**Réponse** :
```json
{
  "meters": [
    "runtime_flow_count",
    "api_manager_api_instance_count_prod",
    "api_manager_api_instance_count_preprod",
    "api_manager_api_instance_count_unclassified",
    "governed_api_count",
    "runtime_network_bytes_count"
  ]
}
```

#### POST /api/dashboard
**Description** : Agrège toutes les métriques en une seule requête

**Requête** :
```json
{
  "startTime": 1704067200000,
  "endTime": 1706745599000,
  "timeSeries": "P1D",
  "orgId": "f22cd53d-c1ea-482e-a6e6-2d367ba7e48e",
  "envType": "production"  // Optionnel
}
```

**Réponse** :
```json
{
  "success": true,
  "timestamp": "2024-01-31T12:00:00Z",
  "data": {
    "runtimeFlows": { /* données */ },
    "apiManager": { /* données */ },
    "governedApis": { /* données */ },
    "summary": {
      "totalFlows": 1250,
      "totalManagedApis": 45,
      "totalGovernedApis": 38,
      "environments": ["Production", "Sandbox"],
      "applications": ["App1", "App2"]
    }
  }
}
```

#### POST /api/metrics/runtime-flows
**Description** : Métriques des flux runtime

**Query SQL généré** :
```sql
SELECT org_id, org_name, env_id, env_name, env_type, 
       asset_id, app_name, deployment_model, 
       mule_flow_count, num_workers 
FROM runtime_flow_count 
WHERE timestamp between {startTime} and {endTime}
  AND org_id = '{orgId}'
TIMESERIES P1D
```

#### POST /api/metrics/api-manager
**Description** : APIs managées par type d'environnement

**Tables utilisées** :
- `api_manager_api_instance_count_prod` (production)
- `api_manager_api_instance_count_preprod` (sandbox/preproduction)
- `api_manager_api_instance_count_unclassified` (non-classifié)

#### POST /api/metrics/governed-apis
**Description** : APIs sous gouvernance

#### POST /api/metrics/network-usage
**Description** : Utilisation de la bande passante réseau

### 3. CORS Handler

**Flow: `options-handler`**
- Gère les requêtes OPTIONS pour CORS
- Headers configurés :
  - `Access-Control-Allow-Origin: *`
  - `Access-Control-Allow-Methods: GET, POST, OPTIONS`
  - `Access-Control-Allow-Headers: Content-Type, Authorization`

## 📊 Métriques Disponibles

### Runtime Flow Count
- **Meter** : `runtime_flow_count`
- **Données** : Nombre de flux Mule par application
- **Dimensions** : org_id, env_id, app_name

### API Manager Instance Count
- **Meters** : 
  - `api_manager_api_instance_count_prod`
  - `api_manager_api_instance_count_preprod`
  - `api_manager_api_instance_count_unclassified`
- **Données** : APIs managées par environnement
- **Dimensions** : org_id, env_type, runtime

### Governed API Count
- **Meter** : `governed_api_count`
- **Données** : APIs gouvernées dans Anypoint
- **Dimensions** : org_id

### Network Bytes Count
- **Meter** : `runtime_network_bytes_count`
- **Données** : Bytes transférés sur le réseau
- **Dimensions** : org_id, env_id, app_name

### TimeSeries Support

- **P1D** : Données journalières (max 30 jours)
- **P1M** : Données mensuelles (pour périodes > 30 jours)
- **P1H** : Données horaires (pour analyses détaillées)

## 💻 Développement

### Environnement de développement

1. **Anypoint Studio**
   - Import du projet comme Mule Application
   - Configuration automatique des dépendances

2. **VS Code / IntelliJ**
   - Extensions Mule/DataWeave recommandées
   - Maven pour build et tests

### Tests

```bash
# Lancer les tests MUnit
mvn test

# Tests avec coverage
mvn clean test munit:coverage-report
```

### Debug

1. **Dans Studio** :
   - Debug As > Mule Application
   - Breakpoints supportés dans les flux

2. **Logs** :
   - Niveau INFO par défaut
   - Fichier : `logs/usage-metrics-api.log`
   - Console en mode dev

### DataWeave Tips

```dataweave
// Gestion des valeurs nulles
payload.orgId default ""

// Formatage des timestamps
now() as String {format: "yyyy-MM-dd'T'HH:mm:ss'Z'"}

// Agrégation
sum(payload.data.mule_flow_count default [])

// Distinct values
(payload.data.env_name default []) distinctBy $
```

## 🚀 Déploiement

### CloudHub

```bash
# Déploiement via Maven
mvn mule:deploy -DmuleDeploy.uri=https://anypoint.mulesoft.com \
  -DmuleDeploy.username=YOUR_USERNAME \
  -DmuleDeploy.password=YOUR_PASSWORD \
  -DmuleDeploy.environment=Production \
  -DmuleDeploy.region=eu-central-1 \
  -DmuleDeploy.workers=1 \
  -DmuleDeploy.workerType=MICRO \
  -DmuleDeploy.applicationName=usage-metrics-api

# Via Anypoint Platform UI
# Runtime Manager > Deploy Application > Upload usage-metrics-api.jar
```

### On-Premise (Hybrid)

```bash
# Copier le JAR dans apps/
cp target/usage-metrics-api-1.0.0-SNAPSHOT-mule-application.jar $MULE_HOME/apps/

# L'application démarre automatiquement
tail -f $MULE_HOME/logs/usage-metrics-api.log
```

### Docker

```dockerfile
# Dockerfile
FROM mulesoft/mule-runtime:4.9.8
COPY target/*.jar /opt/mule/apps/
EXPOSE 8081
```

```bash
docker build -t usage-metrics-api .
docker run -p 8081:8081 usage-metrics-api
```

## 📈 Monitoring

### Health Check

```bash
# Endpoint santé simple
curl http://localhost:8081/api/meters

# Vérifier le token
curl -X POST http://localhost:8081/api/dashboard \
  -H "Content-Type: application/json" \
  -d '{"startTime": 1704067200000, "endTime": 1706745599000}'
```

### Métriques JMX

Activer JMX pour monitoring :
```properties
# wrapper.conf ou arguments JVM
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=1099
-Dcom.sun.management.jmxremote.authenticate=false
```

### Logs

Configuration dans `log4j2.xml` :
- **Level** : INFO en production, DEBUG en dev
- **Rolling** : 10MB par fichier, max 10 fichiers
- **Pattern** : Inclut correlationId et processorPath

## 🔧 Dépannage

### Problèmes Courants

#### 1. Erreur d'authentification

```
Error: HTTP:UNAUTHORIZED
```

**Solutions** :
- Vérifier client_id et client_secret
- Vérifier les permissions sur Anypoint
- Tester directement l'API :

```bash
curl -X POST https://eu1.anypoint.mulesoft.com/accounts/api/v2/oauth2/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "client_credentials",
    "client_id": "YOUR_ID",
    "client_secret": "YOUR_SECRET"
  }'
```

#### 2. Pas de données retournées

**Vérifications** :
- Les données ont un délai de 3 jours
- Vérifier l'Organization ID
- TimeSeries approprié (P1D pour < 30 jours)
- Filtres d'environnement corrects

#### 3. Timeout sur les requêtes

**Solutions** :
- Augmenter le timeout HTTP Request
- Réduire la période de requête
- Utiliser P1M pour grandes périodes

#### 4. Object Store errors

```
OS:KEY_NOT_FOUND
```

**Normal** lors du premier appel, le token sera généré.

### IDs d'Environnement

Les IDs d'environnement hardcodés dans l'API :
- **Sandbox/Préproduction** : `1f157a54-15ca-491e-ac7f-77c662f71d9c`
- **Production** : `242b6f0c-7f5c-4c31-92f1-4257e182e885`

Pour trouver vos IDs :
```bash
# Via Anypoint CLI
anypoint-cli env list

# Ou dans Anypoint Platform
# Access Management > Environments
```

## 🤝 Contribution

### Process

1. **Fork** le repository
2. **Feature branch** : `git checkout -b feature/nouvelle-fonctionnalite`
3. **Tests** : Ajouter des tests MUnit
4. **Commit** : Messages descriptifs
5. **Pull Request** : Avec description détaillée

### Standards

- **Naming** : CamelCase pour flows, kebab-case pour HTTP
- **Documentation** : Attributs doc:name et doc:id
- **Error Handling** : Try-Catch avec error handlers spécifiques
- **DataWeave** : Version 2.0, output types explicites

### Tests MUnit

Structure d'un test :
```xml
<munit:test name="test-get-meters">
    <munit:execution>
        <http:request method="GET" path="/api/meters"/>
    </munit:execution>
    <munit:validation>
        <munit-tools:assert-that expression="#[attributes.statusCode]" is="#[MunitTools::equalTo(200)]"/>
    </munit:validation>
</munit:test>
```

## 📚 Ressources

- [Anypoint Usage API Documentation](https://anypoint.mulesoft.com/exchange/portals/anypoint-platform/f1e97bc6-315a-4490-82a7-23abe036327a/usage-api/)
- [Mule 4 Documentation](https://docs.mulesoft.com/mule-runtime/4.4/)
- [DataWeave 2.0 Reference](https://docs.mulesoft.com/dataweave/2.4/)
- [Object Store Connector](https://docs.mulesoft.com/object-store-connector/latest/)

## 📄 Licence

Propriétaire - Voir LICENSE pour plus de détails

## 👥 Support

- **MuleSoft Support** : https://support.mulesoft.com
- **Community Forum** : https://help.mulesoft.com
- **Stack Overflow** : Tag `mulesoft`

---

**Développé avec ❤️ pour optimiser l'utilisation d'Anypoint Platform**
