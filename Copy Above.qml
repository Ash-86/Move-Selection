
import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	title: "Copy Above"
	description: "Copies selection to the staff above."
	version: "1.0"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "do.png"
	

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
		if (startStaff==0){
			quit()    /// Don't run beyond top staff 
		}else{
		
			curScore.startCmd();


			cmd("copy");
					
		
			cursor.track=startTrack-4; //// set cursor to staff above
			cursor.rewindToTick(startSegTick); // go back to beginning of selection
					
			/////// In case the startSegTick at lower staff falls within the space of an element, 
			/////// (cursor.tick in this case returns tick of next element)
			//////// navigate to previous element and addRest until element tick coincides with startSegTick. 			
								
					
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
			
			if (cursor.element.type==Element.CHORD){ ///special case to select chords if they exist
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