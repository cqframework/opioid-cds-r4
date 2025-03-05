#!/bin/sh
while ! curl http://localhost:8080/fhir
do
  echo "$(date) - still trying"
  sleep 1
done
echo "$(date) - connected successfully"