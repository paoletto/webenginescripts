import QtQuick 2.15
import QtQuick.Window 2.15
import QtWebEngine 1.11
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebChannel 1.15

Window {
    id: root
    width: 960
    height: 960
    visible: true
    title: qsTr("webengineexample")

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: {
            Qt.quit()
        }
    }

    property string httpAcceptLanguage: "en-US"

    QtObject{
        id: internals

        property string script_videoTime: "
            setTimeout(function()
            {
                var backend;
                new QWebChannel(qt.webChannelTransport, function (channel) {
                    backend = channel.objects.backend;
                });

                ytplayer = document.getElementById('movie_player');
                backend.videoPosition = ytplayer.getCurrentTime();
                backend.videoDuration = ytplayer.getDuration();
            }, 100);
        "
    }

    QtObject {
        id: timePuller

        // ID, under which this object will be known at WebEngineView side
        WebChannel.id: "backend"

        property real videoPosition: 0
        property real videoDuration: 0

        onVideoDurationChanged: {
            console.log("VideoDuration ", videoDuration)
            console.log("VideoPosition ", videoPosition)
        }
    }

    WebChannel {
        id : web_channel
        registeredObjects: [timePuller]
    }

    WebEngineView {
        id: webEngineView
        anchors.fill: parent

        webChannel: web_channel
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentReady
                name: "QWebChannel"
                sourceUrl: "qrc:/qtwebchannel/qwebchannel.js"
            }
        ]
//        userScripts: [
//            {
//                name: "QWebChannel",
//                sourceUrl: Qt.resolvedUrl("qrc:/qtwebchannel/qwebchannel.js"),
//                injectionPoint: WebEngineScript.DocumentCreation,
//                worldId: WebEngineScript.MainWorld
//            }
//        ]

        // The following works
        profile {
            httpAcceptLanguage: root.httpAcceptLanguage
            httpCacheType: WebEngineProfile.MemoryHttpCache
            cachePath: "/tmp/webengineexample/customprofile/cache"
            persistentStoragePath: "/tmp/webengineexample/customprofile/data"
            persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
            storageName: "customprofile"
        }

        settings {
            autoLoadImages: true
            dnsPrefetchEnabled: false
        }
        url: "https://youtube.com"
//        url: "https://ping.eu"
    }

    Button {
        id: timeDriver
        anchors {
            top: parent.top
            left: parent.left
        }
        text: "getTime"
        onClicked: {
                webEngineView.runJavaScript(internals.script_videoTime)
        }
    }
}
