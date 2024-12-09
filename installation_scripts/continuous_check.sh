#!/bin/bash

# Verifica se è stato passato il comando da eseguire
if [ $# -lt 1 ]; then
  echo "Uso: $0 <comando>"
  exit 1
fi

# Comando da eseguire
COMMAND=$@

# Intervallo di polling in secondi
INTERVAL=5

# Funzione per eseguire il polling del comando
poll_command() {
  pwd
  while true; do
    # Esegui il comando
    $COMMAND
    RESULT=$?
    
    # Verifica il codice di ritorno del comando
    if [ $RESULT -eq 0 ]; then
      echo "Command was successful."
      break
    else
      echo "Command failed, retry in $INTERVAL seconds..."
      sleep $INTERVAL
    fi
  done
}

poll_command
