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

  title.text: Util.processPrompt(prompt)
  width: 720
  height: 420

  // 标题区域
  Rectangle {
    id: headerArea
    anchors.top: title.bottom
    anchors.topMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 20
    height: 30
    color: "transparent"
    
    Text {
      anchors.centerIn: parent
      text: is_ban ? Lua.tr("Ban Phase - Select generals to ban") : Lua.tr("Choose Phase - Select generals for your pool")
      color: is_ban ? "#ff6b6b" : "#4ecdc4"
      font.pixelSize: 16
      font.bold: true
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
          selectable: !my_selected.includes(index) && !ur_selected.includes(index)
          chosenInBox: selectedItem.includes(index)

          // 禁将模式下显示不同的选中效果
          Rectangle {
            anchors.fill: parent
            color: is_ban && chosenInBox ? "#80ff0000" : "transparent"
            radius: 5
            visible: is_ban && chosenInBox
          }

          onClicked: {
            if (!selectable || num == 0) return;

            if (chosenInBox) {
              selectedItem.splice(root.selectedItem.indexOf(index), 1);
              chosenInBox = false;
            } else {
              chosenInBox = true;
              root.selectedItem.push(index);
              if (selectedItem.length > num) {
                generalRepeater.itemAt(selectedItem[0]).chosenInBox = false;
                selectedItem.splice(0, 1);
              }
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
        text: Lua.tr("Selected: %1 / %2").arg(selectedItem.length).arg(num)
        color: selectedItem.length === num ? "#4ecdc4" : "#ffffff"
        font.pixelSize: 14
      }
      
      Text {
        text: is_ban ? Lua.tr("Banned generals will be removed from the pool") : Lua.tr("Selected generals will join your pool")
        color: "#aaaaaa"
        font.pixelSize: 12
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
        text: is_ban ? Lua.tr("Ban") : Lua.tr("Confirm")
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
    buttonConfirm.enabled = selectedItem.length == num;
    buttonDetail.enabled = selectedItem.length;
  }

  function loadData(data) {
    [generals, num, my_selected, ur_selected, prompt, is_ban] = data;
    selectedItem = [];
  }
}
