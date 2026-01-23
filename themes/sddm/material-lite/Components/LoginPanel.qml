import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects 1.0

Item {
  property var user: userSelection.selectedUser
  property var password: passwordField.text
  property var session: sessionPanel.session
  property var inputHeight: Screen.height * 0.032
  property var inputWidth: Screen.width * 0.16

  // Optional background container with elevation
  Item {
    id: loginBackgroundContainer
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    height: inputHeight * ( config.UserIcon == "true" ? 11.2 : 5.3 )
    width: inputWidth * 1.2
    visible: config.LoginBackground == "true" ? true : false

    // Material 3 Elevation Level 3 - Key shadow
    DropShadow {
      anchors.fill: loginBackground
      horizontalOffset: 0
      verticalOffset: 4
      radius: 8
      samples: 17
      color: "#26000000"
      source: loginBackground
      cached: true
    }

    // Material 3 Elevation Level 3 - Ambient shadow
    DropShadow {
      anchors.fill: loginBackground
      horizontalOffset: 0
      verticalOffset: 4
      radius: 6
      samples: 13
      color: "#4D000000"
      source: loginBackground
      cached: true
    }

    Rectangle {
      id: loginBackground
      anchors.fill: parent
      radius: 5  // Extra large corner radius
      color: config.Surface
    }
  }

  Column {
    spacing: 8
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    PowerButton {
      id: powerButton
    }
    RebootButton {
      id: rebootButton
    }
    SleepButton {
      id: sleepButton
    }
    z: 5
  }

  Column {
    spacing: 8
    anchors {
      bottom: parent.bottom
      right: parent.right
    }
    SessionPanel {
      id: sessionPanel
    }
    z: 5
  }

  Column {
    spacing: 16  // 16dp spacing per Material 3 grid
    z: 5
    width: inputWidth
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
    }

    UserSelection {
      id: userSelection
      height: inputHeight
      width: parent.width
    }

    PasswordField {
      id: passwordField
      height: inputHeight
      width: parent.width
      onAccepted: loginButton.clicked()
    }

    Item {
      implicitHeight: loginButton.height
      implicitWidth: parent.width

      // Material 3 Elevation Level 1 - Key shadow for button
      DropShadow {
        anchors.fill: loginButton
        horizontalOffset: 0
        verticalOffset: 1
        radius: 3
        samples: 7
        color: "#26000000"
        source: loginButton
        cached: true
        visible: loginButton.enabled
      }

      // Material 3 Elevation Level 1 - Ambient shadow for button
      DropShadow {
        anchors.fill: loginButton
        horizontalOffset: 0
        verticalOffset: 1
        radius: 2
        samples: 5
        color: "#4D000000"
        source: loginButton
        cached: true
        visible: loginButton.enabled
      }

      Button {
        id: loginButton
				visible: config.LoginButton == "true" ? true : false
        implicitHeight: inputHeight
        implicitWidth: parent.width
				enabled: true
        hoverEnabled: true

        contentItem: Text {
          id: buttonText
					visible: config.LoginButton == "true" ? true : false
          renderType: Text.NativeRendering
          font {
            family: config.Font
            pointSize: config.LabelSize
            weight: Font.Medium
          }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          color: config.OnPrimary
          text: "Login"
          opacity: loginButton.enabled ? 1.0 : 0.38
        }

        background: Rectangle {
          id: buttonBackground
					visible: config.LoginButton == "true" ? true : false
          radius: 5  // Full rounding
          color: loginButton.enabled ? config.Primary : config.OnSurface
          opacity: loginButton.enabled ? 1.0 : 0.12

          // State layer overlay
          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: config.OnPrimary
            opacity: {
              if (!loginButton.enabled) return 0
              if (loginButton.pressed) return 0.12
              if (loginButton.hovered) return 0.08
              return 0
            }

            Behavior on opacity {
              NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
              }
            }
          }
        }

        onClicked: {
          sddm.login(user, password, session)
        }
      }
    }
  }

  Connections {
    target: sddm

    function onLoginFailed() {
      passwordField.text = ""
      passwordField.focus = true
    }
  }
}
