# Engineering Guidelines

Diese Richtlinien gelten für die Browser-Migration von `Gamble-Game`.

## Ziele
- professionell wartbarer Code
- klare Verantwortlichkeiten
- kleine, verständliche Module statt God-Files
- saubere Trennung von UI, Renderer, Physik und Spiellogik
- Änderungen nachvollziehbar dokumentieren

## Grundprinzipien
1. **Single Responsibility**
   - Eine Datei/ein Modul soll möglichst nur eine klar erkennbare Aufgabe haben.
2. **Keine God Components**
   - Renderer, Würfelmodelle, Physik-Helfer, UI und Regeln nicht in eine Datei kippen.
3. **Explizite Typen**
   - TypeScript-Typen für Datenstrukturen, Contracts und Spielzustände sauber definieren.
4. **Kommentare mit Sinn**
   - Kommentare erklären *warum* etwas so gemacht wird, nicht bloß *was* der Code offensichtlich tut.
5. **Refactor früh, nicht spät**
   - Wenn ein Modul unübersichtlich wird, aufteilen bevor daraus technischer Beton wird.
6. **Dokumentierte Änderungen**
   - Relevante Änderungen kommen in `CHANGELOG.md`.

## Strukturregeln

### Empfohlene Aufteilung im Web-Client
- `components/` → React-Komponenten, UI und Renderer-Bausteine
- `constants/` → feste Werte, Tabellen, Konfigurationen
- `lib/` → Hilfsfunktionen, Berechnungen, Utility-Logik
- `types/` → Typdefinitionen
- `screens/` → Screen-/Page-nahe Komposition
- `state/` → später App-/Game-State-Management

### Nicht okay
- 500+ Zeilen in `App.tsx`, wenn darunter mehrere klar trennbare Verantwortungen liegen
- Regeln, Physik, Rendering und UI-Text in einer Datei vermischen

## Kommentarregeln
- Kommentare nur dort, wo die Entscheidung oder Logik nicht sofort offensichtlich ist
- keine Kommentar-Tapete
- lieber wenige gute Kommentare als 30 nutzlose

## Changelog-Regel
- Jede nennenswerte Änderung am Projekt wird in `CHANGELOG.md` ergänzt
- Einträge kurz, konkret und chronologisch

## Commit-Regel
- Kleine, klare Commits
- Commit-Message beschreibt die tatsächliche Änderung

## Aktuelle Prioritäten
1. gute Renderer-/Physics-Basis
2. saubere Modulstruktur
3. vorbereitbare Core-Logic
4. später Produkt- und Gameplay-Ausbau
