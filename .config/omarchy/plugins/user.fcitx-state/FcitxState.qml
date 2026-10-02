import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "user.fcitx-state"

  property bool korean: false

  function refresh() {
    if (!checkProc.running) checkProc.running = true
  }

  function toggle() {
    if (!toggleProc.running) toggleProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: checkProc
    // "-n" keeps reporting keyboard-us on this setup; the state (1 inactive, 2 active)
    // tracks the Hangul toggle reliably because the group is [keyboard-us, hangul].
    command: ["/usr/bin/fcitx5-remote"]
    stdout: StdioCollector {
      onStreamFinished: function() {
        root.korean = this.text.trim() === "2"
      }
    }
  }

  Process {
    id: toggleProc
    command: ["/usr/bin/fcitx5-remote", "-t"]
    onExited: function(exitCode) {
      refreshTimer.restart()
    }
  }

  Timer {
    interval: 1500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: refreshTimer
    interval: 300
    repeat: false
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.korean ? "K" : "E"
    slotSize: Style.bar.statusSlot
    fontSize: Style.bar.iconFont
    tooltipText: root.korean ? "입력 언어: 한국어 (클릭하면 영어)" : "입력 언어: English (클릭하면 한국어)"
    keepSpace: true
    useActiveColor: false
    onPressed: root.toggle()
  }
}
