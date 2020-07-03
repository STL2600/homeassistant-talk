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

# Wakeup Routine

# Fake Being Home

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
