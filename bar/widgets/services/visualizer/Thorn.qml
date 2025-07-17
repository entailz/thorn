import QtQuick
import Quickshell
import Quickshell.Io
import qs

Item {
    id: root

    property real time: 0
    property real innerRadius: 20
    property real cavaHeight
    property real cavaWidth
    property real maxBarLength: 200
    property real rotationSpeed: 1
    property bool showCenter: false
    property string visualizerMode: "wave" // "bars" or "wave"
    implicitHeight: cavaHeight
    implicitWidth: cavaWidth

    property int count: 102
    Scope {
        id: cava
        property int noiseReduction: 20
        property string channels: "mono"
        property string monoOption: "average"
        property var config: ({
                general: {
                    bars: root.count
                },
                smoothing: {
                    noise_reduction: noiseReduction
                },
                output: {
                    method: "raw",
                    bit_format: 8,
                    channels: channels,
                    mono_option: monoOption
                }
            })
        property var values: Array(root.count).fill(0)
        property var smoothedValues: Array(root.count).fill(0)

        onConfigChanged: {
            process.running = false;
            process.running = true;
        }

        Process {
            id: process
            property int index: 0
            stdinEnabled: true
            command: ["cava", "-p", "/dev/stdin"]

            onExited: {
                stdinEnabled = true;
                index = 0;
            }

            onStarted: {
                for (const k in cava.config) {
                    if (typeof cava.config[k] !== "object") {
                        write(k + "=" + cava.config[k] + "\n");
                        continue;
                    }
                    write("[" + k + "]\n");
                    const obj = cava.config[k];
                    for (const k2 in obj) {
                        write(k2 + "=" + obj[k2] + "\n");
                    }
                }
                stdinEnabled = false;
            }

            stdout: SplitParser {
                splitMarker: ""
                onRead: data => {
                    const tempValues = [...cava.values];
                    if (process.index + data.length > cava.config.general.bars) {
                        process.index = 0;
                    }
                    for (let i = 0; i < data.length; i += 1) {
                        const index = i + process.index;
                        if (index < tempValues.length) {
                            const newVal = Math.min(data.charCodeAt(i), 128) / 128;
                            tempValues[index] = tempValues[index] * 0.2 + newVal * 0.8;
                        }
                    }
                    process.index += data.length;
                    cava.values = tempValues;
                }
            }
        }
    }

    Item {
        id: viz
        implicitWidth: root.cavaWidth
        implicitHeight: root.cavaHeight

        Canvas {
            id: visualizerCanvas
            anchors.fill: parent
            property var barValues: Array(root.count).fill(0)
            property var precomputedColors: []

            Component.onCompleted: {
                precomputeColors();
                requestPaint();
            }

            function precomputeColors() {
                precomputedColors = [];
                const barCount = root.count;
                for (let i = 0; i < barCount; i++) {
                    const baseHue = (i / barCount) * 280;
                    const hue = (baseHue + 200) % 360;
                    precomputedColors.push({
                        base: `hsl(${hue}, 85%, 60%)`,
                        bright: `hsl(${(hue + 20) % 360}, 90%, 70%)`,
                        glow: `hsl(${hue}, 100%, 70%)`
                    });
                }
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const centerX = width / 2;
                const centerY = height / 2;
                const barCount = root.count;

                for (let i = 0; i < barCount; i++) {
                    const target = cava.values[i] || 0;
                    barValues[i] = barValues[i] * 0.8 + target * 0.2;
                }

                if (root.visualizerMode === "bars") {
                    drawCircularBars(ctx, centerX, centerY, barCount);
                } else {
                    drawCircularWave(ctx, centerX, centerY, barCount);
                }

                if (root.showCenter) {
                    drawCenterCircle(ctx, centerX, centerY);
                }
            }

            function drawCircularBars(ctx, centerX, centerY, barCount) {
                const angleStep = (Math.PI * 2) / barCount;
                const baseLineWidth = Math.max(1, (1 * Math.PI * root.innerRadius) / barCount * 1);

                ctx.lineCap = "round";

                for (let i = 0; i < barCount; i++) {
                    const angle = (i * angleStep) + (root.time * root.rotationSpeed * Math.PI / 180);
                    const barHeight = barValues[i] * root.maxBarLength;

                    if (barHeight < 1)
                        continue;

                    const innerX = centerX + Math.cos(angle) * root.innerRadius;
                    const innerY = centerY + Math.sin(angle) * root.innerRadius;
                    const outerX = centerX + Math.cos(angle) * (root.innerRadius + barHeight);
                    const outerY = centerY + Math.sin(angle) * (root.innerRadius + barHeight);

                    const intensity = barValues[i];
                    const colors = precomputedColors[i];

                    ctx.strokeStyle = intensity > 0.8 ? colors.bright : colors.base;
                    ctx.lineWidth = baseLineWidth + intensity * 1;

                    ctx.beginPath();
                    ctx.moveTo(innerX, innerY);
                    ctx.lineTo(outerX, outerY);
                    ctx.stroke();
                }
            }

            function drawCircularWave(ctx, centerX, centerY, barCount) {
                const angleStep = (Math.PI * 2) / barCount;
                const waveRadius = root.innerRadius + root.maxBarLength / 10;

                ctx.beginPath();
                let firstPoint = true;

                for (let i = 0; i <= barCount; i++) {
                    const dataIndex = i % barCount;
                    const angle = (i * angleStep) + (root.time * root.rotationSpeed * Math.PI / 360);
                    const amplitude = barValues[dataIndex] * root.maxBarLength * 0.5;
                    const radius = waveRadius + amplitude;

                    const x = centerX + Math.cos(angle) * radius;
                    const y = centerY + Math.sin(angle) * radius;

                    if (firstPoint) {
                        ctx.moveTo(x, y);
                        firstPoint = false;
                    } else {
                        ctx.lineTo(x, y);
                    }
                }

                ctx.closePath();

                const fillGradient = ctx.createRadialGradient(centerX, centerY, root.innerRadius, centerX, centerY, waveRadius + root.maxBarLength);

                fillGradient.addColorStop(0, "#" + Globals.colors.colors.color6);
                fillGradient.addColorStop(0.3, "#" + Globals.colors.colors.color1);
                fillGradient.addColorStop(1, "#" + Globals.colors.colors.color11);

                // fillGradient.addColorStop(0, "hsla(100, 0%, 100%, 1)");
                // // fillGradient.addColorStop(0.3, "hsla(320, 70%, 50%, 0.3)");
                // // fillGradient.addColorStop(0.7, "hsla(200, 80%, 60%, 0.4)");
                // // fillGradient.addColorStop(1, "hsla(240, 90%, 70%, 0.2)");

                ctx.fillStyle = fillGradient;
                ctx.fill();

                const strokeGradient = ctx.createRadialGradient(centerX, centerY, root.innerRadius, centerX, centerY, waveRadius + root.maxBarLength);
                strokeGradient.addColorStop(0.4, "#dd" + Globals.colors.colors.color4);

                ctx.strokeStyle = strokeGradient;
                ctx.lineWidth = 0;
                ctx.stroke();
            }

            function drawCenterCircle(ctx, centerX, centerY) {
                const avgLevel = barValues.reduce((sum, val) => sum + val, 0) / barValues.length;
                const pulseRadius = root.innerRadius * 0.6 + avgLevel * 20;

                const centerGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, pulseRadius);
                centerGradient.addColorStop(0, "hsla(60, 100%, 80%, 0.9)");
                centerGradient.addColorStop(0.4, "hsla(300, 80%, 60%, 0.6)");
                centerGradient.addColorStop(0.8, "hsla(200, 90%, 50%, 0.3)");
                centerGradient.addColorStop(1, "hsla(240, 100%, 40%, 0.1)");

                ctx.beginPath();
                ctx.arc(centerX, centerY, pulseRadius, 0, Math.PI * 2);
                ctx.fillStyle = centerGradient;
                ctx.fill();
            }
        }

        Timer {
            interval: 30
            running: true
            repeat: true
            onTriggered: {
                root.time += 2;
                visualizerCanvas.requestPaint();
            }
        }
    }
}
