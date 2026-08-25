import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property int currentIndex: 0
    property bool expanded: false
    property bool animateSelection: true
    property bool fadeSelection: false
    default property alias tabData: tabBarColumn.data
    implicitHeight: tabBarColumn.implicitHeight
    implicitWidth: tabBarColumn.implicitWidth
    Layout.topMargin: 25

    onCurrentIndexChanged: {
        if (fadeSelection) {
            fadeSwitch.pendingIndex = currentIndex;
            fadeSwitch.restart();
        } else {
            highlight.visualIndex = currentIndex;
        }
    }

    Rectangle {
        id: highlight
        property int visualIndex: 0
        property real itemHeight: tabBarColumn.children[0]?.baseSize ?? 56
        property real baseHighlightHeight: tabBarColumn.children[0]?.baseHighlightHeight ?? 56

        Component.onCompleted: visualIndex = root.currentIndex

        anchors {
            top: tabBarColumn.top
            left: tabBarColumn.left
            topMargin: itemHeight * visualIndex + (root.expanded ? 0 : ((itemHeight - baseHighlightHeight) / 2))
        }
        radius: Appearance.rounding.full
        color: Appearance.colors.colSecondaryContainer
        implicitHeight: root.expanded ? itemHeight : baseHighlightHeight
        implicitWidth: tabBarColumn?.children[visualIndex]?.visualWidth ?? 100

        Behavior on anchors.topMargin {
            enabled: root.animateSelection
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }

        SequentialAnimation {
            id: fadeSwitch
            property int pendingIndex: 0

            NumberAnimation {
                target: highlight
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.OutCubic
            }
            PropertyAction {
                target: highlight
                property: "visualIndex"
                value: fadeSwitch.pendingIndex
            }
            NumberAnimation {
                target: highlight
                property: "opacity"
                to: 1
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    ColumnLayout {
        id: tabBarColumn
        anchors.fill: parent
        spacing: 0
    }
}
