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
  property var lockedGenerals: []
  property int minNum: 1
  property int maxNum: 2
  property string prompt: ""

  title.text: Util.processPrompt(prompt)
  width: 720
  height: 450

  // 标题区域
  Rectangle {
    id: headerArea
    anchors.top: title.bottom
    anchors.topMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 20
    height: 30
    color: "transparent"
    
    Row {
      anchors.centerIn: parent
      spacing: 30
      
      Text {
        text: Lua.tr("Available Generals")
        color: "#4ecdc4"
        font.pixelSize: 14
        font.bold: true
      }
      
      Text {
        text: Lua.tr("Locked Generals: %1").arg(lockedGenerals.length)
        color: "#ff6b6b"
        font.pixelSize: 14
      }
    }
  }

  Flickable {
    id: cardArea
    height: 280
    width: 700
    anchors.top: headerArea.bottom
    anchors.topMargin: 5
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

          // 锁定武将显示灰色遮罩
          Rectangle {
            anchors.fill: parent
            color: "#80000000"
            radius: 5
            visible: lockedGenerals.includes(modelData)
            
            Text {
              anchors.centerIn: parent
              text: Lua.tr("LOCKED")
              color: "#ff6b6b"
              font.pixelSize: 16
              font.bold: true
            }
          }

          onClicked: {
            if (!selectable || maxNum == 0) return;

            if (chosenInBox) {
              selectedItem.splice(root.selectedItem.indexOf(index), 1);
              chosenInBox = false;
            } else {
              if (selectedItem.length >= maxNum) {
                // 取消最早的选择
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

  // 信息显示区域
  Rectangle {
    id: infoArea
    anchors.top: cardArea.bottom
    anchors.topMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 20
    height: 25
    color: "transparent"
    
    Row {
      anchors.centerIn: parent
      spacing: 20
      
      Text {
        text: Lua.tr("Selected: %1").arg(selectedItem.length)
        color: selectedItem.length >= minNum ? "#4ecdc4" : "#ffffff"
        font.pixelSize: 14
      }
      
      Text {
        text: Lua.tr("Select %1-%2 generals").arg(minNum).arg(maxNum)
        color: "#aaaaaa"
        font.pixelSize: 12
      }
      
      Text {
        text: Lua.tr("Dual General: HP = floor((HP1 + HP2) / 2)")
        color: "#aaaaaa"
        font.pixelSize: 12
        visible: maxNum >= 2
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
        enabled: selectedItem.length
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
    buttonDetail.enabled = selectedItem.length;
  }

  function loadData(data) {
    [generals, minNum, maxNum, lockedGenerals, prompt] = data;
    selectedItem = [];
  }
}
