/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: root
    
    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: Kirigami.Units.gridUnit*2.5
    property alias monthName: plasmaCalendar.displayedDateMonthName
    property alias year: plasmaCalendar.year
        
    signal nextMonth
    signal previousMonth
    signal goToday
       
    onNextMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() + 1));
    }
    
    onPreviousMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() -1));
    }
    
    onGoToday: {
        plasmaCalendar.displayedDate = root.currentDate;        
    }
    
    // HACK: Added only as a temporary model provider, to be replaced with a real model provider    
    CalendarBackend {
        id: plasmaCalendar
        
        property int displayedDateMonth: Qt.formatDate(plasmaCalendar.displayedDate,"MM")
        property string displayedDateMonthName: Qt.locale(Qt.locale().uiLanguages[0]).monthName(displayedDateMonth-1) 
        
        days: root.days
        weeks: root.weeks
        today: root.currentDate
    }
    
    
    ColumnLayout {
        spacing: 0
        
        /**
         * Header of the days' calendar grid
         * E.g.
         * Mon Tue Wed ...
         */
        RowLayout {
            spacing: 0           
            
            Repeater {
                model: root.days
                delegate: weekDayDelegate
            }
        }
        
        /**
         * Grid that displays the days of a month (normally 6x7)
         */        
        Grid {        
            Layout.fillWidth: true            
            columns: root.days
            rows: root.weeks
            
            Repeater {
                model: plasmaCalendar.daysModel
                delegate: monthDayDelegate             
            }
        }
    }
    
    /**
     * Month Day Delegate
     * 
     * Controls the display of each day of a months' grid
     */
    Component {
        id: monthDayDelegate 
        
        Rectangle {
            width: childrenRect.width
            height: childrenRect.height
            opacity: dayButton.isCurrentDate ? 0.4 : 1
            color: dayButton.isCurrentDate ? Kirigami.Theme.textColor : Kirigami.Theme.backgroundColor                    
            border.color: Kirigami.Theme.disabledTextColor
            
            Controls2.ToolButton {
                id: dayButton
                
                property bool isCurrentDate: ( Qt.formatDate(root.currentDate, "yyyy") ==  model.yearNumber ) && ( Qt.formatDate(root.currentDate, "MM") ==  model.monthNumber ) && ( Qt.formatDate(root.currentDate, "dd") ==  model.dayNumber )
                
                property bool isCurrentMonth: model.monthNumber == Qt.formatDate(plasmaCalendar.displayedDate, "MM")
                
                width: root.dayRectWidth
                height: width
                text: model.dayNumber
                enabled: isCurrentMonth
            }
            
        }
    }
    
    /**
     * Week Day Delegate
     * 
     * Controls the display of the elements of the header
     */    
    Component {
        id: weekDayDelegate 
        
        Rectangle {
            width: root.dayRectWidth
            height: width
            color: Kirigami.Theme.disabledTextColor
            opacity: 0.8
        
            Controls2.Label {                
                anchors.centerIn: parent
                color: Kirigami.Theme.textColor
                text: Qt.locale(Qt.locale().uiLanguages[0]).dayName(((plasmaCalendar.firstDayOfWeek + model.index) % root.days), Locale.ShortFormat) 
            }            
        }
    }
    
}
