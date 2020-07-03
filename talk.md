# Installation Methods

 - HomeAssistant
 - HomeAssistant Core
 - HomeAssistant Supervised

## Installation - HomeAssistant

 - Comes as a whole operating system installation
 - Can be installed on a VM, Pi, or other bare metal machine
 - Is the "blessed" installation mode

## Installation - Core

 - A single docker container with _just_ the core of HomeAssistant
 - More difficult to install plugins, but basic functionality works

## Installation - Supervised

 - Install the full package on your own OS
 - Supports plugins and other packages
 - Less supported than normal install

# Exposing HA

 - Don't
 - Nabu Casa
 - VPN
 - Reverse Proxy

## Exposing HA - Don't

 - Just automations
 - Local access

## Exposing HA - Nabu Casa

 - Easy to setup
 - Support HA Development

## Exposing HA - VPN

 - You might already have it set up
 - Probably most secure remote access

## Exposing HA - Reverse Proxy

 - NGINX
 - HAProxy
 - Traefik

## Exposing HA - NGINX

```
worker_processes  1;

error_log /var/log/nginx/error.log;

events {
    worker_connections  1024;
}



http {
    access_log /var/log/nginx/access.log;
    default_type application/octet-stream;
    include mime.types;
    keepalive_timeout 65;
    resolver 127.0.0.11 valid=300s;
    resolver_timeout 10s;
    sendfile on;

    # Options for websocket forwarding
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    server {
        listen 80;
        listen 443 ssl;
        server_name ha.server.rtward.com;

        if ($scheme != "https") {
            return 301 https://$host$request_uri;
        }

        ssl_certificate /etc/letsencrypt/live/rtward.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/rtward.com/privkey.pem;

        location / {
            proxy_pass http://localhost:8123;
	    proxy_set_header Host $host;
	    proxy_redirect http:// https://;
	    proxy_http_version 1.1;
	    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    proxy_set_header Upgrade $http_upgrade;
	    proxy_set_header Connection $connection_upgrade;
        }
    }
}

```

## Exposing HA - HAProxy

```
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3
	maxconn 2048
	tune.ssl.default-dh-param 2048

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
	timeout connect 5000
	timeout client  50000
	timeout server  50000
	timeout tunnel  60000    # long enough for websocket pings every 55 seconds
	timeout http-request 5s  # protection from Slowloris attacks

frontend www-http
	bind *:80
	redirect scheme https

frontend www-https
	log /dev/log	local0 debug
	bind *:443 ssl crt /etc/haproxy/certs/MYCERT.pem
	acl hass-acl hdr(host) -i SUBDOMAIN.DOMAIN.COM
	use_backend hass-backend if hass-acl

backend hass-backend
	server hass <Home Assistant Server IP>:8123

	mode http
	option forwardfor
	http-request add-header X-Forwarded-Proto https
	http-request add-header X-Forwarded-Port 443
```

## Exposing HA - Traefik

 - GUI Config
 - Auto SSL
 - Easiest option for non-techies

# Toolbox

# Devices

# Cameras

## Cameras - Models

 - ONVIF - Standard profile that means a camera can likely be integrated
 - POE makes things easier

## Cameras - Config

 Stream device in the `configuration.yaml` file
 ```
 stream:
   stream_source: rtsp://my.camera:554
 ```

## Cameras - Dashbaord

 - Once configured, can add camera feed in GUI

## Cameras - Motion Detection

 - Once configured, you can use the `enable_motion_detection` service on the camera
 - This will emit events when motion starts and ends on the camera

## Cameras - Doods

 - Distributed outside object detection service
 - Installed via a HACS plugin
 - Detects / categorizes obects in a video stream
 - Can react to events like "when a car is seen"

## Cameras - Facebox

 - Can perform face detection and recognition
 - Can emit events when certain faces are seen

## Cameras - Recording

 - HA is not a NVR
 - Can use third party software since network streams aren't unique
 - Motion - Simplest option
 - Zoneminder - More heavyweight, more features


# Door / Window Sensors

## ZWave / Zigbee

 - Lots of good options
 - Easy to setup
 - Long battery life
 - Usually other sesonrs built in

## Hardwired

 - Can use RPi GPIO pins if running on pi
 - ESP MQTT Bridge

## Events

 - Emit on open and close
 - Battery level

## Models

 https://www.amazon.com/Aeotec-Window-Contact-sensors-Battery/dp/B07PDDX3K6/ref=sr_1_9?dchild=1&keywords=zwave+door+sensor&qid=1593566140&sr=8-9

# Motion Sensors

## ZWave / Zigbee

 - Lots of good options
 - Easy to setup
 - Long battery life
 - Usually other sesonrs built in

## Cameras

 - Multi-purpose
 - Privacy issues

## Events

 - Emit events on motion
 - Security alarms
 - Lighting

## Models

 https://www.amazon.com/Inovelli-Temperature-SmartThings-Encryption-SmartStart/dp/B07YCWRCPH/ref=sr_1_6?dchild=1&keywords=zwave+motion+sensor&qid=1593565519&sr=8-6

# Door Locks

## ZWave / Zigbee

 - Private network
 - Lower power usage

## WiFi

 - Security issues
 - Higher Power Usage
 
## Bluetooth

 - Security issues
 - App controlled, harder to integrate

# Switches / Lights

## Smart Switches

 - Prefer ZWave / Zigbee
 - Prefer switches to bulbs

 https://www.amazon.com/Inovelli-Repeater-Technology-Indicator-SmartStart/dp/B07RYMSH6Q/ref=pd_bxgy_2/143-6128294-1367931?_encoding=UTF8&pd_rd_i=B07RYMSH6Q&pd_rd_r=88aa62f7-4099-468c-b43d-1f5c7c8112b8&pd_rd_w=Xh27R&pd_rd_wg=HO0Re&pf_rd_p=4e3f7fc3-00c8-46a6-a4db-8457e6319578&pf_rd_r=Z9RH0DS7G665AWM2FKHH&psc=1&refRID=Z9RH0DS7G665AWM2FKHH

## Smart Bulbs

 - Lots of options
   - Hue
   - Ikea
 - Can be more difficult to integrate with legacy switches

# Alerting

  - Audible Alerts
  - Visual
  - Notifications

## Audible Alerts

  - Roll your own smart speakers
  - HA integrates with pretty much any media player platform

## Audible Alerts - DIY Smart Speakers

  - Snapcast with Raspberry Pi's is just one option
  - Allows you to logically group speakers
  - Switch between audio streams
      - Play alarm audio
      - Text to Speech message

## Audible Alerts - Media Players

  - If the player accepts streams, do the same as Snapcast
  - Or you can pull a "Kevin McCallister"

## Visual Alerts

  - Smart Lighting
  - Media Players

## Visual Alerts - Smart Lights

  - Easiest option is to blinking patterns
  - Add a smart plug to a strobe or siren light
  - Multi-color LED strips

## Visual Alerts - Media Players

  - Cast a camera stream as an alert
  - Play a pre-recorded video
  - HA can send notifications to some players, like Kodi

## Notifications

  - HA has dedicated functions for notifications
  - Allows for alerts when not at home

## Notifications

  - Various Messaging Clients
  - SMS Text Messages
  - HA Companion App

## Notifications - Messaging Clients

  - Texting clients like Facebook, Hangouts, Telegram
  - Groupware like Slack, MS Teams, Matrix
  - Twitter
  - Signal!

## Notifications - SMS Texting

  - Service provided, like Twilio
  - GSM-Modem

## Notifications - SMS Texting

  - GSM-Modem
    - Cheap Burner Phone
    - Out-of-Band

## Notifications - HA App

  - Official Companion App for iOS and Android
  - Direct to your instance. No third party services.

## HA and Your Network

  - Leveraging HA as a makshift IDS
    - Integration to Cisco, Ubiquiti, and other hardware
    - Fail2Ban
    - Shodan
    - HaveIBeenPwned
    - Pretty much anything else...

## HA Networking - Router Integration

  - Can be used to detect new devices on your network
  - OpenWRT and ubus as an example

## HA Networking - Router Integration

Configure by adding to `configuration.yaml`
```
device_tracker:
  - platform: ubus
    host: ROUTER_IP_ADDRESS
    username: YOUR_ADMIN_USERNAME
    password: !secret openwrt_password
    new_device_defaults:
      track_new_devices: true
```

## HA Networking - Router Integration

Create `known_devices.yaml` list:
```
devicename:
  name: Friendly Name
  mac: EA:AA:55:E7:C6:94
  picture: https://www.home-assistant.io/images/favicon-192x192.png
  track: true
```

## HA Networking - Router Integration

```
- id: '1593583785160'
  alias: New Device Detected Automation
  description: 'Send Notification when DHCP issues a new IP'
  trigger:
  - entity_id: device_tracker.ubus
    platform: state
  condition: []
  action:
  - data:
      message: A new device has connected to your network
    service: notify.mobile_app_pixel_3
```

## HA Networking - Fail2Ban

  - Allows you to import IPs banned by fail2ban

## HA Networking - Fail2Ban

Setup by adding to `configuration.yaml`

```
sensor:
  - platform: fail2ban
    jails:
      - ssh-iptables
```

## HA Networking - Fail2Ban

```
- id: '1593583785160'
  alias: Fail2Ban Automation
  description: 'Send Notification on Fail2Ban'
  trigger:
  - entity_id: sensor.fail2ban_sensor
    platform: state
  condition: []
  action:
  - data:
      message: Fail2Ban has been triggered
    service: notify.mobile_app_pixel_3
``` 

## HA Networking - Shodan

  - Get alerts based on any Shodan query
  - Use to be notified of open ports on the Internet

## HA Networking - Shodan

Setup by adding to `configuration.yaml`

```
sensor:
  - platform: shodan
    api_key: !secret shodan_key
    query: 'net:IP_ADDRESS'
```

## HA Networking - Shodan

```
- id: '1593583785160'
  alias: Shodan Automation
  description: 'Send Notification from Shodan'
  trigger:
  - entity_id: sensor.shodan_sensor
    platform: state
  condition: []
  action:
  - data:
      message: Shodan reports additional ports exposed on your network
    service: notify.mobile_app_pixel_3
```

## HA Networking - HaveIBeenPwned

  - Get alerts on email addresses involved in breaches
  - Can track multiple email addresses
  - Not free.  $3.50 a month.

## HA Networking - HaveIBeenPwned

Setup by adding to `configuration.yaml`
```
sensor:
  - platform: haveibeenpwned
    email:
      - root@example.com
    api_key: !secret haveibeenpwned-api
```

## HA Networking - HaveIBeenPwned
```
- id: '1593583449893'
  alias: HaveIBeenPwned - Automation
  description: ''
  trigger:
  - entity_id: sensor.breaches_root_example_com
    platform: state
  condition: []
  action:
  - data:
      message: HaveIBeenPwn reports a breach for root@example.com
    service: notify.mobile_app_pixel_3
```


# Getting Creative

# Energy Saver

## Conditions

 - When all people have left the house
 - When no motion is detected

## Actions

 - Turn off all lights
 - Turn off TVs

# Smart Thermostat

# Kid Friendly Lighting

## Conditions

 - At Bedtime

## Actions

 - Set max light level to 20%

# Bedtime Routine

## Triggers

  - On bedroom motion sensor

## Conditions

  - After 10:00 PM
  - Phone state is Charging

## Actions

  - Active Bedtime Scene
    - Turn off all lights
    - Mute Smart Speakers
    - Lowers Thermostat
    - Run Script that turns off the TV

# Wakeup Routine

## Triggers

  - At 6:00 AM

## Conditions

 - Checks if it's a Weekday

## Actions

  - Increase Thermostat
  - Delay 50 Minutes
  - Activate Smart Plug on Coffee Pot
  - Delay 10 Minutes
  - Activate Wake-Up Scene
    - Playlist through Smart Speakers
    - Turn on Bedroom, Bathroom, and Kitchen Lights

# Fake Being Home

Go Full "Home Alone"...

## Triggers

  - On outdoor motion sensor or camera.

## Actions

  - Call Script to turn TV on
  - Play a movie on media player
  - Turn on lights
  - Start robot vacuum with cardboard cutout

# Automatic Lights

## Conditions

 - When motion is detected in area
 - And the sun is down

## Actions

 - Turn on lights to 10%

# Auto Unlock Door

## Conditions

 - When prescense detection shows you at home
 - And your face is seen on doorbel camera

## Actions

 - Unlock front door

# Internet Radio Station

 - Components
   - Mopidy or another MPD server
   - Icecast Server
   - Playlists are schedule with HA Automations

