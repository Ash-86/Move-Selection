
import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	title: "Move RIGHT"
	description: "Moves selection to the Right by an 1/8 note."
	version: "1.0"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "right.png"
	


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
		var startSegTick= curScore.selection.startSegment.tick;
		var startTick = cursor.tick;
		var startStaff = cursor.staffIdx;
		var startTrack = startStaff * 4;
		///////////////////////////////////////////////////////////////
		curScore.startCmd();

		
		cmd("copy");
		
		
		
		var e = curScore.selection.elements
		for (var i in e) {
			if (e[i].type==Element.tuplet){
				removeElement(e[i].tuplet)
			}
			if (e[i].type==Element.CHORD){
				for (var j in e[i].notes){
					removeElement(e[i].notes[j])
				}
			}
			if (e[i].type==Element.STAFF_TEXT){
				removeElement(e[i].STAFF_TEXT)
			}
			if (e[i].type==Element.LYRIC){
				removeElement(e[i].LYRIC)
			}
			if (e[i].type==Element.harmony){
				removeElement(e[i].harmony)
			}					
			else{
				removeElement(e[i])
			}				
		}

		////////////////////////////////
		while(cursor.segment && cursor.tick < endTick ) {					
				var e = cursor.element;
				var a = cursor.segment.annotations
				if(e.tuplet) {
					removeElement(e.tuplet); // must specifically remove tuplets
				} 				
				else {
					removeElement(e);
				}
				for (var i in a){
					removeElement(a[i])
				}
				
				cursor.next();					
			}
		/////////////////////////////////
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
		
		if(startSegTick!=startTick){
			cursor.setDuration(1, 16)
			cursor.addRest();	
		}else{
			cursor.setDuration(1, 8)
			cursor.addRest();
		}	
		
		
		if (cursor.element.type==Element.CHORD){
			curScore.selection.select(cursor.element.notes[0])
		}else {
			curScore.selection.select(cursor.element)
		}

        cmd("paste");
			

	
        
	
        curScore.endCmd();
        quit();
	}
}