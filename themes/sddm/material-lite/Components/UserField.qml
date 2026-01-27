import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects 1.0

Item {
	visible: config.UserField == "true" ? true : false
	id: userField
	height: inputHeight
	width: inputWidth

	property string currentName: userList.currentItem ? userList.currentItem.userNameData : ""

	Item {
		anchors.fill: parent

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
				opacity: 0
			}
		}
	}

	ListView {
		id: userList
		anchors.fill: parent
		orientation: ListView.Horizontal
		snapMode: ListView.SnapToItem
		highlightRangeMode: ListView.StrictlyEnforceRange
		clip: true
		model: userModel
		currentIndex: userModel.lastIndex

		delegate: Item {
			width: userField.width
			height: userField.height
			property string userNameData: name

			Text {
				anchors.centerIn: parent
				text: name
				color: config.OnSurface
				renderType: Text.NativeRendering
				font {
					family: config.Font
					pointSize: config.BodySize
					weight: Font.Normal
				}
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
		}
	}

	Item {
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		width: height
		height: parent.height
		visible: userList.count > 1

		Text {
			anchors.centerIn: parent
			anchors.verticalCenterOffset: -2
			text: "‹"
			color: config.OnSurface
			font.pixelSize: 30
			font.family: config.Font
			renderType: Text.NativeRendering
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: userList.decrementCurrentIndex()
		}
	}

	Item {
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		width: height
		height: parent.height
		visible: userList.count > 1

		Text {
			anchors.centerIn: parent
			anchors.verticalCenterOffset: -2
			text: "›"
			color: config.OnSurface
			font.pixelSize: 30
			font.family: config.Font
			renderType: Text.NativeRendering
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: userList.incrementCurrentIndex()
		}
	}
}
