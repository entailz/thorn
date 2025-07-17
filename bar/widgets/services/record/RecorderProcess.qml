pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Hyprland
import qs

Singleton {
    id: recorder
    property bool recording: false
    property int timer: 0
    property string outputFile: ""
    property string videoDir: Globals.homeDir + "/Videos/Screencasting/qs"
    property string audioDevice: "alsa_output.usb-Corsair_CORSAIR_HS70_Pro_Wireless_Gaming_Headset-00.analog-stereo.monitor"
    property bool selectionInProgress: false
    property string currentArea: ""

    signal recordingStarted
    signal recordingStopped

    readonly property var focusedMonitor: Hyprland.focusedMonitor

    GlobalShortcut {
        appid: "bar"
        name: "record"
        description: "Start/Stop Screen Recording"
        onPressed: {
            const now = Date.now();
            if (now - RecorderProcess.lastShortcutTime < 500)
                return;
            RecorderProcess.lastShortcutTime = now;

            recorder.recording ? recorder.stopRecording() : recorder.startRecording();
        }
    }

    Timer {
        id: intervalTimer
        interval: 1000
        repeat: true
        running: recorder.recording
        onTriggered: {
            recorder.timer++;
        }
    }

    Slurp {
        id: slurp

        onSelectionMade: selection => {
            recorder.selectionInProgress = false;
            recorder.startRecordingWithArea(selection);
        }

        onSelectionCancelled: {
            recorder.selectionInProgress = false;
        }
    }

    function timestamp() {
        const now = new Date();
        const pad = n => n.toString().padStart(2, "0");
        return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}_${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
    }

    function startRecording() {
        if (recording || selectionInProgress)
            return;

        selectionInProgress = true;
        slurp.startSelection(focusedMonitor);
    }

    function startRecordingWithArea(area) {
        if (recording)
            return;

        currentArea = area;
        outputFile = `${recorder.videoDir}/${timestamp()}.mp4`;

        wfrecProcess.running = true;

        recorder.timer = 0;
        recorder.recording = true;
        intervalTimer.start();
        recorder.recordingStarted();
    }

    Process {
        id: stop
        command: ["sh", "-c", "pkill -INT wf-recorder"]
    }

    function stopRecording() {
        if (!recording)
            return;
        stop.running = true;
        waitTimer.start();
    }

    function finalizeRecording() {
        intervalTimer.stop();
        recording = false;
        notify.running = true;
        recordingStopped();
    }

    Timer {
        id: waitTimer
        interval: 10
        repeat: false
        onTriggered: {
            fileCheckProcess.running = true;
        }
    }

    Process {
        id: fileCheckProcess
        command: ["sh", "-c", `[ -f "${outputFile}" ] && [ $(stat -c%s "${outputFile}") -gt 100 ] && echo "OK"`]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "OK") {
                    recorder.finalizeRecording();
                }
            }
        }
    }

    Process {
        id: wfrecProcess
        command: ["sh", "-c", `wf-recorder -x yuv420p -c libx264 -r 30 --audio="${audioDevice}" -g "${currentArea}" -f "${outputFile}" && chmod 644 "${outputFile}"`]
        onExited: (exitCode, status) => {
            if (recording) {
                recording = false;
                intervalTimer.stop();
                waitTimer.start();
            }
        }
    }

    Process {
        id: notify
        command: ["notify-send", "-A", "files=Show in Files", "-A", "view=View", "-i", "video-x-generic-symbolic", "Screenrecord", `Saved to: ${outputFile}`]
        stdout: SplitParser {
            onRead: data => {
                const res = data.trim();
                if (res === "files") {
                    openFilesProcess.running = true;
                } else if (res === "view") {
                    checkBeforeViewProcess.running = true;
                }
            }
        }
    }

    Process {
        id: checkBeforeViewProcess
        command: ["sh", "-c", `[ -f "${outputFile}" ] && echo "exists"`]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "exists") {
                    openViewerProcess.running = true;
                } else {
                    errorNotifyProcess.running = true;
                }
            }
        }
    }

    Process {
        id: openFilesProcess
        command: ["thunar", videoDir]
    }
    Process {
        id: openViewerProcess
        command: ["mpv", outputFile]
    }
    Process {
        id: errorNotifyProcess
        command: ["notify-send", "-i", "error", "Error", "Video file not found"]
    }
}
