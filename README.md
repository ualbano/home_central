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

#### Room climate

- `config/has/dashboards/raumklima.yaml` – dashboard (YAML mode) with outdoor
  values, hints, one tile per room with a 24 h curve, thermostat controls and
  history charts. Needs Mushroom, Lovelace Card Mod, ApexCharts Card and
  mini-graph-card from HACS.
- `config/has/packages/raumklima.yaml` – hints (rooms too humid / too warm,
  weak batteries), 24 h min/max outdoors and a push notification when a room is
  too humid (max. once per room in 3 h, not at night).

#### Server

- `config/has/dashboards/server.yaml` – dashboard (YAML mode) with CPU, RAM and
  disk gauges, load/temperature, network and power consumption of the server.
- `config/has/packages/server.yaml` – RAM in % and GB, a warning sensor
  (disk > 85 %, RAM > 90 %, CPU > 75 °C) and daily/monthly energy.
  The server's smart plug is still called `kz_siebtrager` (it used to power
  the espresso machine).

#### Load config from git

The script *Config aus Git laden* (`config/has/packages/home_central.yaml`)
pulls this repo from inside Home Assistant and reloads automations, scripts,
templates and helpers. Tick *Danach neu starten* for changes that need a
restart. For this the repo is mounted into the container as `/repo`.
Changes to `docker-compose.yml` and new images still need `scripts/update.sh`.

#### Škoda Enyaq

The car is connected via the HACS integration *Škoda API Connect*.
Everything around it lives in this repo:

- `config/has/dashboards/enyaq.yaml` – dashboard (YAML mode) with battery,
  charging, location, climate, doors and a logbook page.
  Needs the HACS frontend cards Mushroom, Lovelace Card Mod and ApexCharts Card.
- `config/has/packages/enyaq_fahrtenbuch.yaml` – logbook: detects trips by the
  mileage, calculates consumption (kWh/100 km) and monthly statistics.
- `config/has/packages/enyaq_ladelog.yaml` – charging log: after unplugging,
  a push notification asks for the price per kWh, so the real costs are tracked.

Both logs can append to CSV files (`config/has/fahrtenbuch.csv`,
`config/has/ladelog.csv`) via the File integration. These files are personal
and therefore ignored by git.

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
