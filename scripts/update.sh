#! /bin/bash
# This Script is for updating the home central.
# The Update has two parts.
# Firstly pull the newest Commit of this Repo, to update the
# configuration and deployment files.
#
# Secondly pull the newest docker images and rebuild all containers.

set -eu

function update_docker_containers() {

	# I separate pull and rebuild into two steps in order to avoid unclear states.
	docker-compose pull
	# --force-recreate ensures that all containers are restarted in both ways.
	# way. Assuming the configuration has changed, in this case you need to restart the container
	# to make the change available and docker compose up will only restart the container.
	# (and restart) the container when the container changes.
	docker-compose up -d --force-recreate --remove-orphans
}

git pull --rebase
update_docker_containers
