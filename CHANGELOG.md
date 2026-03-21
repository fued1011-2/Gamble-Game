# Changelog

## Unreleased

### Added
- Browser-Migrationsplanung unter `.pako/` als lokale Arbeitsgrundlage aufgebaut
- Web-Grundstruktur unter `web/` angelegt
- React/Vite/TypeScript-Webprojekt angelegt
- R3F-basierter Renderer-Spike gestartet
- Face-Mapping und Top-Face-Erkennung ergänzt
- Rapier-Physik für Würfelwürfe integriert
- becherbasierte Wurfsequenz ergänzt
- Engineering-Richtlinien und Strukturregeln dokumentiert
- `vercel.json` und Vercel-Setup-Dokumentation für automatische Preview-Deployments ergänzt
- Preview-Deployment-Test per Branch-Push ausgelöst

### Changed
- Würfelgröße und Becher-Innenraum für bessere Stabilität angepasst
- Renderer-Code wird in besser getrennte Module aufgeteilt
- Kamera weiter herausgezogen und Zoom-Spielraum erweitert
- Becherwurf auf sichtbareres Ausgießen und ruhigere Sammelphase umgestellt
- Würfel verkleinert und Collider enger auf die neue Größe abgestimmt, um Verhakungen zu reduzieren
- Wurfsequenz stärker in Richtung kontrollierter Referenz-Inszenierung getunt
- Becherfreigabe weiter choreografiert und Kamera nochmals auf Referenz-Lesbarkeit abgestimmt
- Teleport-Bug behoben, indem Würfel-Repositionierung nur noch bei echten Phasenwechseln erfolgt
- Keep-Zone visuell klarer markiert und Würfel-Endlagen lesbarer organisiert
- Würfel werden jetzt erst nach echter Ruhephase statt zu frühem Fix-Timer ausgerichtet
- Ruhephase nach dem Wurf verlängert und Fallback gegen dauerhaft hängenden Rolling-Zustand ergänzt
- Auswahlfluss korrigiert: aktive Würfel bleiben beim Selektieren im Tray statt in den Becher zurückzuspringen
- Keep-/Selection-Layer weiter geschärft: aktive und zurückgelegte Würfel visuell klarer getrennt
- Keep-Zone ruhiger geordnet und optisch stärker als eigener Ablagebereich markiert
- Auswahlfeedback verbessert: Hover-/Select-Highlight macht interaktive Würfel klarer erkennbar
- Kamerakomposition näher an 51WWG ausgerichtet: steilere Vogelperspektive, Keep-Zone oben, Becher rechts vom Tray
