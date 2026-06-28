// SPDX-License-Identifier: GPL-3.0-or-later
// 星汉灿烂 1v1 选将界面
// 支持禁将和选将两种模式

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Fk
import Fk.Components.Common
import LunarLtk
import LunarLtk.Components
import LunarLtk.Pages.Popups

GraphicsBox {
  id: root

  property var generals: []
  property var selectedItem: []
  property int num: 1
  property string prompt: ""
  property var my_selected: []
  property var ur_selected: []
  property bool is_ban: false

  title.text: Ltk.processPrompt(prompt)
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
          required property string modelData
          required property int index

          dataModel: Ltk.createGeneralCardModel(modelData)
          selectable: !my_selected.includes(index) && !ur_selected.includes(index)
          chosenInBox: selectedItem.includes(index)

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
        text: is_ban ? Lua.tr("Ban") : Lua.tr("OK")
        enabled: selectedItem.length == num

        onClicked: {
          close();
          Ltk.roomModel.deActivate();
          ClientInstance.replyToServer("",
            { ids: selectedItem, generals: selectedItem.map(id => generalRepeater.itemAt(id).dataModel.name) }
          );
        }
      }

      MetroButton {
        id: buttonDetail
        enabled: selectedItem.length > 0
        text: Lua.tr("Show General Detail")
        onClicked: roomScene.showInfoPopup(
          Qt.createComponent("LunarLtk.Pages.InfoPopups", "GeneralDetail"),
          { generals: selectedItem.map(id => generalRepeater.itemAt(id).dataModel.name) }
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
