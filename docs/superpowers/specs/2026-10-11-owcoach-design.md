# OWCoach — Overwatch-Trainings-App

Persönliche iOS-App, die das Overwatch-Trainingssystem aus Obsidian
(`~/Obsidian/Schakal/Games/Overwatch`) ablöst. Zwei Nutzer: Eduard und seine
Freundin, jeder mit eigenen Daten. Wichtigstes Ziel: schnell und mit Spaß
bedienbar. Was sich zäh anfühlt, wird nicht benutzt.

## Ziele

- Nach jedem Game in ~10 Sekunden durchtippen, ohne nachzudenken
- Immer sichtbar: woran arbeite ich gerade (eine Fokus-Karte) und mit welchen Helden
- Sichtbar machen, dass man besser wird: Fokus-Score, Todesursachen, Winrate
- Coaching-Wissen strukturiert pro Held: Aufgabe, Positionierung, Kit, Lernpfad
- VOD-Findings fließen ohne Extra-Aufwand in die Karten zurück

## Nicht-Ziele

Login oder eigener Server · gemeinsame Daten zwischen Nutzern · Karten in der
App bearbeiten · Clips oder Screenshots anhängen · Aufwärm- oder Aim-Tracking ·
Import von Spielstatistiken aus Overwatch · ältere iOS-Versionen.

## Grundprinzip: eine Karte im Kopf

Aus den Coachings (Wizard Hyeong): viele Regeln gleichzeitig machen schlechter,
ein Lernobjekt mit voller Aufmerksamkeit macht besser. Deshalb gibt es immer
genau **eine aktive Fokus-Karte**. Im Game denkt man nur an sie. Alles andere
(Todesursache, Tilt) wird erst nach dem Game erfasst.

## Inhalte

### Kartentypen

- **Grundlagen-Karten** gelten für jeden Helden. Sieben Stück: Cover,
  Slicing the Pie, Go/Back, Position zum Team, Threat tracken, Fluchtweg zuerst,
  Timing mit dem Team. Eine Karte kann pro Rolle (Tank, DPS, Support) eine
  eigene Variante der Punkte haben; fehlt sie, gilt die allgemeine Version.
- **Helden-Karten** behandeln nur das Kit eines Helden (Torb: Turret,
  Overload, Molten Core; Zarya: Bubbles; …). Sie bilden den Lernpfad des
  Helden in fester Reihenfolge.

Jede Karte: Titel, eine Frage, höchstens drei Punkte, null bis fünf Video-Links
mit Zeitstempel.

### Helden

Pro Held: Name, Rolle, Icon, Guide und Lernpfad. Der Guide hat feste
Abschnitte: Aufgabe, Positionierung, Kit, Matchups. Jeder Abschnitt ist eine
kurze Liste von Regeln mit optionalen Video-Links. Ein Abschnitt darf fehlen.

Startinhalt:

- **Torbjörn** komplett aus `Helden/Torbjörn.md` und den Torb-Karten in Obsidian
- **Juno, Domina, Winston, Zarya** nur mit Name, Rolle und Icon; Guide und
  Karten folgen in Projekt B
- **Grundlagen** komplett, aus den bisherigen allgemeinen Karten (Ecke halten,
  Slicing the Pie, Spot wechseln, Fluchtweg, Go/Back, Lane wählen, Threat
  tracken, Timing mit dem Tank) zusammengeführt auf die sieben Grundlagen.
  Die bisherigen Torb-Positionskarten (Ecke halten, Spot wechseln, Overload-Leine)
  werden zur DPS-Variante von Cover bzw. zu Torb-Helden-Karten
- **Maps** komplett: Name, Modus, Bild

### Format

JSON-Dateien im Projekt unter `Content/`, beim Build in die App gepackt,
zur Laufzeit nur gelesen:

- `Content/basics.json` — Grundlagen-Karten
- `Content/heroes/<id>.json` — ein Held mit Guide und Lernpfad
- `Content/maps.json` — Maps mit Modus und Bildname

Icons und Map-Bilder lädt einmalig ein Skript (`scripts/fetch-assets`):
Helden-Icons von overwatch.blizzard.com, Map-Bilder vom Overwatch-Fandom-Wiki.
Sie liegen danach als Assets im Projekt. Die App braucht kein Internet.

Neue Inhalte: Claude wertet Videos aus und schreibt die JSON-Datei, dann neuer
Build. Die Freundin bekommt Updates über TestFlight.

## Nutzerdaten

SwiftData mit CloudKit (private Datenbank). Gesichert pro Apple-ID, auf einem
neuen iPhone automatisch wieder da, zwischen den beiden Nutzern getrennt. Ohne
iCloud-Anmeldung läuft die App lokal weiter und zeigt einen Hinweis in den
Einstellungen.

Modelle:

- **Game** — Datum, Rolle, Held, Map, Ergebnis (Sieg/Niederlage/Unentschieden),
  Fokus 1–5, Fokus-Karte zum Zeitpunkt des Games, Todesursache, Tilt 1–4
- **FocusState** — aktive Karte, Wochenhelden, Seit-Datum
- **CardProgress** — pro Karte: Status (offen/aktiv/sitzt), Datum „sitzt seit“
- **VODReview** — Datum, Replay-Code, Held, Map, optional verknüpftes Game
- **Finding** — gehört zu einem VODReview: Zeit/Runde (optional), Karte, Text, Stern
- **Settings** — Standard-Rolle, Modus 5v5/6v6, Heldenpool

CloudKit verlangt optionale oder vorbelegte Attribute und keine Unique-Constraints;
das Modell hält sich daran.

### Todesursachen

Ein Tap pro Game, die Hauptursache. Jede Ursache gehört zu genau einer
Grundlagen-Karte:

| Ursache | Karte |
|---|---|
| Offen | Cover |
| Zu weit vorn | Go/Back |
| Allein / weg vom Team | Position zum Team |
| Überrascht | Threat tracken |
| Kein Ausweg | Fluchtweg zuerst |
| Zu früh / zu spät rein | Timing mit dem Team |
| Fair | — |
| Kaum gestorben | — |

Slicing the Pie hat keine eigene Ursache; Tode im Offenen zählen auf Cover,
Slicing the Pie ist die Folgekarte dazu.

## Screens

Vier Tabs: Heute · Lernen · VOD · Stats. Einstellungen über ein Zahnrad.

### Heute

- Wochenhelden als Icons oben. Antippen öffnet die Auswahl aus dem Pool
- Fokus-Karte groß: Frage, Punkte, darunter die mit Stern markierten Findings
- Großer Button „Game loggen“
- Liste der heutigen Games: Held-Icon, Map, Ergebnis, Fokus, Tilt-Smiley
- Drei Kacheln: Winrate 7 Tage · Fokus-Ø 7 Tage · häufigste Todesursache 14 Tage
- Vorschlag-Banner, höchstens einer gleichzeitig (Regeln unten)

### Game loggen

Schritt für Schritt, ein Screen pro Schritt, Vor/Zurück per Button und Swipe,
Fortschritt als Punkte oben. Nichts ist vorausgefüllt außer der Rolle aus den
Einstellungen. Ein Tap auf eine Auswahl springt automatisch weiter.

1. Rolle (Tank/DPS/Support)
2. Held — nur Helden aus dem Pool mit dieser Rolle, als Icon-Raster
3. Map — Suchfeld oben, Liste mit Bild und Name, nach Modus gruppiert
4. Ergebnis — Sieg / Niederlage / Unentschieden
5. Fokus 1–5 — die Frage der aktiven Karte steht darüber
6. Todesursache — 8 Chips in 2 Reihen
7. Tilt — 😎 🙂 😐 😤

Nach Schritt 7 speichern und zurück zu Heute, mit kurzer Bestätigung.
Abbrechen verwirft das Game.

### Lernen

- Abschnitt **Grundlagen**: die sieben Karten mit Status
- Abschnitt **Helden**: Icon-Raster nach Rolle, Pool-Helden oben, andere ausgegraut
- **Heldenseite**: Guide-Abschnitte, Lernpfad mit Status pro Karte,
  Stats dieses Helden (Games, Winrate, Fokus-Ø)
- **Kartenseite**: Frage, Punkte (passende Rollen-Variante bei Grundlagen),
  Video-Links, Findings zu dieser Karte (Stern zuerst), Button „Als Fokus setzen“
  bzw. „Sitzt“

### VOD

- Liste der Reviews, neueste oben. Neues Review: Replay-Code, Held, Map;
  oder aus einem geloggten Game übernehmen
- Im Review Findings hinzufügen: Zeit/Runde, Karte (Chips: Grundlagen plus
  Helden-Karten dieses Helden), ein Satz, Stern
- Umschalter **Learnings**: alle Findings gruppiert nach Karte mit Anzahl

### Stats

Zeitraum-Umschalter 7 Tage / 30 Tage / alles.

- Winrate über Zeit, pro Held, pro Map
- Fokus-Ø-Verlauf pro Spieltag
- Todesursachen pro Woche als gestapelte Balken
- Karten: Anzahl „sitzt“, aktive Karte seit wann

### Einstellungen

Standard-Rolle · Modus 5v5/6v6 · Heldenpool (alle Helden mit Icon, an/aus) ·
iCloud-Status.

## Regeln

- **Spieltag** = alle Games eines Kalendertags. Es gibt keine explizite Session
- **Karte sitzt?** Vorschlag, wenn die letzten drei Spieltage mit der aktiven
  Karte je Fokus-Ø ≥ 4 haben
- **Weiter trotzdem:** nach 10 Spieltagen mit derselben aktiven Karte Hinweis
  „Nächste Karte nehmen, diese später wiederholen“
- **Fokus-Vorschlag:** wenn eine Ursache in den letzten 10 Games ≥ 40 % ausmacht
  (mindestens 4 Games) und ihre Karte nicht aktiv ist und nicht „sitzt“
- Priorität der Banner: Karte sitzt > Fokus-Vorschlag > Weiter trotzdem
- Ein weggeklickter Vorschlag kommt erst nach 3 weiteren Games wieder

## Technik

- `~/Developer/OWCoach`, XcodeGen über `project.yml`, iOS 26, SwiftUI, Swift Charts
- `OWCoachKit` (Swift Package): Inhaltsmodelle und Laden, Stats-Berechnung,
  Vorschlagsregeln. Nur Foundation, mit Unit-Tests
- `App/`: SwiftUI-Screens und SwiftData-Modelle. Die Modelle werden für die Kit-Logik
  in einfache Werte-Typen übersetzt, damit das Kit ohne SwiftData testbar bleibt
- Bundle-ID `de.schakal.OWCoach`, CloudKit-Container `iCloud.de.schakal.OWCoach`
- Design: Liquid Glass (iOS 26). Systemeigene Tab-Bar, Toolbars und Buttons bringen es
  mit; eigene Flächen (Kacheln, Chips, Fokus-Karte) bekommen `.glassEffect()`.
  Dunkles Grundthema mit Overwatch-Orange als Akzent, große Touch-Ziele
  (mindestens 52 pt), Rollen-Farben für Tank/DPS/Support, Haptik bei jedem Tap
  im Game-Ablauf

## Tests

- Kit: Winrate, Fokus-Ø pro Spieltag, Ursachen-Anteile, alle Vorschlagsregeln
  mit Grenzfällen (genau 40 %, 3 vs. 4 Games, Spieltag-Grenze Mitternacht)
- Inhalt: ein Test lädt alle JSON-Dateien und prüft: jede Karte hat eine Frage
  und höchstens drei Punkte, IDs sind eindeutig, jedes Icon und jedes Map-Bild
  existiert, jede Todesursache verweist auf eine existierende Grundlagen-Karte
- UI: Durchlauf im Simulator mit Screenshots aller Screens und des Game-Ablaufs

## Reihenfolge

1. **A1** — Gerüst, Inhalte (Torb, Grundlagen, Maps, Icons), Datenmodell,
   Game-Ablauf, Heute-Tab, Einstellungen
2. **A2** — Lernen, VOD, Stats
3. **B** — Inhalte für Juno, Domina, Winston, Zarya aus den Playlists und Videos,
   die Eduard am 2026-10-11 geschickt hat

Obsidian bleibt bestehen, bis A2 auf dem Handy läuft. Bisherige Sessions werden
nicht übernommen (nur zwei Einträge, beide fast leer).
