#!/bin/bash

# Pfad zum ectool
ECTOOL="/usr/local/bin/ectool"

# Funktion: Automatik EIN (Reset)

#!/bin/bash

# Pfad zum ectool (Anpassen falls nötig)
ECTOOL="/usr/local/bin/ectool"

# Funktion: Turbo EIN
function turbo_on() {
    echo "--- Modus: TURBO ---"
    echo "Deaktiviere Automatik..."
    # Automatik für beide Lüfter aus
    sudo $ECTOOL autofanctrl 0
    echo "Setze Lüfter auf 100% (Duty 100)..."
    # Beide Lüfter auf 100%
    sudo $ECTOOL fanduty 80
    echo "Status:"
    sudo $ECTOOL pwmgetfanrpm all
}

# Funktion: Manuelle Prozentangabe (für Tests)
function turbo_set() {
    VAL=$1
    if [[ "$VAL" =~ ^[0-9]+$ ]] && [ "$VAL" -le 100 ]; then
        echo "--- Modus: MANUELL ($VAL%) ---"
        sudo $ECTOOL autofanctrl 0 0 2>/dev/null
        sudo $ECTOOL autofanctrl 0 1 2>/dev/null
        sudo $ECTOOL fanduty $VAL
        sudo $ECTOOL pwmgetfanrpm all
    else
        echo "Fehler: Wert zwischen 0 und 100 angeben."
    fi
}
# Funktion: Automatik EIN
function turbo_off() {
    echo "--- Modus: AUTOMATIK ---"
    echo "Aktiviere EC-Lüftersteuerung..."
    # Wir schalten die Automatik explizit ein
    sudo $ECTOOL autofanctrl 1
    
    # Manche EC-Versionen brauchen einen Schubs, 
    # um den manuellen Duty-Wert zu vergessen:
    # Wir setzen die Duty kurz auf 0, während die Automatik übernimmt
    sudo $ECTOOL fanduty 0 2>/dev/null 
    
    # Sicherheitshalber für beide Indizes (falls vorhanden)
    # Modus (Auto) für Fan 0 (Index 0)
    sudo $ECTOOL autofanctrl 0 2>/dev/null
    # Modus (Auto) für Fan 1 (Index 1)
    sudo $ECTOOL autofanctrl 1 2>/dev/null
    
    echo "Lüfter werden nun wieder vom System gesteuert."
    sleep 2
    sudo $ECTOOL pwmgetfanrpm all
}

# Weiche für die Parameter
case "$1" in
    on)
        turbo_on
        ;;
    set)
        turbo_set $2
        ;;
    off)
        turbo_off
        ;;
    status)
        echo "Aktuelle Drehzahl:"
        sudo $ECTOOL pwmgetfanrpm all
        ;;
    *)
        echo "Benutzung: $0 {on|off|status}"
        echo "Benutzung: $0 {on|off|set %|status}"
        echo "  on     -> Lüfter auf 100% (für HandBrake)"
        echo "  off    -> Zurück zur Automatik (Idle)"
        echo "  set 80 -> Lüfter auf 80% "
        echo "  status -> Zeigt RPM und ob HB läuft"
        exit 1
esac
