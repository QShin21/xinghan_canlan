// SPDX-License-Identifier: GPL-3.0-or-later
// 星汉灿烂 1v1 上阵选择界面
// 支持选择minNum到maxNum名武将上场

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
  property int sceneWidth: roomScene && roomScene.width ? roomScene.width : 760
  property int sceneHeight: roomScene && roomScene.height ? roomScene.height : 540
  property int cardColumns: Math.max(2, Math.min(6, Math.floor(cardArea.width / 96)))

  title.text: Util.processPrompt(prompt)
  width: Math.max(360, Math.min(760, sceneWidth - 48))
  height: Math.max(380, Math.min(540, sceneHeight - 72))

  // 提示信息区域
  Rectangle {
    id: hintArea
    anchors.top: title.bottom
    anchors.topMargin: 5
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    height: 25
    color: "transparent"
    
    Text {
      anchors.centerIn: parent
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      text: minNum === maxNum ? 
        Lua.tr("Please select %1 general(s)").arg(minNum) :
        Lua.tr("Please select %1-%2 general(s)").arg(minNum).arg(maxNum)
      color: "#4ecdc4"
      font.pixelSize: 14
      font.bold: true
    }
  }

  Flickable {
    id: cardArea
    anchors.top: hintArea.bottom
    anchors.topMargin: 5
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.bottom: infoArea.top
    anchors.bottomMargin: 5

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
          selectable: !lockedGenerals.includes(modelData)
          chosenInBox: selectedItem.includes(index)

          onClicked: {
            if (!selectable) return;

            if (chosenInBox) {
              // 取消选择
              var idx = selectedItem.indexOf(index);
              if (idx >= 0) {
                selectedItem.splice(idx, 1);
              }
              chosenInBox = false;
            } else {
              // 选择
              if (selectedItem.length >= maxNum) {
                // 已达到最大数量，取消最早的选择
                var firstIdx = selectedItem[0];
                generalRepeater.itemAt(firstIdx).chosenInBox = false;
                selectedItem.splice(0, 1);
              }
              selectedItem.push(index);
              chosenInBox = true;
            }
            // 强制更新
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

  // 信息显示区域
  Rectangle {
    id: infoArea
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    anchors.bottom: buttonArea.top
    anchors.bottomMargin: 5
    height: 20
    color: "transparent"
    
    Text {
      anchors.centerIn: parent
      text: Lua.tr("Selected: %1").arg(selectedItem.length)
      color: selectedItem.length >= minNum && selectedItem.length <= maxNum ? "#4ecdc4" : "#ffffff"
      font.pixelSize: 13
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
        text: Lua.tr("Deploy")
        enabled: selectedItem.length >= minNum && selectedItem.length <= maxNum

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("",
            { ids: selectedItem, generals: selectedItem.map(function(id) { return generalRepeater.itemAt(id).name; }) }
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
          { generals: selectedItem.map(function(id) { return generalRepeater.itemAt(id).name; }) }
        );
      }
    }
  }

  function updateSelectable() {
    var valid = selectedItem.length >= minNum && selectedItem.length <= maxNum;
    buttonConfirm.enabled = valid;
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
