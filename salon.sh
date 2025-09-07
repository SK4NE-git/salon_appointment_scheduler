#!/bin/bash
# Salon appointment scheduler

PSQL="psql --username=freecodecamp --dbname=salon -X -t -c"

echo -e "\n~~ Salon Appointment Scheduler ~~\n"

MAIN_MENU () {
  # print the given message if any
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  # get the list of available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # pretty print the retrieved services
  echo -e "\nHere is the list of available services:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # get the service id from the user
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if it doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    # restart with the given message
    MAIN_MENU "The resquested service doesn't exist"
  else
    # else schedule the appointment
    SCHEDULE_APPOINTMENT
  fi
}

SCHEDULE_APPOINTMENT () {
  # get the customer's phone number from the user
  echo -e "\nWhat's your phone number ?"
  read CUSTOMER_PHONE

  # get the customer's name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if it does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get the customer's name from the user
    echo -e "\nWhat's your name ?"
    read CUSTOMER_NAME

    # register the new user into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get the customer's id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # get the time for the service from the user
  echo -e "\nWhat time do you wish for this service ?"
  read SERVICE_TIME

  # register the appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # give the final feedback to the user
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed 's/  / /g'
}

MAIN_MENU

