import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import Qt5Compat.GraphicalEffects 1.0

Item {
  property var session: sessionList.currentIndex
  implicitHeight: sessionButton.height
  implicitWidth: sessionButton.width
  
  DelegateModel {
    id: sessionWrapper
    model: sessionModel
    delegate: ItemDelegate {
      id: sessionEntry
      height: inputHeight
      width: parent.width
      highlighted: sessionList.currentIndex == index
      
      contentItem: Text {
        renderType: Text.NativeRendering
        font {
          family: config.Font
          pointSize: config.LabelSize
          weight: Font.Medium
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: config.OnSurface
        text: name
      }
      
      background: Rectangle {
        id: sessionEntryBackground
        color: config.SurfaceContainerHighest
        radius: inputHeight / 2  // Full corner radius
        
        // State layer overlay
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          color: config.OnSurface
          opacity: sessionEntry.hovered ? 0.08 : 0
          
          Behavior on opacity {
            NumberAnimation { 
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
        }
      }
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          sessionList.currentIndex = index
          sessionPopup.close()
        }
      }
    }
  }
  
  // Material 3 Elevation Level 1 - Key shadow
  DropShadow {
    anchors.fill: sessionButton
    horizontalOffset: 0
    verticalOffset: 1
    radius: 3
    samples: 7
    color: "#26000000"
    source: sessionButton
    cached: true
  }
  
  // Material 3 Elevation Level 1 - Ambient shadow
  DropShadow {
    anchors.fill: sessionButton
    horizontalOffset: 0
    verticalOffset: 1
    radius: 2
    samples: 5
    color: "#4D000000"
    source: sessionButton
    cached: true
  }
  
  Button {
    id: sessionButton
    implicitHeight: inputHeight
    implicitWidth: inputHeight
    hoverEnabled: true
    
    icon {
      source: Qt.resolvedUrl("../icons/settings.svg")
      height: height * .6
      width: width * .6
      color: config.OnSurfaceVariant
    }
    
    background: Rectangle {
      id: sessionButtonBackground
      color: config.SurfaceContainerHighest
      radius: inputHeight / 2  // Full corner radius
      
      // State layer overlay
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: config.OnSurface
        opacity: {
          if (sessionButton.pressed) return 0.12
          if (sessionButton.hovered) return 0.08
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
      sessionPopup.visible ? sessionPopup.close() : sessionPopup.open()
    }
  }
  
  Popup {
    id: sessionPopup
    width: inputWidth + padding * 2
    x: (sessionButton.width + sessionList.spacing) * -7.6
    y: -(contentHeight + padding * 2) + sessionButton.height
    padding: inputHeight / 10
    
    background: Item {
      // Material 3 Elevation Level 3 - Key shadow
      DropShadow {
        anchors.fill: popupBg
        horizontalOffset: 0
        verticalOffset: 4
        radius: 8
        samples: 17
        color: "#26000000"
        source: popupBg
        cached: true
      }
      
      // Material 3 Elevation Level 3 - Ambient shadow
      DropShadow {
        anchors.fill: popupBg
        horizontalOffset: 0
        verticalOffset: 4
        radius: 6
        samples: 13
        color: "#4D000000"
        source: popupBg
        cached: true
      }
      
      Rectangle {
        id: popupBg
        anchors.fill: parent
        radius: 28  // Extra large corner radius
        color: config.SurfaceContainer
      }
    }
    
    contentItem: ListView {
      id: sessionList
      implicitHeight: contentHeight
      spacing: 8
      model: sessionWrapper
      currentIndex: sessionModel.lastIndex
      clip: true
    }
    
    enter: Transition {
      ParallelAnimation {
        NumberAnimation {
          property: "opacity"
          from: 0
          to: 1
          duration: 300
          easing.type: Easing.OutCubic
        }
        NumberAnimation {
          property: "scale"
          from: 0.9
          to: 1.0
          duration: 300
          easing.type: Easing.OutCubic
        }
      }
    }
    
    exit: Transition {
      ParallelAnimation {
        NumberAnimation {
          property: "opacity"
          from: 1
          to: 0
          duration: 200
          easing.type: Easing.OutCubic
        }
        NumberAnimation {
          property: "scale"
          from: 1.0
          to: 0.9
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
