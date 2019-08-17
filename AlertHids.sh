#!/bin/bash
# Tiago Silva Leite | tleite@bsd.com.br
#V.2.1

API=$( echo $1 )
TARGET=$( echo $2 )

if [ -z $API ] || [ -z $TARGET  ];then

                        echo "
                        +-------------------------------------------------------+
                         [ Usage ] $0   <API do BOT>   <ID Destino> 
                        +-------------------------------------------------------+
                                                PID: $$
                             "
exit 0
else

DIR="/opt/telegram/"                                                                    # Diretório base do programa
LOG="$DIR/events.log"                                                                   # Arquivo filtro de dados do Ossec
ST="$DIR/state.log"                                                                     # Arquivo para verificação dos status
URL="https://api.telegram.org/bot$API/sendMessage"                                      # Endereço para envio
egrep -A 3 -B 3 "level ([6-9]|1[0-6])" /var/ossec/logs/alerts/alerts.log > $LOG         # Ler Logs de níveis de 5-16 do Ossec 
ST_ATUAL=$( egrep -c "level ([6-9]|1[0-6])" /var/ossec/logs/alerts/alerts.log )         # Pega o número do status atual.
EXEC=$(cat $ST)                                                                         # Ler o conteúdo do status
RESULT=$(tail -n7 $LOG )                                                                # Verifica o resultado final para enviar os alertas

if [ {$EXEC} != {$ST_ATUAL} ] ;then                                                     # Se o número atual for maior que o arquivo state.log, envia.

TEXT=" 
| OSSEC - HIDS |

$RESULT
"

curl -s \
-X POST \
https://api.telegram.org/bot$API/sendMessage \
-d text="$TEXT" \
-d chat_id=$TARGET

egrep -c "level ([6-9]|1[0-6])" /var/ossec/logs/alerts/alerts.log > $ST                 # Salva o último estado no arquivo state.log

else
exit 0
fi
