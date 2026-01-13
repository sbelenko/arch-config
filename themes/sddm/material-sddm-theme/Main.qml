import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "Components"

Item {
  id: root
  height: Screen.height
  width: Screen.width
  
  Rectangle {
    id: background
    anchors.fill: parent
    color: config.Surface  // Use Material 3 surface color
  }
  
  Item {
    id: mainPanel
    z: 3
    anchors {
      fill: parent
      margins: 50
    }
    
    Clock {
      id: time
      visible: config.ClockEnabled == "true" ? true : false
    }
    
    LoginPanel {
      id: loginPanel
      anchors.fill: parent
    }
  }
}
