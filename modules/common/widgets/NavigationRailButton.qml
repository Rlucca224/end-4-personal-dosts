import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

TabButton {
    id: root

    property bool toggled: TabBar.tabBar.currentIndex === TabBar.index
    property string buttonIcon
    property real buttonIconRotation: 0
    property string buttonText
    property bool expanded: false
    property bool __animReady: false
    property bool showToggledHighlight: true
    readonly property real visualWidth: root.expanded ? root.baseSize + 20 + itemText.implicitWidth : root.baseSize

    property bool rippleEnabled: true
    property int rippleDuration: 600
    property color rippleColor: toggled ? Appearance.colors.colSecondaryContainerActive : Appearance.colors.colLayer1Active

    function startRipple(x, y) {
        rippleAnim.x = x;
        rippleAnim.y = y;
        rippleAnim.radius = Math.sqrt(itemBackground.width * itemBackground.width + itemBackground.height * itemBackground.height);
        rippleFadeAnim.complete();
        rippleAnim.restart();
    }

    component RippleAnim: NumberAnimation {
        duration: root.rippleDuration
        easing.type: Appearance.animation.elementMoveEnter.type
        easing.bezierCurve: Appearance.animationCurves.standardDecel
    }

    RippleAnim {
        id: rippleFadeAnim
        duration: root.rippleDuration * 1.5
        target: ripple
        property: "opacity"
        to: 0
    }

    SequentialAnimation {
        id: rippleAnim
        property real x
        property real y
        property real radius

        PropertyAction { target: ripple; property: "x"; value: rippleAnim.x }
        PropertyAction { target: ripple; property: "y"; value: rippleAnim.y }
        PropertyAction { target: ripple; property: "opacity"; value: 1 }
        ParallelAnimation {
            RippleAnim {
                target: ripple
                properties: "implicitWidth,implicitHeight"
                from: 0
                to: rippleAnim.radius * 2
            }
        }
    }

    Component.onCompleted: Qt.callLater(() => Qt.callLater(() => root.__animReady = true))

    property real baseSize: 56
    property real baseHighlightHeight: 32
    property real highlightCollapsedTopMargin: 8
    padding: 0

    Layout.fillWidth: true
    implicitHeight: baseSize

    background: null
    PointingHandInteraction {}

    contentItem: Item {
        id: buttonContent
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: undefined
        }
        
        implicitWidth: root.visualWidth
        implicitHeight: root.expanded ? itemIconBackground.implicitHeight : itemIconBackground.implicitHeight + itemText.implicitHeight 

        Rectangle {
            id: itemBackground
            anchors.top: itemIconBackground.top
            anchors.left: itemIconBackground.left
            anchors.bottom: itemIconBackground.bottom
            implicitWidth: root.visualWidth
            radius: Appearance.rounding.full
            color: toggled ? 
                root.showToggledHighlight ?
                    (root.down ? Appearance.colors.colSecondaryContainerActive : root.hovered ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colSecondaryContainer)
                    : ColorUtils.transparentize(Appearance.colors.colSecondaryContainer) :
                (root.down ? Appearance.colors.colLayer1Active : root.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1))

            states: State {
                name: "expanded"
                when: root.expanded
                AnchorChanges {
                    target: itemBackground
                    anchors.top: buttonContent.top
                    anchors.left: buttonContent.left
                    anchors.bottom: buttonContent.bottom
                }
                PropertyChanges {
                    target: itemBackground
                    implicitWidth: root.visualWidth
                }
            }
            transitions: Transition {
                enabled: root.__animReady
                AnchorAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
                PropertyAnimation {
                    target: itemBackground
                    property: "implicitWidth"
                    duration: Appearance.animation.elementMove.duration
                    easing.type: Appearance.animation.elementMove.type
                    easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                }
            }

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: itemBackground.width
                    height: itemBackground.height
                    radius: itemBackground.radius
                }
            }

            Item {
                id: ripple
                width: ripple.implicitWidth
                height: ripple.implicitHeight
                opacity: 0
                visible: width > 0 && height > 0

                property real implicitWidth: 0
                property real implicitHeight: 0

                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.rippleColor }
                        GradientStop { position: 0.3; color: root.rippleColor }
                        GradientStop { position: 0.5; color: Qt.rgba(root.rippleColor.r, root.rippleColor.g, root.rippleColor.b, 0) }
                    }
                }

                transform: Translate {
                    x: -ripple.width / 2
                    y: -ripple.height / 2
                }
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton
                grabPermissions: PointerHandler.TakeOverForbidden
                enabled: root.rippleEnabled
                onPressedChanged: {
                    if (pressed) {
                        root.startRipple(point.position.x, point.position.y);
                    } else {
                        rippleFadeAnim.restart();
                    }
                }
            }
        }

        Item {
            id: itemIconBackground
            implicitWidth: root.baseSize
            implicitHeight: root.baseHighlightHeight
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            MaterialSymbol {
                id: navRailButtonIcon
                rotation: root.buttonIconRotation
                anchors.centerIn: parent
                iconSize: 24
                fill: toggled ? 1 : 0
                font.weight: (toggled || root.hovered) ? Font.DemiBold : Font.Normal
                text: buttonIcon
                color: toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer1

                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        StyledText {
            id: itemText
            anchors {
                top: itemIconBackground.bottom
                topMargin: 2
                horizontalCenter: itemIconBackground.horizontalCenter
            }
            states: State {
                name: "expanded"
                when: root.expanded
                AnchorChanges {
                    target: itemText
                    anchors {
                        top: undefined
                        horizontalCenter: undefined
                        left: itemIconBackground.right
                        verticalCenter: itemIconBackground.verticalCenter
                    }
                }
            }
            transitions: Transition {
                enabled: root.__animReady
                AnchorAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }
            text: buttonText
            font.pixelSize: 14
            color: Appearance.colors.colOnLayer1
        }
    }

}
