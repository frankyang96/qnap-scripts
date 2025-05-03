# qnap-scripts
some QNAP scripts used by myself

power_off_links_down.sh

 Used when QNAP is connected a UPS but not supporting any communication protocal.
 Then this script can ping router, if fails then check if both physical links are down or not, to see if all other devices are down.
 After that to execute power-off within 1 min.


need to add this file into /etc/config/crontab 
 * * * * * /share/homes/admin/power_off_link_down.sh

Make above crontab file effect:
crontab /etc/config/crontab && /etc/init.d/crond.sh restart

