#!/bin/sh
##
# Acuparse - AcuRite®‎ Access/smartHUB and IP Camera Data Processing, Display, and Upload.
# @copyright Copyright (C) 2015-2018 Maxwell Power
# @author Maxwell Power <max@acuparse.com>
# @link http://www.acuparse.com
# @license AGPL-3.0+
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this code. If not, see <http://www.gnu.org/licenses/>.
##

##
# File: cam/templates/remote.sh
# Remote IP camera upload shell script
##

### USER VALUES ###
WU_CAM_USER='' # WeatherUnderground Webcam user
WU_CAM_PASS='' # WeatherUnderground Webcam password
### END USER VALUES ###

WEBDIR='/opt/acuparse/src/pub/img/cam'
BASEDIR='/opt/acuparse/cam/tmp'
ARCHIVE_DATE=$(date +"%Y-%m-%d")
ARCHIVE_TIME=$(date +"%H%M")
STATION_INFO=$(wget 'http://127.0.0.1/?cam' -q -O -)
APACHE_USER='www-data'
APACHE_GROUP='www-data'

echo "Starting remote processing"

cd $BASEDIR

echo "Applying Weather Info Watermark"
convert image.jpg \
    -font DejaVu-Sans-Bold -pointsize 12 \
    -draw "gravity south \
        fill black  text 0,18 '$STATION_INFO' \
        fill OrangeRed2  text 1,19 '$STATION_INFO' " \
    image.jpg

echo "Sending image to Weather Underground"
ftp -n webcam.wunderground.com <<EOF > /opt/acuparse/logs/wu_upload.log 2>&1
quote USER $WU_CAM_USER
quote PASS $WU_CAM_PASS
binary
put image.jpg
quit
EOF

echo "Moving image to webserver"
cp image.jpg $WEBDIR/latest.jpg
mkdir -p $WEBDIR/$ARCHIVE_DATE
cp image.jpg $WEBDIR/$ARCHIVE_DATE/$ARCHIVE_TIME.jpg
chown -R $APACHE_USER:$APACHE_GROUP $WEBDIR

echo "Updating Animation"
convert -delay 25 -loop 0 $WEBDIR/$ARCHIVE_DATE/*.jpg $WEBDIR/$ARCHIVE_DATE/daily.gif

echo "Removing processed image"
rm image.jpg*

echo "Done Remote Processing"
