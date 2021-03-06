<?php
/**
 * Acuparse - AcuRite®‎ Access/smartHUB and IP Camera Data Processing, Display, and Upload.
 * @copyright Copyright (C) 2015-2018 Maxwell Power
 * @author Maxwell Power <max@acuparse.com>
 * @link http://www.acuparse.com
 * @license AGPL-3.0+
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this code. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * File: src/pub/archive.php
 * View station archive data
 */

// Get the loader
require(dirname(__DIR__) . '/inc/loader.php');

if ($config->archive->enabled === true) {
    $page_title = 'Weather Archive | ' . $config->site->name;
    include(APP_BASE_PATH . '/inc/header.php');
    ?>

    <div class="row">
        <h1 class="page-header ">Weather Archive</h1>
    </div>
    <section id="weather_archive_display" class="weather_archive_display">
        <div class="row">
            <div id="archive"><img src="/img/archive.gif">
                <h2>Going back in time ...</h2></div>
        </div>
    </section>
    <?php
// Set the footer to include scripts required for this page
    $page_footer =
        '<script>
        $(document).ready(function () {
            function update() {
                $.ajax({
                    url: \'/?archive\',
                    success: function (data) {
                        $("#archive").html(data);
                    }
                });
            }

            update();
        });
    </script>';

    include(APP_BASE_PATH . '/inc/footer.php');

} // Archive not enabled, go home.
else {
    header("Location: /");
}
