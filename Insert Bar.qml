//========================================================================
// Insert Bar v1.0                                          
// https://github.com/Ash-86/Move-Selection                    
//                                                                        
//  Copyright (C)2023 Ashraf El Droubi (Ash-86)                           
//                                                                        
//  This program is free software: you can redistribute it and/or modify  
//  it under the terms of the GNU General Public License as published by  
//  the Free Software Foundation, either version 3 of the License, or     
//  (at your option) any later version.                                   
//                                                                        
//  This program is distributed in the hope that it will be useful,       
//  but WITHOUT ANY WARRANTY; without even the implied warranty of        
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         
//  GNU General Public License for more details.                          
//                                                                        
//  You should have received a copy of the GNU General Public License     
//  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
//========================================================================

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	title: "Insert Bar"
	description: "Inserts an empty bar before the selected staves only."
	version: "1.0"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "do.png"
	


    function insertBar() {
		
		///// get start and end tics,staff,and track, for selection 
		var cursor = curScore.newCursor(); // get the selection			
		//end
		cursor.rewind(2); // go to the end of the selection
		var endTick = cursor.tick;
		if (endTick == 0) { // dealing with some bug when selecting to end.
   			var endTick = score.lastSegment.tick+1;
		}
		var endStaff = cursor.staffIdx +1;
        var endTrack = endStaff * 4;
		//start		
		cursor.rewind(1); // go to the beginning of the selection
		var startSegTick= curScore.selection.startSegment.tick;
		var startTick = cursor.tick;
		var startStaff = cursor.staffIdx;
		var startTrack = startStaff * 4;
		///////////////////////////////////////////////////////////////
		endTick = curScore.lastSegment.tick + 1;
		curScore.selection.selectRange(startTick, endTick, startStaff, endStaff)

		cmd("copy");
		var e= curScore.selection.elements
		for (var i in e) {
			// if (e[i].type==Element.tuplet){   /// does not work
			// 	removeElement(e[i].tuplet)
			// }
			if (e[i].type==Element.NOTE ){  //special handling of chords
				removeElement(e[i].parent)				
			}
			else{				
				removeElement(e[i])
			}
		}

		while(cursor.segment && cursor.tick < endTick ) {					
				var e = cursor.element;				
				if(e.tuplet) {
					removeElement(e.tuplet); // must specifically remove tuplets					
				}				
				cursor.next();					
			}

		
       	// for (var track=startTrack; track< endTrack; track++){  ///iterate over tracks
		// 	cursor.track=track;
		// 	cursor.rewindToTick(startTick);
            // while(cursor.segment && cursor.tick < endTick) {
            //     var e = cursor.element;
			//     if(e.type==Element.tuplet) {removeElement(e.tuplet)} // you have to specifically remove tuplets
			//     if(e.type==Element.LYRIC) {removeElement(e.LYRIC)} // you have to specifically remove tuplets
            //     if(e.type==Element.Note) {removeElement(e.Note)}  
			// 	if(e.type==Element.STAFF_TEXT) {removeElement(e.STAFF_TEXT)}          
            //     cursor.next(); // advance cursor
                
            // }            
        // }		
	
		cursor.track=startTrack;
		cursor.rewindToTick(startSegTick);
		
		cursor.nextMeasure()
		
		
		if (cursor.element.type==Element.CHORD){
			curScore.selection.select(cursor.element.notes[0])
		}else {
			curScore.selection.select(cursor.element)
		}

        cmd("paste");
	}		

	onRun: {
        curScore.startCmd();
		insertBar();
        curScore.endCmd();
        quit();
	}
}
