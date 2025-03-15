/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
 
import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0

ColumnLayout {
    spacing: 2
    property string fontstyle : "Fonts/FontsFree-Net-SF-UI-Text-Bold.ttf"
     property string fontstylelight : "Fonts/SFUIText-Semibold.otf"
    FontLoader {
        id : loginfont
        source : fontstyle
    }
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    Label {
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        color: "white"
        opacity: 0.5
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        font.pointSize: 20
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        font.family: config.name

    }
    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
        color: "white"
        opacity: 0.5
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        font.pointSize: 100
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        font.family: config.name

    }
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

}
