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
# File: cam/templates/combined.sh
# Combined IP camera shell script
##

### USER VALUES ###
WU_CAM_USER='' # WeatherUnderground Webcam user
WU_CAM_PASS='' # WeatherUnderground Webcam password
WATERMARK='Station Name | Station Web Address' # Image Watermark Text
CAMERA_HOST='http://' # The camera host
CAMERA_FILENAME='snapshot.jpg' # Camera image name
RESIZE='50%'
### END USER VALUES ###

BASEDIR='/opt/acuparse/cam/tmp'
WEBDIR='/opt/acuparse/src/pub/img/cam'
ARCHIVE_DATE=$(date +"%Y-%m-%d")
ARCHIVE_TIME=$(date +"%H%M")
STATION_INFO=$(wget 'http://127.0.0.1/?cam' -q -O -)
TIMESTAMP=$(date +"%A, %d %B %Y %H:%M %Z")

echo "Getting camera image"
wget $CAMERA_HOST/$CAMERA_FILENAME

echo "Applying Timestamp and Copyright"
convert $CAMERA_FILENAME \
    -resize $RESIZE \
    -font DejaVu-Sans-Bold -pointsize 20 \
    -draw "gravity south \
        fill black  text 0,36 '$TIMESTAMP' \
        fill OrangeRed2  text 1,37 '$TIMESTAMP' " \
    -font DejaVu-Sans-Bold -pointsize 12 \
    -draw "gravity south \
        fill black  text 0,18 '$STATION_INFO' \
        fill OrangeRed2  text 1,19 '$STATION_INFO' " \
    -draw "gravity south \
        fill black  text 0,0 '$WATERMARK' \
        fill OrangeRed2  text 1,1 '$WATERMARK' " \
    image.jpg

echo "Sending image to Weather Underground"
ftp -n webcam.wunderground.com <<END_SCRIPT > /opt/acuparse/logs/wu_upload.log 2>&1
quote USER $WU_CAM_USER
quote PASS $WU_CAM_PASS
binary
put image.jpg
quit
END_SCRIPT

echo "Moving image to webserver"
cp image.jpg $WEBDIR/latest.jpg
mkdir -p $WEBDIR/$ARCHIVE_DATE
cp image.jpg $WEBDIR/$ARCHIVE_DATE/$ARCHIVE_TIME.jpg
chown -R www-data:www-data $WEBDIR
echo "Updating Animation"
convert -delay 25 -loop 0 $WEBDIR/$ARCHIVE_DATE/*.jpg $WEBDIR/$ARCHIVE_DATE/daily.gif

echo "Cleaning up files"

rm image.jpg*
rm $CAMERA_FILENAME*

echo "Done Processing"