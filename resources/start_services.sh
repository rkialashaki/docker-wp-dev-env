#!/bin/bash
SERVICES=("php7.2-fpm" "redis-server" "nginx")

function stop_services() {
  for service in ${SERVICES[@]}; do
    sudo service $service stop
  done
}

function start_services() {
  for service in ${SERVICES[@]}; do
    sudo service $service start
  done
}

function restart_services() {
  stop_services
  start_services
}

restart_services
