#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo Welcome to My Salon, how can I help you?
IN_CHOOSE_SERVICE_STEP=true
while [[ $IN_CHOOSE_SERVICE_STEP == true ]]
do
  MAIN_MENU
  read SERVICE_ID_SELECTED
  MAIN_MENU_SELECTION=$SERVICE_ID_SELECTED
  if [[ ! $MAIN_MENU_SELECTION =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
  else
    IS_SERVICE_ID_VALID=$($PSQL "select name from services where service_id = $MAIN_MENU_SELECTION")
    if [[ -z $IS_SERVICE_ID_VALID ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
    else
      IN_CHOOSE_SERVICE_STEP=false
    fi
  fi
done
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
EXISTED_CUSTOMER=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
if [[ -z $EXISTED_CUSTOMER ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  EXISTED_CUSTOMER=$CUSTOMER_NAME
fi
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
echo -e "\nWhat time would you like your$IS_SERVICE_ID_VALID, $EXISTED_CUSTOMER?"
read SERVICE_TIME
INSERT_ORDER_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $MAIN_MENU_SELECTION, '$SERVICE_TIME')")
echo -e "\nI have put you down for a $IS_SERVICE_ID_VALID at $SERVICE_TIME, $EXISTED_CUSTOMER."


