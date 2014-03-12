import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string station
    property bool refreshing: false
    property var resultList: ListModel {}

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            resultList.clear()
            refresh()
        }
    }

    SilicaListView {
        id: departureList
        anchors.fill: parent

        PullDownMenu {
            busy: refreshing

            MenuItem {
                text: "Add to favourites" //FIXME already fav?/save fav?
            }

            MenuItem {
                text: refreshing ? "Refreshing..." : "Refresh"
                enabled: !refreshing
                onClicked: refresh()
            }
        }

        header: Column {
            width: parent.width

            PageHeader {
                title: "Result"
            }

            Item {
                width: parent.width
                height: Theme.itemSizeMedium

                Label {
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }

                    text: station
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge 
                }
            
                BusyIndicator {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Theme.paddingLarge
                    }
                    running: refreshing 
                }
            }
        }

        ViewPlaceholder {
            enabled: departureList.count == 0 && !refreshing
            text: "No departures found"
        }
            
        model: resultList

        delegate: ListItem {
            width: parent.width
            height: Theme.itemSizeMedium

            Row {
                anchors.fill: parent
                anchors.margins: Theme.paddingLarge

                Label {
                    width: parent.width * 0.25 - image.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.line.name
                }

                Image {
                    id: image
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.line.barrierFree ? Qt.resolvedUrl('wheelchair.png') : ''
                }

                Label {
                    width: parent.width * 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.line.towards
                }

                Label {
                    width: parent.width * 0.25
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: modelData.countdown
                }
            }
        }
    }

    function refresh() {
        if(!refreshing) {
            refreshing = true
            py.call('glue.gui_departures.deps.get', 
                [station], function(result) {
                    resultList = result;
                    refreshing = false
            });
        }
    }
}
