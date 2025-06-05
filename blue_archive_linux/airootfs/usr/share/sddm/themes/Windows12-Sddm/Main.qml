// Copyright 2023 zayronxio <zayronxio@gmail.com>
// Used sources & ideas:
// - SDDM Team https://github.com/sddm/sddm
import QtQuick
import QtQuick.Window 2.15 // Add this import for Window
import SddmComponents 2.0
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts 1.2
import org.kde.plasma.core 2.0 as PlasmaCore
import "components"

// Replace Rectangle with Window
Window {
    id: root
    width: 640
    height: 480
    visible: true // Window needs to be visible
    color: "transparent" // Make the background transparent if needed
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants {
        id: textConstants
    }

    // hack for disable autostart QtQuick.VirtualKeyboard
    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            password.placeholderText = textConstants.loginFailed
            password.placeholderTextColor = "white"
            password.text = ""
            password.focus = true
            errorMsgContainer.visible = true
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        Binding on source {
            when: config.background !== undefined
            value: config.background
        }
    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 0
        radius: 0
        samples: 17
        color: "#70000000"
        source: panel
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.bottomMargin: 35

        Item {
            Image {
                id: shutdown
                height: 22
                width: 22
                source: "images/system-shutdown.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        shutdown.source = "images/system-shutdown-hover.svg"
                        var component = Qt.createComponent("components/ShutdownToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(shutdown)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        shutdown.source = "images/system-shutdown.svg"
                    }
                    onClicked: {
                        shutdown.source = "images/system-shutdown-pressed.svg"
                        sddm.powerOff()
                    }
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 70
        anchors.bottomMargin: 35

        Item {
            Image {
                id: reboot
                height: 22
                width: 22
                source: "images/system-reboot.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        reboot.source = "images/system-reboot-hover.svg"
                        var component = Qt.createComponent("components/RebootToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(reboot)
                            tooltip.x = -100
                            tooltip.y = 40
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        reboot.source = "images/system-reboot.svg"
                    }
                    onClicked: {
                        reboot.source = "images/system-reboot-pressed.svg"
                        sddm.reboot()
                    }
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 84
        anchors.bottomMargin: 15
        Text {
            id: kb
            color: "#eff0f1"
            text: keyboard.layouts[keyboard.currentLayout].shortName
            font.pointSize: 9
            font.weight: Font.DemiBold
        }
        Text {
            id: espacio
            text: "  "
        }

        Image {
            id: sff
            height: 16
            width: 16
            source: "images/keyboard.svg"
            fillMode: Image.PreserveAspectFit
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 123
        anchors.bottomMargin: 15

        ComboBox {
            id: session
            height: 20
            width: 150
            model: sessionModel
            textRole: "name"
            displayText: ""
            currentIndex: sessionModel.lastIndex
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: "transparent"
            }

            delegate: MenuItem {
                id: menuitems
                width: slistview.width * 4
                text: session.textRole ? (Array.isArray(session.model) ? modelData[session.textRole] : model[session.textRole]) : modelData
                highlighted: session.highlightedIndex === index
                hoverEnabled: session.hoverEnabled
                onClicked: {
                    session.currentIndex = index
                    slistview.currentIndex = index
                    session.popup.close()
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 9
                height: parent.height
                width: 18
                color: "transparent"
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: width
                    fillMode: Image.PreserveAspectFit
                    source: "images/conf.svg"
                }
            }

            Popup {
                width: parent.width
                height: parent.height * menuitems.count
                implicitHeight: slistview.contentHeight
                margins: 0
                contentItem: ListView {
                    id: slistview
                    clip: true
                    anchors.fill: parent
                    model: session.model
                    spacing: 0
                    highlightFollowsCurrentItem: true
                    currentIndex: session.highlightedIndex
                    delegate: session.delegate
                }
            }
        }
    }

    Rectangle {
        id: maskleft
        color: "red"
        width: 45
        height: 45
        radius: 100
        visible: false
    }

    // user list added for windows theme
    Component {
        id: userDelegate

        Row {
            spacing: 10
            Image {
                width: 45
                height: 45
                source: model.icon
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: maskleft
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        ava.source = ""
                        ava.source = "/home/" + user.currentText + "/.face.icon"
                        user.currentIndex = index
                        userfocus = true
                    }
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (model.realName === "") ? model.name : model.realName
                color: "white"
                font.pointSize: 9
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        ava.source = ""
                        ava.source = "/home/" + user.currentText + "/.face.icon"
                        user.currentIndex = index
                        user.focus = true
                    }
                }
            }
        }
    }

    ComboBox {
        id: user
        height: 40
        width: 226
        textRole: "name"
        currentIndex: userModel.lastIndex
        model: userModel

        background: Rectangle {
            implicitWidth: parent.width
            implicitHeight: parent.height
            Layout.alignment: Qt.AlignHCenter
            color: "transparent"
        }

        contentItem: Text {
            font.pointSize: 15
            text: user.currentText
            color: "transparent"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: MenuItem {
            font.bold: true
            width: parent.width - 24
            text: user.textRole ? (Array.isArray(user.model) ? modelData[user.textRole] : model[user.textRole]) : modelData
            highlighted: user.highlightedIndex === index
            hoverEnabled: user.hoverEnabled
            onClicked: {
                user.currentIndex = index
                ulistview.currentIndex = index
                user.popup.close()
                ava.source = ""
                ava.source = "/home/" + user.currentText + "/.face.icon"
            }
        }

        indicator: Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 9
            height: parent.height
            width: 24
            color: "transparent"
            Image {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: width
                fillMode: Image.PreserveAspectFit
                source: ""
            }
        }

        popup: Popup {
            width: parent.width
            height: parent.height * parent.count
            implicitHeight: ulistview.contentHeight
            margins: 0
            contentItem: ListView {
                id: ulistview
                clip: true
                anchors.fill: parent
                model: user.model
                spacing: 0
                highlightFollowsCurrentItem: true
                currentIndex: user.highlightedIndex
                delegate: user.delegate
            }
        }
    }

    Rectangle {
        color: "transparent"
        height: parent.height - 20
        width: parent.width - 20
        anchors.top: parent.top
        anchors.right: parent.right

        ListView {
            verticalLayoutDirection: ListView.BottomToTop
            id: mylistView
            focus: true
            height: parent.height
            spacing: 20
            model: userModel
            currentIndex: userModel.lastIndex
            delegate: userDelegate
            orientation: ListView.Vertical
        }
    }

    // fin de codigo agregado para usuarios de windows
    Item {
        width: dialog.width
        height: dialog.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Rectangle {
            id: dialog
            color: "transparent"
            height: 270
            width: 400
        }

        Grid {
            columns: 1
            spacing: 20
            verticalItemAlignment: Grid.AlignVCenter
            horizontalItemAlignment: Grid.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                Item {
                    Rectangle {
                        id: mask
                        width: 185
                        height: 185
                        radius: 100
                        visible: false
                    }

                    DropShadow {
                        anchors.fill: mask
                        width: mask.width
                        height: mask.height
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 15.0
                        samples: 15
                        color: "#50000000"
                        source: mask
                        visible: false
                    }
                }

                Image {
                    id: ava
                    width: 185
                    height: 185
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: mask
                    }
                    source: "/var/lib/AccountsService/icons/" + user.currentText
                    onStatusChanged: {
                        if (status == Image.Error)
                            return source = "images/.face.icon"
                    }
                }

                Item {
                    id: txtuser
                    width: parent.width
                    implicitHeight: usertext.height * 1.7
                    Text {
                        id: usertext
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        text: user.currentText
                        color: "white"
                        opacity: 0.8
                        font.pointSize: 28
                    }
                }
            }

            // user list
            // Custom ComboBox for hack colors on DropDownMenu
            Rectangle {
                width: password.width
                height: password.height
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wallpaper.source = "background-blur.jpg"
                    }
                }

                TextField {
                    id: password
                    height: 32
                    width: 250
                    color: "#fff"
                    echoMode: TextInput.Password
                    focus: true
                    font.weight: Font.DemiBold
                    placeholderText: textConstants.password
                    onAccepted: sddm.login(user.currentText, password.text, session.currentIndex)

                    background: Rectangle {
                        id: formBg
                        implicitWidth: parent.width
                        implicitHeight: parent.height
                        color: "#000"
                        border.color: "#4Df8f8ff"
                        border.width: 2
                        opacity: 0.2
                        radius: 6
                        z: -1
                    }

                    Image {
                        id: caps
                        width: 24
                        height: 24
                        opacity: 0
                        state: keyboard.capsLock ? "activated" : ""
                        anchors.right: password.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        fillMode: Image.PreserveAspectFit
                        source: "images/capslock.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24

                        states: [
                            State {
                                name: "activated"
                                PropertyChanges {
                                    target: caps
                                    opacity: 1
                                }
                            },
                            State {
                                name: ""
                                PropertyChanges {
                                    target: caps
                                    opacity: 0
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                to: "activated"
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: imageFadeIn
                                }
                            },
                            Transition {
                                to: ""
                                NumberAnimation {
                                    target: caps
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: imageFadeOut
                                }
                            }
                        ]
                    }
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    sddm.login(user.currentText, password.text, session.currentIndex)
                    event.accepted = true
                }
            }
        }
    }
}
