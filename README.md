# Projektrepository

Bitte halten Sie sich **unbedingt** an folgende Ordnerstruktur und beachten Sie insbesondere Groß- und Kleinschreibung. Nicht-Beachtung dieser Struktur kann zu Punktabzügen führen.

- `Ausarbeitung/Ausarbeitung.pdf`: PDF Ihrer Ausarbeitung
- `Ausarbeitung/Ausarbeitung.tex`: LaTeX-Quellen Ihrer Ausarbeitung
- `Implementierung/`: Ihre Implementierung
- `Implementierung/Makefile`: Makefile für Ihre Implementierung, welches durch einen Aufruf von `make` Ihre Implementierung kompiliert
- `Vortrag/Vortrag.pdf`: Folien für Ihre Abschlusspräsentation

-----
## Berechnung des Tricornsfraktals: 

In dem Implementierungsordner gibt es einen Makefile, der durch ausführen des Befehls `make` einen
Build unserer Implementierung baut.
Danach kann man durch
>./main r_start r_end i_start i_end res

die jeweillige Implementierung ausführen. Die Attribute des Befehls entsprechen die Attribute der Funktion:

>void multicorn(float r_start, float r_end, float i_start, float i_end, float res, unsigned
char* img)

Das heißt, dass man einen beliebigen Bereich des tricorns einsetzen kann um es mit beliebige Resolution anzuschauen. Um eine erste Perspektive zu bekommen, empfehlen wir das ausführen von:

>./main -2 -1 -1.5 1.5 1000

denn so kann man den gesamten Tricorn in eine genügend große Definition anschauen. Das Ergebnis ist in dem selben Folder als Bitmap Datei zu finden. Das Spielen mit verschiedene Attribute ist erwartet und wünschenswert, denn so kann man letzendlich die Schönheit des Tricorn Fraktal sehen.

>Mit `make test` iteriert unser Programm durch alle mögliche Resolutionen. So können wir testen, dass keine Eingabe ein Segfault geben kann. 


Man kann auch die durch make generierte Dateien durch Ausführung des Befehls `make clean` schnell löschen.


