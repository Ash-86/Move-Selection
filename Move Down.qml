//========================================================================
// Move Down v1.0                                         
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
	title: "Move DOWN"
	description: "Moves selection to the staff below."
	version: "1.0"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "down.png"
	


    onRun: {
		///// get start and end tics,staff,and track, for selection 
		var cursor = curScore.newCursor(); 			
		//end
		cursor.rewind(2); // go to the end of the selection
		var endTick = cursor.tick;
		// if (endTick == 0) { // dealing with some bug when selecting to end.
   		// 	var endTick = score.lastSegment.tick + 1;
		// }
		var endStaff = cursor.staffIdx +1;
        var endTrack = endStaff * 4;
		//start		
		cursor.rewind(1); // go to the beginning of the selection
		// var startSegTick= cursor.segment.tick
		var startSegTick= curScore.selection.startSegment.tick;
		var startTick = cursor.tick;
		var startStaff = cursor.staffIdx;
		var startTrack = startStaff * 4;
		///////////////////////////////////////////////////////////////
		if (endStaff==curScore.nstaves){ 
			quit()   /// Don't run beyond lowest staff 
		}else{
			

			curScore.startCmd();

			cmd("copy");
			

			var e = curScore.selection.elements
			for (var i in e) {
				
				// cusror.rewind(e[i].tick)
				// if (e[i].type==Element.tuplet){ ///doesnt work
				// 	removeElement(e[i].tuplet)
				// }
				// if(e[i].tuplet) {
				// 	removeElement(e[i].tuplet); // must specifically remove tuplets
				// } 		

				// if (e[i].parent.type==Element.CHORD){								
				// 	removeElement(e[i].parent)
				// }
				// if (e[i].type==Element.NOTE  ){   //special handling of chords  ////  crashes when undoing
				// 	removeElement(e[i].parent)
				// }
				
			// 	// if (e[i].type==Element.STAFF_TEXT){ //is not needed aparently 
			// 	// 	removeElement(e[i].STAFF_TEXT)
			// 	// }				
			// 	// if (e[i].type==Element.LYRIC){  //is not needed 
			// 	// 	removeElement(e[i].LYRIC)
			// 	// }							
				// else{
					removeElement(e[i]) /// deletes everything exept tuplets when there are single notes (no chords)
				// }				
			}
		
			

			/////////not sure why, chords and tuplets  could only get removed by iterating over segments as in the following block
			while(cursor.segment && cursor.tick < endTick ) {					
				var e = cursor.element;
				var a = cursor.segment.annotations  ////for deleting roman numerals and dynamic markings when chords are presnt
				if(e.tuplet) {
					removeElement(e.tuplet); // must specifically remove tuplets
				} 							
				else {
					removeElement(e); ///deletes chords
				}
				for (var i in a){				
					removeElement(a[i])						
				}				
				cursor.next();					
			}
			////////////////////////////////
			
			cursor.track=startTrack+4; //// set cursor to staff above
			cursor.rewindToTick(startSegTick); // go back to beginning of selection
					
			/////// In case the startTick at lower staff falls within the space of an element, 
			/////// (cursor.tick in this case returns tick of next element)
			//////// navigate to previous element and addRest until element tick coincides with startTick. 			
				
			if (cursor.tick > startSegTick){	/// for empty measures with odd time signature, in order not to end up with awkward rest durations resulting from dividing by 2.
				cursor.prev();
				cursor.setDuration(1, 4);
				cursor.addRest();					
				cursor.rewindToTick(startSegTick);	
			}

			while(cursor.tick > startSegTick){	
				cursor.prev();
				var n=cursor.element.duration.numerator;
				var d=cursor.element.duration.denominator;					
				cursor.setDuration(n, d*2);
				cursor.addRest();					
				cursor.rewindToTick(startSegTick);			
			}	
		
			///////////////////////////////////////////////

			if (cursor.element.type==Element.CHORD){
				curScore.selection.select(cursor.element.notes[0])
			}else {
				curScore.selection.select(cursor.element)
			}

			cmd("paste");
			
			
			curScore.endCmd();
			quit();
		}///end else
	}///end onRun
}	