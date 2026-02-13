// SPDX-License-Identifier: GPL-3.0-or-later
// 星汉灿烂 1v1 上阵选择界面
// 支持选择1-2名武将上场

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
  property int minNum: 1
  property int maxNum: 2
  property var lockedGenerals: []
  property string prompt: ""

  title.text: Util.processPrompt(prompt)
  width: 620
  height: 370

  Flickable {
    id: cardArea
    height: 280
    width: 600
    anchors.top: title.bottom
    anchors.topMargin: 10
    anchors.horizontalCenter: parent.horizontalCenter

    contentHeight: gridLayout.implicitHeight
    ScrollBar.horizontal: ScrollBar {}
    flickableDirection: Flickable.VerticalFlick
    
    clip: true

    GridLayout {
      id: gridLayout
      columns: 6
      width: parent.width
      height: parent.height
      clip: true

      Repeater {
        id: generalRepeater
        model: generals

        delegate: GeneralCardItem {
          name: modelData
          selectable: !lockedGenerals.includes(modelData)
          chosenInBox: selectedItem.includes(index)

          onClicked: {
            if (!selectable) return;

            if (chosenInBox) {
              // 取消选择
              selectedItem.splice(root.selectedItem.indexOf(index), 1);
              chosenInBox = false;
            } else {
              // 选择
              if (selectedItem.length >= maxNum) {
                // 已达到最大数量，取消最早的选择
                generalRepeater.itemAt(selectedItem[0]).chosenInBox = false;
                selectedItem.splice(0, 1);
              }
              chosenInBox = true;
              root.selectedItem.push(index);
            }
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
    
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 15

      MetroButton {
        id: buttonConfirm
        width: 120
        text: Lua.tr("Deploy")
        enabled: selectedItem.length >= minNum && selectedItem.length <= maxNum

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
    buttonConfirm.enabled = selectedItem.length >= minNum && selectedItem.length <= maxNum;
    buttonDetail.enabled = selectedItem.length > 0;
  }

  function loadData(data) {
    generals = data[0] || [];
    minNum = data[1] || 1;
    maxNum = data[2] || 2;
    lockedGenerals = data[3] || [];
    prompt = data[4] || "";
    selectedItem = [];
    updateSelectable();
  }
}
