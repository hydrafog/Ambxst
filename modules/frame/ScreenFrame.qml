import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.services
import qs.config
import qs.modules.bar.workspaces

import qs.modules.globals
Item {
    id: root

    required property ShellScreen targetScreen

    readonly property alias frameEnabled: frameContent.frameEnabled
    readonly property alias baseThickness: frameContent.thickness
    readonly property bool hasFullscreenWindow: {
        const monitor = AxctlService.monitorFor(targetScreen);
        if (!monitor)
            return false;

        const activeWorkspaceId = monitor.activeWorkspace.id;
        const monId = monitor.id;

        // Check active toplevel first (fast path)
        const toplevel = ToplevelManager.activeToplevel;
        if (toplevel && toplevel.fullscreen && AxctlService.focusedMonitor.id === monId) {
            return true;
        }

        // Check all windows on this monitor (robust path)
        const wins = CompositorData.windowList;
        for (let i = 0; i < wins.length; i++) {
            if (wins[i].monitor === monId && wins[i].fullscreen && wins[i].workspace.id === activeWorkspaceId) {
                return true;
            }
        }
        return false;
    }
    readonly property alias actualFrameSize: frameContent.actualFrameSize
    readonly property int thickness: hasFullscreenWindow ? 0 : baseThickness

    readonly property alias innerRadius: frameContent.innerRadius
    readonly property bool containBar: Config.bar?.containBar ?? false

    readonly property bool sidebarActive: GlobalStates.assistantVisible && targetScreen.name === GlobalStates.assistantScreenName
    readonly property bool sidebarPinned: GlobalStates.assistantPinned
    readonly property int sidebarWidth: GlobalStates.assistantWidth
    readonly property string sidebarPosition: GlobalStates.assistantPosition

    readonly property int sidebarMargin: 4
    readonly property int sidebarExpansion: sidebarPinned ? (sidebarWidth + thickness) : 0

    readonly property string barPos: Config.bar?.position ?? "top"
    // Bar height is 44. Total size = Thickness (Outer) + Bar (44) + Thickness (Inner)
    readonly property int barExpansion: 44 + thickness
    readonly property int topThickness: hasFullscreenWindow ? 0 : (thickness + ((containBar && barPos === "top") ? barExpansion : 0))
    readonly property int bottomThickness: hasFullscreenWindow ? 0 : (thickness + ((containBar && barPos === "bottom") ? barExpansion : 0))
    readonly property int leftThickness: hasFullscreenWindow ? 0 : (thickness + ((containBar && barPos === "left") ? barExpansion : 0) + ((sidebarPosition === "left") ? sidebarExpansion : 0))
    readonly property int rightThickness: hasFullscreenWindow ? 0 : (thickness + ((containBar && barPos === "right") ? barExpansion : 0) + ((sidebarPosition === "right") ? sidebarExpansion : 0))

    Item {
        id: noInputRegion
        anchors.fill: parent
    }

    PanelWindow {
        id: topFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitHeight: root.topThickness
        height: root.topThickness
        color: "transparent"
        anchors {
            left: true
            right: true
            top: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "ambxst:screenFrame:top"

        // Space reservation is handled by ReservationWindows.qml
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: bottomFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitHeight: root.bottomThickness
        height: root.bottomThickness
        color: "transparent"
        anchors {
            left: true
            right: true
            bottom: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "ambxst:screenFrame:bottom"

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: leftFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitWidth: root.leftThickness
        width: root.leftThickness
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "ambxst:screenFrame:left"

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: rightFrame
        screen: root.targetScreen
        visible: root.frameEnabled
        implicitWidth: root.rightThickness
        width: root.rightThickness
        color: "transparent"
        anchors {
            top: true
            bottom: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "ambxst:screenFrame:right"

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        mask: Region {
            item: noInputRegion
        }
    }

    PanelWindow {
        id: frameOverlay
        screen: root.targetScreen
        visible: root.frameEnabled
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "ambxst:screenFrame:overlay"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        mask: Region {
            item: noInputRegion
        }

        ScreenFrameContent {
            id: frameContent
            anchors.fill: parent
            targetScreen: root.targetScreen
        }
    }
}
