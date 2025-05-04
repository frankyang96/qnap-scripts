# qnap-scripts

A collection of personal scripts used on QNAP NAS devices.

## Script: `power_off_links_down.sh`

This script is used when your QNAP NAS is connected to a UPS that **does not support any communication protocol**.

### Purpose

The script performs the following:

1. Pings the router (or gateway).
2. If the ping fails, it checks whether **both physical network links** are down.
3. If both conditions are true, the NAS will **power off within 1 minute**.

### Usage

### 1. Place the Script

### Copy the script to your home directory (or preferred path):

```bash
/share/homes/admin/power_off_links_down.sh
```

### add following into /etc/config/crontab
```bash
 * * * * * /share/homes/admin/power_off_link_down.sh
```


### Make above crontab file effect:

```bash
crontab /etc/config/crontab && /etc/init.d/crond.sh restart
```


## Script: `check_cert.sh`
### Purpose

The script performs the following:

1. check if certs under acme is different.
2. If different then replace qnap apache certs and jellyfin certs.
3. then call resend-api to send mail

### Usage

### 1. Place the Script

### Copy the script to your home directory (or preferred path):

```bash
/share/homes/admin/check_cert.sh
```

### add following into /etc/config/crontab
```bash
 35 04 * * * /share/homes/admin/check_cert.sh
```


