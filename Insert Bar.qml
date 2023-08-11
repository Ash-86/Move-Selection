
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
		for (var i in curScore.selection.elements) {
			if (curScore.selection.elements[i].type==Element.tuplet){
				removeElement(curScore.selection.elements[i].tuplet)
			}else{
				removeElement(curScore.selection.elements[i])
			}
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
