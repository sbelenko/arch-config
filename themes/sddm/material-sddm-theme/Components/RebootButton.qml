import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  implicitHeight: rebootButton.height
  implicitWidth: rebootButton.width
  
  Button {
    id: rebootButton
    implicitHeight: inputHeight
    implicitWidth: inputHeight
    hoverEnabled: true
    
    icon {
      source: Qt.resolvedUrl("../icons/reboot.svg")
      height: height * .6
      width: width * .6
      color: config.OnSurfaceVariant
    }
    
    background: Rectangle {
      id: rebootButtonBackground
      radius: inputHeight / 2  // Full corner radius (height / 2)
      color: "transparent"  // Material 3 standard icon buttons are transparent
      
      // State layer overlay
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: config.OnSurface
        opacity: {
          if (rebootButton.pressed) return 0.12
          if (rebootButton.hovered) return 0.08
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
    
    onClicked: sddm.reboot()
  }
}
