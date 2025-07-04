# Home Central

This Repositories is containing my home central, which is the central control
system for my Smart Home. I want to control and readout different devices to
create smart automations.
This home central is made of different components. 
All Components are configured by this repo.

To orchestrate the components I use docker compose. 

## Installation

For this Project I need to install docker and the docker compose plugin:

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# I am running debian and my package manager is apt
sudo install docker-compose-plugin 
```

All containers should run as root, so I don't use rootless docker. 
I do not add a user to the docker group, as root access should be necessary.

Last step, run the Project:

```
docker compose up -d
```

## Components

### Home Assistant

Home Assistant is the central platform for including for my devices,
configuring automatons and creating dashboards. 

HAS can automatically discover new Devices in the network, therefore the
container is running in network mode host
(https://community.home-assistant.io/t/avoid-network-mode-host-for-docker/47250/10).

Home Assistant is available on port 8123. Over the WebUI you can configure it, 
but some configurations can only be made in the configuration file, therefore this configuration is part of this repo.

### Mosquito

For some devices I need MQTT to connect them, therefore I added this MQTT
Broker.

### Zigbee2Mqtt

I have several devices that run on Zigbee and I want to avoid having
a gateway from Phillips or Ikea because it needs a place to mount on it and some
features are not supported by them. 
Luckily for me I found this nice tool zigbee2mqtt. I connect a sonoff
zigbee stick to my server and this tool connects my devices via mqtt to my
system. The Devices can be readed and controlled by HAS over MQTT. Every Devices
is a "MQTT Device" in HAS with all the corresponding entities.

I can use this stick directly in Homeassistant, but this way seems cooler to me.

Thank you for providing me this docker compose entry zigbee2mqtt: https://www.zigbee2mqtt.io/guide/installation/02_docker.html

## Maintenance Scripts

To maintain my central, I have added different scripts to this Repo.

**Update**

```
sudo ./scripts/update.sh
```

The script is very simple. It pulls the latest version of the Gut Repo and the Docker images. Afterwards, all containers are rebuilt so that all “fresh” new instances are running.

**Backup**

```
sudo ./scripts/backup.sh
```

Of course I would like to back up data from this control center. For this reason I added a script.
The script backs up all data that is created at runtime of the services and backs it up to another 
path of the local file system. This location is backed up by another mechanic.
