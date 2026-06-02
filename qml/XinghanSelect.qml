// SPDX-License-Identifier: GPL-3.0-or-later
// 星汉灿烂 1v1 选将界面
// 支持禁将和选将两种模式

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
  id: root

  property var generals: []
  property var selectedItem: []
  property int num: 1
  property string prompt: ""
  property var my_selected: []
  property var ur_selected: []
  property bool is_ban: false
  property int sceneWidth: roomScene && roomScene.width ? roomScene.width : 760
  property int sceneHeight: roomScene && roomScene.height ? roomScene.height : 520
  property int cardColumns: Math.max(2, Math.min(6, Math.floor(cardArea.width / 96)))

  title.text: Util.processPrompt(prompt)
  width: Math.max(360, Math.min(760, sceneWidth - 48))
  height: Math.max(360, Math.min(520, sceneHeight - 72))

  Flickable {
    id: cardArea
    anchors.top: title.bottom
    anchors.topMargin: 10
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.bottom: buttonArea.top
    anchors.bottomMargin: 8

    contentWidth: width
    contentHeight: gridLayout.implicitHeight
    ScrollBar.vertical: ScrollBar {}
    flickableDirection: Flickable.VerticalFlick
    
    clip: true

    GridLayout {
      id: gridLayout
      columns: root.cardColumns
      width: parent.width
      columnSpacing: 8
      rowSpacing: 8

      Repeater {
        id: generalRepeater
        model: generals

        delegate: GeneralCardItem {
          name: modelData
          selectable: !my_selected.includes(index) && !ur_selected.includes(index)
          chosenInBox: selectedItem.includes(index)

          onClicked: {
            if (!selectable || num == 0) return;

            if (chosenInBox) {
              selectedItem.splice(selectedItem.indexOf(index), 1);
              chosenInBox = false;
            } else {
              chosenInBox = true;
              root.selectedItem.push(index);
              if (selectedItem.length > num) {
                generalRepeater.itemAt(selectedItem[0]).chosenInBox = false;
                selectedItem.splice(0, 1);
              }
            }
            selectedItem = selectedItem.slice();
            updateSelectable();
          }

          onRightClicked: {
            if (Lua.evaluate('ClientInstance:getSettings("enableFreeAssign")'))
              roomScene.startCheat("FreeAssign", { card: this });
          }
        }
      }
    }
  }

  Item {
    id: buttonArea
    height: 40
    width: parent.width
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    
    RowLayout {
      anchors.horizontalCenter: parent.horizontalCenter
      width: Math.min(parent.width - 24, 360)
      spacing: 15

      MetroButton {
        id: buttonConfirm
        Layout.preferredWidth: 120
        text: is_ban ? Lua.tr("Ban") : Lua.tr("OK")
        enabled: selectedItem.length == num

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("",
            { ids: selectedItem, generals: selectedItem.map(id => generalRepeater.itemAt(id).name) }
          );
        }
      }

      MetroButton {
        id: buttonDetail
        Layout.fillWidth: true
        enabled: selectedItem.length > 0
        text: Lua.tr("Show General Detail")
        onClicked: roomScene.startCheat(
          "GeneralDetail",
          { generals: selectedItem.map(id => generalRepeater.itemAt(id).name) }
        );
      }
    }
  }

  function updateSelectable() {
    buttonConfirm.enabled = selectedItem.length == num;
    buttonDetail.enabled = selectedItem.length > 0;
  }

  function loadData(data) {
    generals = data[0];
    num = data[1];
    my_selected = data[2] || [];
    ur_selected = data[3] || [];
    prompt = data[4];
    is_ban = data[5] || false;
    selectedItem = [];
  }
}
