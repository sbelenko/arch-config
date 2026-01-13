import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects 1.0

TextField {
	visible: config.UserField == "true" ? true : false
	id: userField
	height: inputHeight
	width: inputWidth
	selectByMouse: true
	echoMode: TextInput.Normal
	selectionColor: config.Primary
	renderType: Text.NativeRendering
	font {
		family: config.Font
		pointSize: config.BodySize
		weight: Font.Normal
	}
	color: config.OnSurface
	placeholderTextColor: config.OnSurfaceVariant
	horizontalAlignment: Text.AlignHCenter
	placeholderText: "Username"
	text: userModel.lastUser
	
	background: Item {
		implicitWidth: 280
		implicitHeight: 56

		// Material 3 Elevation Level 1 - Key shadow
		DropShadow {
			anchors.fill: bg
			horizontalOffset: 0
			verticalOffset: 1
			radius: 3
			samples: 7
			color: "#26000000"
			source: bg
			cached: true
		}

		// Material 3 Elevation Level 1 - Ambient shadow
		DropShadow {
			anchors.fill: bg
			horizontalOffset: 0
			verticalOffset: 1
			radius: 2
			samples: 5
			color: "#4D000000"
			source: bg
			cached: true
		}

		Rectangle {
			id: bg
			anchors.fill: parent
			radius: 28  // Full rounding (half of 56)
			color: config.SurfaceContainerHighest
			
			// State layer overlay
			Rectangle {
				anchors.fill: parent
				radius: parent.radius
				color: config.OnSurface
				opacity: {
					if (userField.activeFocus) return 0.12
					if (userField.hovered) return 0.08
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
	}
}
