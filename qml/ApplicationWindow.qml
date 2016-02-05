/*
 *   Copycontext 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Controls 1.3
import "private"
import org.kde.plasma.mobilecomponents 0.2

/**
 * A window that provides some basic features needed for all apps
 *
 * It's usually used as a root QML component for the application.
 * It's based around the PageRow component, the application will be
 * about pages adding and removal.
 *
 * Example usage:
 * @code
 * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
 *
 * MobileComponents.ApplicationWindow {
 *  [...]
 *     globalDrawer: MobileComponents.GlobalDrawer {
 *         actions: [
 *            MobileComponents.Action {
 *                text: "View"
 *                iconName: "view-list-icons"
 *                MobileComponents.Action {
 *                        text: "action 1"
 *                }
 *                MobileComponents.Action {
 *                        text: "action 2"
 *                }
 *                MobileComponents.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            MobileComponents.Action {
 *                text: "Sync"
 *                iconName: "folder-sync"
 *            }
 *         ]
 *     }
 *
 *     contextDrawer: MobileComponents.ContextDrawer {
 *         id: contextDrawer
 *     }
 * 
 *     initialPage: MobileComponents.Page {
 *         mainAction: MobileComponents.Action {
 *             iconName: "edit"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *         contextualActions: [
 *             MobileComponents.Action {
 *                 iconName: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             },
 *             MobileComponents.Action {
 *                 iconName: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *         ]
 *       [...]
 *     }
 *  [...]
 * }
 * @endcode
 *
 * @inherit QtQuick.Controls.ApplicationWindow
 */
ApplicationWindow {
    id: root

    /**
     * pageStack: StackView
     * Readonly.
     * The stack used to allocate the pages and to manage the transitions
     * between them.
     * It's using a PageRow, while having the same API as PageStack,
     * it positions the pages as adjacent columns, with as many columns
     * as can fit in the screen. An handheld device would usually have a single
     * fullscreen column, a tablet device would have many tiled columns.
     */
    property alias pageStack: __pageStack

    /**
     * Shows a little passive notification at the bottom of the app window
     * lasting for few seconds, with an optional action button.
     *
     * @param message The text message to be shown to the user.
     * @param timeout How long to show the message:
     *            possible values: "short", "long" or the number of milliseconds
     * @param actionText Text in the action button, if any.
     * @param callBack A JavaScript function that will be executed when the
     *            user clicks the button.
     */
    function showPassiveNotification(message, timeout, actionText, callBack) {
        if (!__actionButton.__passiveNotification) {
            var component = Qt.createComponent("private/PassiveNotification.qml");
            __actionButton.__passiveNotification = component.createObject(contentItem.parent);
        }

        __actionButton.__passiveNotification.showNotification(message, timeout, actionText, callBack);
    }

    PageRow {
        id: __pageStack
        anchors {
            fill: parent
            bottomMargin: Qt.inputMethod.keyboardRectangle.height
        }
        focus: true
        Keys.onReleased: {
            if (event.key == Qt.Key_Back) {
                if (root.contextDrawer && root.contextDrawer.opened) {
                    root.contextDrawer.close();
                    event.accepted = true;
                } else if (root.globalDrawer && root.globalDrawer.opened) {
                    root.globalDrawer.close();
                    event.accepted = true;
                } else if (stackView.depth > 1) {
                    stackView.pop();
                    event.accepted = true;
                }
            }
        }
    }

    /**
     * globalDrawer: AbstractDrawer
     * The drawer for global actions, that will be opened by sliding from the
     * left screen edge or by dragging the ActionButton to the right.
     * It is recommended to use the GlobalDrawer class here
     */
    property AbstractDrawer globalDrawer
    
    /**
     * contextDrawer: AbstractDrawer
     * The drawer for context-dependednt actions, that will be opened by sliding from the
     * right screen edge or by dragging the ActionButton to the left.
     * It is recommended to use the ContextDrawer class here.
     * The contents of the context drawer should depend from what page is
     * loaded in the main pageStack
     *
     * Example usage:
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     *
     * MobileComponents.ApplicationWindow {
     *  [...]
     *     contextDrawer: MobileComponents.ContextDrawer {
     *         id: contextDrawer
     *     }
     *  [...]
     * }
     * @endcode
     *
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     *
     * MobileComponents.Page {
     *   [...]
     *     contextualActions: [
     *         MobileComponents.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         },
     *         MobileComponents.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         }
     *     ]
     *   [...]
     * }
     * @endcode
     *
     * When this page will be the current one, the context drawer will visualize
     * contextualActions defined as property in that page.
     */
    property AbstractDrawer contextDrawer

    onGlobalDrawerChanged: {
        globalDrawer.parent = contentItem.parent;
    }
    onContextDrawerChanged: {
        contextDrawer.parent = contentItem.parent;
    }

    width: Units.gridUnit * 25
    height: Units.gridUnit * 30

    /**
     * actionButton: ActionButton
     * Readonly.
     * ActionButton can't be instantiated directly by the user.
     * This is the Action button shown in the middle bottom of the page.
     * It will open the side drawers by dragging it around.
     * Also, it is possible to assign an Action to it, dependent from the page.
     *
     * Example usage:
     *
     * @code
     * import org.kde.plasma.mobilecomponents 0.2 as MobileComponents
     * MobileComponents.Page {
     *     mainAction: MobileComponents.Action {
     *         iconName: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     *
     * When that page will be the current one in the app, the action button
     * will have the icon of the page's mainAction and when clicked it will
     * trigger it.
     */
    property alias actionButton: __actionButton
    ActionButton {
        id: __actionButton
        //put it there just to make it not accessible bu users
        property Item __passiveNotification
        z: 9999
        anchors.bottom: parent.bottom
        x: parent.width/2 - width/2
        iconSource: action && action.iconName ? action.iconName : ""

        visible: root.globalDrawer || root.contextDrawer
    }
}
