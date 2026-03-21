# Vercel Setup

Ziel: Jeder Push auf das GitHub-Repo soll automatisch eine testbare Web-Version bauen, damit das Spiel direkt auf dem Handy getestet werden kann.

## Empfohlener Setup-Weg

1. Bei Vercel anmelden
2. `New Project`
3. GitHub verbinden
4. Repository auswählen: `Gamble-Game`
5. Vercel-Konfiguration prüfen

## Empfohlene Einstellungen

### Root
- Repository Root unverändert lassen
- Die Build-Konfiguration wird über `vercel.json` geregelt

### Build
- `installCommand`: `cd web/app && npm install`
- `buildCommand`: `cd web/app && npm run build`
- `outputDirectory`: `web/app/dist`

## Erwartetes Verhalten
- Push auf Branches erzeugt Preview Deployments
- Push auf Hauptbranch kann auf Wunsch Produktionsdeployment auslösen
- Die resultierende URL ist direkt mobil testbar

## Empfohlener Workflow
- Entwicklung auf `feature/browser-migration-spike`
- jeder Push erzeugt eine neue Preview-URL
- sobald stabil, Merge auf Hauptbranch

## Später
Wenn der Server-Teil ebenfalls online testbar werden soll, braucht der Multiplayer-/Socket-Server ein separates Deployment oder einen VPS/anderen Host. Dieses Setup hier betrifft zunächst nur den Web-Client.
