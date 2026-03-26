# MOM-CA v2 - eXist-db App Package

## Quick Start with Docker

```bash
cd xar
docker compose up --build
```

eXist-db startet auf **http://localhost:8080**

- Dashboard: http://localhost:8080/exist/apps/dashboard/
- MOM-CA App: http://localhost:8080/exist/apps/mom-ca/
- Login-Seite (Fore): http://localhost:8080/exist/apps/mom-ca/login
- REST API: http://localhost:8080/exist/apps/mom-ca/api/health

Default-Login: `admin` / (kein Passwort)

## Lokale Entwicklung (ohne Docker)

### Voraussetzungen
- Node.js 18+
- eXist-db 6.x lokal installiert

### Setup
```bash
cd xar
npm install          # Installiert Fore + Build-Tools
npm run build        # Baut das .xar Package
npm run xar          # Erstellt dist/mom-ca-2.0.0-alpha.1.xar
```

### .xar manuell installieren
1. eXist-db Dashboard öffnen: http://localhost:8080/exist/apps/dashboard/
2. Package Manager > Upload > `dist/mom-ca-2.0.0-alpha.1.xar` hochladen

### Live-Entwicklung
```bash
npm run watch        # Synct Änderungen automatisch nach eXist-db
```

## Projektstruktur

```
xar/
  Dockerfile              # Multi-stage: Build .xar + eXist-db 6.2
  docker-compose.yml      # Startet eXist-db mit persistentem Volume
  expath-pkg.xml          # EXPath Package-Deskriptor
  repo.xml                # eXist-db Deployment-Deskriptor
  package.json            # npm/Fore Dependencies
  gulpfile.js             # Build-Pipeline
  src/
    controller.xql        # URL-Routing (alle ~200 Routen)
    config.xml             # Konsolidierte Konfiguration
    pre-install.xql        # Deployt Index-Konfigurationen
    modules/
      config.xqm          # conf:param() Kompatibilitätsmodul
      view.xql             # Seiten-Renderer
      api.xql              # RESTXQ API-Endpoints
    pages/                 # 136 konvertierte Widget-Seiten
      home.html            # Startseite
      login.html           # Login (Fore Web Components)
      charter.html         # Charter-Ansicht
      ...
    templates/
      default.html         # Basis-HTML5-Template
    resources/
      fore/                # Fore JS/CSS (via npm)
      css/
      js/
      img/
    collection-configs/    # eXist-db Index-Konfigurationen
```
