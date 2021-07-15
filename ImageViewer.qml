import QtQuick.Controls 1.1
import QtQuick 2.9
import QtQuick.Window 2.2

Item{
    id: root
    clip: true
    property alias source: mapImg.source
    property alias scale: mapImg.scale
    property int imageRotation: 0
    Image {
        id: mapImg

        x: 0 - (mapImg.width - (mapImg.width * mapImg.scale)) / 2
        y: 0 - (mapImg.height - (mapImg.height * mapImg.scale)) / 2
        sourceSize.height: root.height
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        rotation: root.imageRotation
    }
    MouseArea {
        id: imageDragField
        anchors.fill: root

        drag.target: mapImg

        property real xOffsset:  0 - (mapImg.width - (mapImg.width * mapImg.scale)) / 2
        property real yOffset: 0 - (mapImg.height - (mapImg.height * mapImg.scale)) / 2


        drag.minimumX: {
            if(mapImg.width * mapImg.scale > root.width){
                return (root.width - mapImg.width*mapImg.scale ) + xOffsset
            } else {
                return xOffsset
            }
        }
        drag.maximumX: {
            if(mapImg.width * mapImg.scale > root.width){
                return xOffsset
            } else {
                return (root.width - (mapImg.width * mapImg.scale)) + drag.minimumX
            }
        }

        drag.minimumY: {
            if(mapImg.height*mapImg.scale > root.height){
                return (root.height - mapImg.height*mapImg.scale) + yOffset
            } else {
                return yOffset
            }

        }
        drag.maximumY: {
            if(mapImg.height*mapImg.scale > root.height){
                return yOffset
            }else {
                return  (root.height - mapImg.height*mapImg.scale) + drag.minimumY
            }
        }

        onWheel: {
            var delta = wheel.angleDelta.y/120;
            if(delta > 0)
            {
                mapImg.scale = mapImg.scale/0.9
            }
            else
            {
                mapImg.scale = mapImg.scale*0.9
            }
        }
    }
}
