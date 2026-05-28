#!/bin/bash

# SCHWELLENWERTE
RAM_LIMIT_HIGH=55
RAM_LIMIT_LOW=50
CHECK_INTERVAL=5
STATE="auto"

echo "--- Framework 16: Thermal Guard (Echter RAM-Sensor) aktiv ---"

while true; do
    # Gezieltes Auslesen der temp1-Werte der spd5118 Sensoren
    # Wir nehmen den höchsten Wert beider Riegel
    RAM_TEMP=$(sensors spd5118-* | grep "temp1" | awk '{print $2}' | tr -d '+°C' | sort -n | tail -1 | cut -d. -f1)

    if [[ -z "$RAM_TEMP" ]]; then
        sleep $CHECK_INTERVAL
        continue
    fi

    if [[ "$RAM_TEMP" -ge "$RAM_LIMIT_HIGH" ]] && [[ "$STATE" == "auto" ]]; then
        echo "[$(date +%T)] ALARM: RAM-Riegel bei $RAM_TEMP°C -> Full Speed!"
        fan-control set 100
        STATE="manual"
    
    elif [[ "$RAM_TEMP" -le "$RAM_LIMIT_LOW" ]] && [[ "$STATE" == "manual" ]]; then
        echo "[$(date +%T)] Entwarnung: RAM bei $RAM_TEMP°C -> Zurück auf Auto."
        fan-control off
        STATE="auto"
    fi

    sleep $CHECK_INTERVAL
done

