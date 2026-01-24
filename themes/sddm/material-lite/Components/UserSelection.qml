import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property alias selectedUser: userName.text
    property int currentIndex: sddm.userModel.count > 0 ? (sddm.userModel.lastIndex >= 0 && sddm.userModel.lastIndex < sddm.userModel.count ? sddm.userModel.lastIndex : 0) : -1

    function changeUser(step) {
        var newIndex = currentIndex + step;
        if (newIndex >= sddm.userModel.count) {
            newIndex = 0;
        } else if (newIndex < 0) {
            newIndex = sddm.userModel.count - 1;
        }
        currentIndex = newIndex;
    }

    Connections {
        target: sddm.userModel
        function onCountChanged() {
            if (sddm.userModel.count > 0) {
                root.currentIndex = sddm.userModel.lastIndex >= 0 && sddm.userModel.lastIndex < sddm.userModel.count ? sddm.userModel.lastIndex : 0;
            } else {
                root.currentIndex = -1;
            }
        }
    }

    Item {
        anchors.fill: parent

        // Background item from original UserField
        Item {
            implicitWidth: 280
            implicitHeight: 56
            anchors.fill: parent

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 28
                color: config.SurfaceContainerHighest
                
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: config.OnSurface
                    opacity: 0
                }
            }
        }
    }

    Row {
        id: userSelectionRow
        anchors.fill: parent
        spacing: 10
        visible: sddm.userModel.count > 0

        // Left Arrow
        Item {
            id: leftArrowContainer
            width: parent.height
            height: parent.height
            visible: sddm.userModel.count > 1
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: leftArrowIcon
                source: "icons/arrow-left.svg"
                anchors.fill: parent
                anchors.margins: 12
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
            }
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: width / 2
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.changeUser(-1)
                    
                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? "rgba(255, 255, 255, 0.1)" : "transparent"
                        radius: parent.radius
                        border.color: parent.containsMouse ? "rgba(255, 255, 255, 0.2)" : "transparent"
                        border.width: 1
                    }
                }
            }
        }

        // User Name
        Text {
            id: userName
            text: root.currentIndex >= 0 ? sddm.userModel.get(root.currentIndex).name : ""
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
            color: config.OnSurface
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: userSelectionRow.width - (leftArrowContainer.width + rightArrowContainer.width)
        }

        // Right Arrow
        Item {
            id: rightArrowContainer
            width: parent.height
            height: parent.height
            visible: sddm.userModel.count > 1
            anchors.verticalCenter: parent.verticalCenter
            
            Image {
                id: rightArrowIcon
                source: "icons/arrow-right.svg"
                anchors.fill: parent
                anchors.margins: 12
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
            }
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: width / 2

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.changeUser(1)

                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? "rgba(255, 255, 255, 0.1)" : "transparent"
                        radius: parent.radius
                        border.color: parent.containsMouse ? "rgba(255, 255, 255, 0.2)" : "transparent"
                        border.width: 1
                    }
                }
            }
        }
    }
}
