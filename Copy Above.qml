/*========================================================================
  Move Selection
  https://github.com/Ash-86/Move-Selection

  Copyright (C)2023 Ashraf El Droubi (Ash-86)

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
=========================================================================*/

import QtQuick 2.0
import MuseScore 3.0

MuseScore {
	menuPath: "Plugins.Move/Duplicate Selection.Duplicate to Staff Above"
	description: "Duplicates selection to the staff above."
	version: "1.0"

	//4.4 title: "Duplicate to Staff Above"
	//4.4 thumbnailName: "do.png"
	//4.4 categoryCode: "Move selection"

	Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title= "Duplicate to Staff Above"
            thumbnailName = "do.png"
            categoryCode = "Move selection"
        }
    }

    onRun: {		
		var cursor = curScore.newCursor()
		
		cursor.rewind(2)
		var endTick = cursor.tick
		// if (endTick == 0) { // dealing with some bug when selecting to end.
   		// 	var endTick = score.lastSegment.tick + 1;
		// }
		var endStaff = cursor.staffIdx +1;
        var endTrack = endStaff * 4;

		cursor.rewind(1)
		var startSegTick = curScore.selection.startSegment.tick
		var startTick = cursor.tick
		var startStaff = cursor.staffIdx
		var startTrack = startStaff * 4


		var targetStaff = startStaff - 1
		while (targetStaff >= 0 && curScore.staves[targetStaff].visible == false) { //// skip invisible staves
			targetStaff --
		}
		if (targetStaff < 0) {
			return
		}

		curScore.startCmd("Duplicate to Staff Above")

		cmd("copy")

		var stavesN = endStaff - startStaff
		cursor.track = targetStaff * 4 //// set cursor to staff above
		cursor.rewindToTick(startSegTick) // go back to beginning of selection

		/////// In case the startSegTick at lower staff falls within the space of an element,
		/////// (cursor.tick in this case returns tick of next element)
		//////// navigate to previous element and changeCRLen so element tick coincides with startSegTick.

		if (cursor.tick > startSegTick) {
			cursor.prev()
			var cr = cursor.element                       // Chord or Rest
			if (cr) {
				var chordStart = cursor.tick
				var chordEnd   = chordStart + cr.actualDuration.ticks
				var overlap    = chordEnd - startSegTick

				if (overlap > 0 && chordStart < startSegTick) {
					// keep only the part before startSegTick
					cr.duration = fractionFromTicks(cr.actualDuration.ticks - overlap)
				}
			}
			cursor.rewindToTick(startSegTick)
		}

		if (cursor.element.type==Element.CHORD) { ///special case to select chords if they exist
			curScore.selection.select(cursor.element.notes[0])
		} else {
			curScore.selection.select(cursor.element)
		}

		cmd("paste")

		curScore.endCmd()
	}
}