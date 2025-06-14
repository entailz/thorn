import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Controls
import "components/pomodoro" as Pom
import "components" as Components
import "root:/"

Components.BarWidget {
    id: roots
    implicitHeight: 32
    implicitWidth: 24
    color: "transparent"

    property color backgroundColor: Globals.backgroundColor
    property int pomodoroWorkMinutes: 25
    property int pomodoroBreakMinutes: 5
    property int pomodoroLongBreakMinutes: 15
    property int pomodoroSessions: 0
    property bool pomodoroIsWorking: true
    property bool pomodoroRunning: false
    property int pomodoroTimeLeft: pomodoroWorkMinutes * 60
    property string soundPath: Globals.homeDir + "/.config/quickshell/thorn/sound/pleasant.mp3"
    property bool alarmRunning: false
    property date alarmTime: new Date()
    property int alarmTimeLeft: 0

    Process {
        id: playSound
        running: false
        command: ["play", `${roots.soundPath}`]
    }

    Timer {
        id: pomodoroTimer
        interval: 1000
        running: roots.pomodoroRunning
        repeat: true
        onTriggered: {
            if (roots.pomodoroTimeLeft > 0) {
                roots.pomodoroTimeLeft--;
            } else {
                playSound.running = true;

                if (roots.pomodoroIsWorking) {
                    roots.pomodoroSessions++;
                    roots.pomodoroRunning = false;

                    if (roots.pomodoroSessions % 4 === 0) {
                        roots.pomodoroIsWorking = false;
                        pomodoroTimeLeft = pomodoroLongBreakMinutes * 60;
                    } else {
                        roots.pomodoroIsWorking = false;
                        pomodoroTimeLeft = pomodoroBreakMinutes * 60;
                    }

                    autoStartTimer.start();
                } else {
                    roots.pomodoroRunning = false;
                    roots.pomodoroIsWorking = true;
                    pomodoroTimeLeft = pomodoroWorkMinutes * 60;

                    autoStartTimer.start();
                }
            }
        }
    }

    Timer {
        id: autoStartTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            roots.pomodoroRunning = true;
        }
    }

    Timer {
        id: alarmTimer
        interval: 1000
        running: roots.alarmRunning
        repeat: true
        onTriggered: {
            const now = new Date();
            const target = new Date(roots.alarmTime);
            const diff = Math.floor((target.getTime() - now.getTime()) / 1000);

            if (diff <= 0) {
                roots.alarmRunning = false;
                playSound.running = true;
                roots.alarmTimeLeft = 0;
            } else {
                roots.alarmTimeLeft = diff;
            }
        }
    }

    function formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0');
    }

    function formatAlarmTime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        return hours.toString().padStart(2, '0') + ":" + mins.toString().padStart(2, '0') + ":" + secs.toString().padStart(2, '0');
    }

    function formatTime12Hour(hours, minutes) {
        const period = hours >= 12 ? "PM" : "AM";
        const displayHours = hours === 0 ? 12 : (hours > 12 ? hours - 12 : hours);
        return displayHours + ":" + minutes.toString().padStart(2, '0') + " " + period;
    }

    Components.IconButton {
        id: timerIcon
        anchors.centerIn: parent
        icon: roots.pomodoroRunning ? "pause" : (roots.alarmRunning ? "notification_important" : "timelapse")
        clickable: true
        outerSize: 20
        useVariableFill: true
        iconColor: roots.pomodoroRunning ? "#ff6b6b" : (roots.alarmRunning ? "#" + Globals.colors.colors.color1 : "#" + Globals.colors.colors.color6)
        onClicked: {
            const window = roots.QsWindow.window;
            const itemRect = window.contentItem.mapFromItem(roots, 0, roots.height);
            timerPopup.anchor.rect.x = itemRect.x - (timerPopup.width / 2) + (roots.width / 2);
            timerPopup.anchor.rect.y = itemRect.y;
            timerPopup.show();
            grab.active = true;
        }

        Components.BarTooltip {
            relativeItem: timerIcon.containsMouse ? timerIcon : null
            offset: 2

            Label {
                font.hintingPreference: Font.PreferFullHinting
                font.family: Globals.secondaryFont
                font.pixelSize: 11
                color: "white"
                text: roots.pomodoroRunning ? "Pomodoro timer is running" : "Pomodoro Timer"
            }
        }
    }
    Components.SlidingPopup {
        id: timerPopup
        anchor.window: roots.QsWindow.window
        anchor.margins.top: -7
        implicitWidth: 400
        implicitHeight: roots.pomodoroIsWorking ? 435 : 435 + 30

        ClippingRectangle {
            anchors.fill: parent
            color: roots.backgroundColor
            radius: 16
            layer.smooth: true
            layer.samples: 8
            layer.enabled: true
            contentInsideBorder: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: !roots.pomodoroIsWorking ? 410 : 380
                    color: "transparent"
                    radius: 12

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16

                        Canvas {
                            id: progressDial
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 140
                            implicitHeight: 140

                            property real workProgress: {
                                if (roots.pomodoroIsWorking) {
                                    const totalTime = roots.pomodoroWorkMinutes * 60;
                                    return totalTime > 0 ? (1 - (roots.pomodoroTimeLeft / totalTime)) : 0;
                                }
                                return 1;
                            }

                            property real breakProgress: {
                                if (!roots.pomodoroIsWorking) {
                                    const totalTime = roots.pomodoroSessions % 4 === 0 && roots.pomodoroSessions > 0 ? roots.pomodoroLongBreakMinutes * 60 : roots.pomodoroBreakMinutes * 60;
                                    return totalTime > 0 ? (1 - (roots.pomodoroTimeLeft / totalTime)) : 0;
                                }
                                return 0;
                            }

                            Behavior on workProgress {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on breakProgress {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.OutCubic
                                }
                            }

                            onWorkProgressChanged: requestPaint()
                            onBreakProgressChanged: requestPaint()
                            Component.onCompleted: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                var centerX = width / 2;
                                var centerY = height / 2;
                                var radius = 55;
                                var lineWidth = 6;

                                if (workProgress > 0) {
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                                    ctx.strokeStyle = "#33" + Globals.colors.colors.color8;
                                    ctx.lineWidth = 2;
                                    ctx.stroke();
                                }

                                if (workProgress > 0 && breakProgress === 0) {
                                    ctx.beginPath();
                                    var startAngle = -Math.PI / 2;
                                    var endAngle = startAngle + (workProgress * 2 * Math.PI);
                                    ctx.arc(centerX, centerY, radius, startAngle, endAngle);

                                    var gradient = ctx.createRadialGradient(centerX, centerY, radius * 0.7, centerX, centerY, radius);
                                    gradient.addColorStop(1, "#" + Globals.colors.colors.color11);
                                    gradient.addColorStop(0, "#f8c291");

                                    ctx.strokeStyle = gradient;
                                    ctx.lineWidth = lineWidth;
                                    ctx.lineCap = "round";
                                    ctx.stroke();
                                }

                                if (breakProgress > 0) {
                                    ctx.beginPath();
                                    var breakStartAngle = -Math.PI / 2;
                                    var breakEndAngle = breakStartAngle - (breakProgress * 2 * Math.PI);
                                    ctx.arc(centerX, centerY, radius, breakStartAngle, breakEndAngle, true);
                                    ctx.strokeStyle = "#88" + Globals.colors.colors.color6;
                                    ctx.lineWidth = lineWidth;
                                    ctx.lineCap = "round";
                                    ctx.stroke();
                                }

                                var buttonRadius = 45;
                                var gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, buttonRadius);

                                if (centerButton.containsMouse) {
                                    var hoverColor = roots.pomodoroIsWorking ? Globals.colors.colors.color11 : Globals.colors.colors.color5;
                                    gradient.addColorStop(0, "#22" + hoverColor);
                                    gradient.addColorStop(0.2, "#33" + hoverColor);
                                    gradient.addColorStop(0.4, "#44" + hoverColor);
                                    gradient.addColorStop(0.7, "#55" + hoverColor);
                                    gradient.addColorStop(1, "#88" + "transparent");
                                } else {
                                    var baseColor = Globals.colors.colors.color6;
                                    gradient.addColorStop(0, "#28" + baseColor);
                                    gradient.addColorStop(0.4, "#20" + baseColor);
                                    gradient.addColorStop(0.8, "#18" + baseColor);
                                    gradient.addColorStop(1, "transparent");
                                }

                                ctx.beginPath();
                                ctx.arc(centerX, centerY, buttonRadius, 0, 2 * Math.PI);
                                ctx.fillStyle = gradient;
                                ctx.fill();

                                if (!roots.pomodoroIsWorking && breakProgress > 0) {
                                    ctx.lineWidth = 1;
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY - radius - 12, 3, 0, 2 * Math.PI);
                                    ctx.fillStyle = "#" + Globals.colors.colors.color11;
                                    ctx.fill();

                                    ctx.beginPath();
                                    ctx.moveTo(centerX - 8, centerY - radius - 12);
                                    ctx.lineTo(centerX - 2, centerY - radius - 15);
                                    ctx.lineTo(centerX - 2, centerY - radius - 9);
                                    ctx.closePath();
                                    ctx.fillStyle = "#" + Globals.colors.colors.color11;
                                    ctx.fill();
                                }
                            }

                            Item {
                                id: pomodoroContainer
                                anchors.fill: parent
                                property bool pomodoroRunning: false
                                property bool hovered: false

                                states: [
                                    State {
                                        name: "running"
                                        when: roots.pomodoroRunning && !pomodoroContainer.hovered
                                        PropertyChanges {
                                            target: timeLeft
                                            opacity: 1
                                        }
                                        PropertyChanges {
                                            target: focusText
                                            opacity: 1
                                        }
                                        PropertyChanges {
                                            target: playPauseIcon
                                            opacity: 0
                                        }
                                    },
                                    State {
                                        name: "hovering"
                                        when: roots.pomodoroRunning && pomodoroContainer.hovered
                                        PropertyChanges {
                                            target: timeLeft
                                            opacity: 0
                                        }
                                        PropertyChanges {
                                            target: focusText
                                            opacity: 0
                                        }
                                        PropertyChanges {
                                            target: playPauseIcon
                                            opacity: 1
                                        }
                                    },
                                    State {
                                        name: "idle"
                                        when: !roots.pomodoroRunning
                                        PropertyChanges {
                                            target: timeLeft
                                            opacity: 0
                                        }
                                        PropertyChanges {
                                            target: focusText
                                            opacity: 0
                                        }
                                        PropertyChanges {
                                            target: playPauseIcon
                                            opacity: 1
                                        }
                                    }
                                ]

                                transitions: [
                                    Transition {
                                        NumberAnimation {
                                            properties: "opacity"
                                            duration: 800
                                        }
                                    }
                                ]

                                MouseArea {
                                    id: centerButton
                                    anchors.centerIn: parent
                                    width: 70
                                    height: 70
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: pomodoroRunning = !pomodoroRunning
                                    onEntered: pomodoroContainer.hovered = true
                                    onExited: pomodoroContainer.hovered = false

                                    Components.ColorIcon {
                                        id: playPauseIcon
                                        anchors.centerIn: parent
                                        source: pomodoroRunning ? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
                                        implicitSize: 24
                                        opacity: 1
                                        hovered: centerButton.containsMouse
                                    }
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: -2

                                    Text {
                                        id: timeLeft
                                        Layout.alignment: Qt.AlignHCenter
                                        font.pixelSize: 40
                                        text: formatTime(roots.pomodoroTimeLeft)
                                        opacity: (roots.pomodoroRunning && !hovered) ? 1 : 0
                                        color: "#" + Globals.colors.colors.color6
                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 400
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }

                                    Text {
                                        id: focusText
                                        text: roots.pomodoroIsWorking ? "focus" : "break"
                                        font.pixelSize: 14
                                        font.letterSpacing: 2
                                        font.family: Globals.font
                                        color: "#A0A0A0"
                                        opacity: 0
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }

                        RowLayout {

                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 60
                            implicitHeight: 37
                            Components.IconButton {
                                useVariableFill: true
                                icon: "table_lamp"
                                size: 28
                            }
                            Text {
                                verticalAlignment: Text.AlignVCenter
                                Layout.preferredWidth: 10
                                text: roots.pomodoroSessions
                                color: "#" + Globals.colors.colors.color2
                                font.pixelSize: 25
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.margins: 8
                            spacing: 16

                            Pom.CustomSlider {
                                id: workSlider
                                Layout.fillWidth: true
                                label: "Work Duration "
                                from: 1
                                to: 60
                                value: roots.pomodoroWorkMinutes
                                suffix: "m"
                                enabled: !roots.pomodoroRunning
                                accentColor: "#ff6b6b"
                                onValueChanged: {
                                    pomodoroWorkMinutes = value;
                                    if (roots.pomodoroIsWorking && !roots.pomodoroRunning) {
                                        pomodoroTimeLeft = value * 60;
                                    }
                                }
                            }

                            Pom.CustomSlider {
                                id: breakSlider
                                Layout.fillWidth: true
                                label: "Break Duration "
                                from: 1
                                to: 30
                                value: roots.pomodoroBreakMinutes
                                suffix: "m"
                                enabled: !roots.pomodoroRunning
                                accentColor: "#4ecdc4"
                                onValueChanged: {
                                    pomodoroBreakMinutes = value;
                                    if (!roots.pomodoroIsWorking && !roots.pomodoroRunning && roots.pomodoroSessions % 4 !== 0) {
                                        pomodoroTimeLeft = value * 60;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [timerPopup]
        onCleared: {
            timerPopup.closeWithAnimation();
        }
    }
}
