import QtGraphicalEffects 1.0
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls 2.12 as QQS

import "."

Item {
    id: root;

    readonly property int itemDiameter: clockBox.height * 0.17
    readonly property int angleBetweenItems: isMinutesClock ? 360 / 60 : 360 / 12
    readonly property int roundAngle: root.isMinutesClock ? 6 : 30
    readonly property int currentItem: Math.round(clockBox.angle / roundAngle) >= mouseArea.items ? 0 :  Math.round(clockBox.angle / roundAngle)

    property int index: 0

    onIndexChanged: {
        clockBox.angle = index * angleBetweenItems;
    }



    property bool isMinutesClock: false;

    property int borderWidth: 1
    property var borderColor: Style.semiTransparent

    property var hourList: [] /*have to look like 
    [
        {text: "12", value: 12},
        {text: "13", value: 13},
        {text: "14", value: 14},
        {text: "15", value: 15},
        {text: "16", value: 16},
        {text: "17", value: 17},
        {text: "18", value: 18},
        {text: "19", value: 19},
        {text: "20", value: 20},
        {text: "21", value: 21},
        {text: "22", value: 22},
        {text: "23", value: 23}
    ]
    */

    property bool isInactive: false

    signal active()

    signal timeChanged(var index)



    Rectangle {
        id: clockBox
        anchors.centerIn: root

        property int textSize: 10;
        property real angle: root.index * root.angleBetweenItems;

        height: root.height > root.width ? root.width : root.height
        width: height
        color: Style.transparent


        Repeater {
            id: itemsRepeater
            anchors.fill: clockBox


            model: hourList.length
            Rectangle {
                id: clockItemRope; //transparent rectangle with no width allowing us center arrow properly on every angle
                anchors.top: itemsRepeater.verticalCenter

                anchors.horizontalCenter: clockBox.horizontalCenter
                height: clockBox.height / 2
                width: 0
                color: Style.transparent

                CustomToolButton {
                    id: clockItem
                    anchors.bottom: clockItemRope.bottom
                    anchors.horizontalCenter: clockItemRope.horizontalCenter
                    width: itemDiameter
                    height: itemDiameter
                    radius: width * 0.5
                    text: hourList[index].text
                    color: Style.white
                    textColor: Style.black
                    borderWidth: root.borderWidth
                    borderColor: root.borderColor
                    visible: index*root.angleBetweenItems % 5 === 0

                    onClicked: {
                        timeChanged(index)
                        clockBox.angle = index * root.angleBetweenItems
                        active();
                    }

                    transform: Rotation { // rotate text so it always will be horisontally aligned
                        origin.x: clockItem.width / 2
                        origin.y: clockItem.height / 2
                        angle: -1 * root.angleBetweenItems * index + 180
                    }
                }

                CustomToolButton {
                    id: minuteDot
                    anchors.bottom: clockItemRope.bottom
                    anchors.horizontalCenter: clockItemRope.horizontalCenter
                    width: itemDiameter * 0.2
                    height: width
                    radius: width * 0.5


                    color: Style.semiTransparent
                    visible: !clockItem.visible

                    onClicked: {
                        timeChanged(index)
                        clockBox.angle = index * root.angleBetweenItems
                    }
                }

                transform: Rotation {
                    angle: root.angleBetweenItems * index + 180
                }
            }
        }


        Item {
            id: dragContainer;
            width: clockBox.width;
            height: width;
            anchors.centerIn: parent;

            property real centerX : (width / 2);
            property real centerY : (height / 2);

            z: 1000

            Rectangle{
                id: rotateItem;
                color: Style.transparent;
                transformOrigin: Item.Center;
                radius: (width / 2);
                antialiasing: true;
                anchors.fill: parent;
                rotation: clockBox.angle

                Rectangle {
                    id: handle;

                    property bool moving: false;
                    color: moving ? Style.semiTransparent :
                                    root.isMinutesClock ? Style.semiTransparent :
                                    root.isInactive ? Style.transparent : Style.blue
                    width: root.itemDiameter;
                    border.width: 1;
                    border.color: root.isInactive ? Style.transparent : Style.semiTransparent
                    height: width;
                    radius: (width / 2);
                    antialiasing: true;
                    anchors {
                        top: parent.top;
                        horizontalCenter: parent.horizontalCenter;
                    }

                    QQS.Label {
                        anchors.fill: parent
                        text: root.isMinutesClock ? "" : hourList[root.currentItem].text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: root.isInactive ? Style.transparent : Style.white

                        rotation: clockBox.angle * -1
                        fontSizeMode: Text.HorizontalFit
                    }


                    MouseArea{
                        id: mouseArea
                        anchors.fill: parent;

                        property int items: root.isMinutesClock ? 60 : 12; //count of items we can select
                        property double angle: 0

                        function roundToNearest(deg){
                            var degreeRange = 360 / mouseArea.items;
                            var currentRange = degreeRange;
                            while(currentRange <= 360){
                                if(deg < currentRange){
                                    deg = deg < currentRange - (degreeRange/2) ? currentRange - degreeRange : currentRange
                                    return deg === 360 ? 0 : deg
                                }
                                currentRange += degreeRange
                            }
                            return 0;
                        }
                        onPressed: {
                            active();
                            handle.moving = true;
                        }

                        onPositionChanged:  {
                            var point =  mapToItem (dragContainer, mouse.x, mouse.y);
                            var diffX = (point.x - dragContainer.centerX);
                            var diffY = -1 * (point.y - dragContainer.centerY);
                            var rad = Math.atan (diffY / diffX);
                            var deg = (rad * 180 / Math.PI);
                            if (diffX > 0 && diffY > 0) {
                                angle = 90 - Math.abs (deg);
                            }
                            else if (diffX > 0 && diffY < 0) {
                                angle = 90 + Math.abs (deg);
                            }
                            else if (diffX < 0 && diffY > 0) {
                                angle = 270 + Math.abs (deg);
                            }
                            else if (diffX < 0 && diffY < 0) {
                                angle = 270 - Math.abs (deg);
                            }
                            clockBox.angle = angle;
                            root.timeChanged(root.currentItem)
                        }

                        onReleased: {
                            clockBox.angle = roundToNearest(angle);
                            root.timeChanged(root.currentItem)
                            handle.moving = false;
                        }
                    }
                }
            }
        }




        Rectangle {
            id: arrowBegin
            anchors.centerIn: clockBox
            height: itemDiameter * 0.3
            width: height
            radius: width * 0.5
            color: Style.blue
        }

        Rectangle {
            id: arrowRope //need transparent item for properly centering on every possible degree
            anchors.top: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            height: (parent.width / 2) - (root.itemDiameter)
            width: 0
            color: Style.transparent

            Rectangle {
                id: arrow
                antialiasing: true
                anchors.bottom: arrowRope.bottom
                anchors.top: arrowRope.top
                anchors.horizontalCenter: arrowRope.horizontalCenter
                width: 2
                color: root.isInactive ? Style.transparent : Style.blue
            }

            transform: Rotation {
                angle: clockBox.angle + 180
            }
        }
    }
}

