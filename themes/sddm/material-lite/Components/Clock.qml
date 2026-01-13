import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  id: clockContainer
  anchors {
    margins: 10
    top: parent.top
    right: parent.right
    left: parent.left
  }
  height: dateText.height + timeText.height + 8
  
  Column {
    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
    }
    spacing: 4
    
    // Date on top
    Text {
      id: dateText
      anchors.horizontalCenter: parent.horizontalCenter
      color: config.OnSurfaceVariant
      font {
        family: config.Font
        pointSize: config.HeadlineSize
        weight: Font.Normal
      }
      renderType: Text.NativeRendering
      
      function updateDate() {
        var now = new Date()
        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var months = ["January", "February", "March", "April", "May", "June", 
                      "July", "August", "September", "October", "November", "December"]
        
        text = days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear()
      }
      
      Component.onCompleted: updateDate()
      
      Timer {
        interval: 60000 // Update every minute
        running: true
        repeat: true
        onTriggered: dateText.updateDate()
      }
    }
    
    // Time below
    Text {
      id: timeText
      anchors.horizontalCenter: parent.horizontalCenter
      color: config.OnSurface
      font {
        family: config.Font
				pointSize: config.DisplaySize
				weight: Font.Bold
      }
      renderType: Text.NativeRendering
      
      function updateTime() {
        var now = new Date()
        var hours = now.getHours().toString().padStart(2, '0')
        var minutes = now.getMinutes().toString().padStart(2, '0')
        text = hours + ":" + minutes
      }
      
      Component.onCompleted: updateTime()
      
      Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: timeText.updateTime()
      }
    }
  }
}
