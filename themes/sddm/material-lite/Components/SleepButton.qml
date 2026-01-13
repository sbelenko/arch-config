import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  implicitHeight: sleepButton.height
  implicitWidth: sleepButton.width
  
  Button {
    id: sleepButton
    implicitHeight: inputHeight
    implicitWidth: inputHeight
    hoverEnabled: true
    
    icon {
      source: Qt.resolvedUrl("../icons/sleep.svg")
      height: height * .6
      width: width * .6
      color: config.OnSurfaceVariant
    }
    
    background: Rectangle {
      id: sleepButtonBg
      radius: inputHeight / 2  // Full corner radius (height / 2)
      color: "transparent"  // Material 3 standard icon buttons are transparent
      
      // State layer overlay
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: config.OnSurface
        opacity: {
          if (sleepButton.pressed) return 0.12
          if (sleepButton.hovered) return 0.08
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
    
    onClicked: sddm.suspend()
  }
}
