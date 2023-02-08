#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"
echo -e "\n~~ freeCodeCamp Salon ~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi
  #prompt available services
  SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nPlease enter the service ID you need:"
  #get requested service id
  read SERVICE_ID_SELECTED
  REQ_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  #if invalid request
  if [[ -z $REQ_SERVICE_ID ]]
  then
    #return to main menu
    MAIN_MENU "Please enter a valid service ID."
  else
    #get phone number
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    #if not in database
    if [[ -z $CUSTOMER_ID ]]
    then
      #ask for name
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      #add new customer
      CUSTOMER_INSERTION_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    fi
    echo -e "\nPlease enter a time for booking an appointment:"
    read SERVICE_TIME
    APPOINTMENT_INSERTION_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$REQ_SERVICE_ID,'$SERVICE_TIME');")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$REQ_SERVICE_ID;")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}
MAIN_MENU