/*
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
*/
(function() {

var MSG_INVALID_CHARACTER = "Invalid character: ";
var MSG_DELETE_FIRST_LAST_CHAR_FORBIDDEN = "First and last Char cannot be deleted.";
var MSG_REDO_UNDO_NOT_SUPPORTED_YET = "Redo / Undo is not supported at the moment.";
var MSG_ENTER_NOT_INTENDED = "The Enter Key is not intended to use. Use a line-break Tag instead.";
	
function infoMessage(message) {
	
	$(".xrx-message").xrxMessage({ 
		state: "highlight",
		icon: "info",
		message: message
	});
}

var map = CodeMirror.keyMap.visualxml = {
	Delete: function(cm) {
		var pos = cm.getCursor(), numLastLine = cm.lineCount() - 1,
			lastLine = cm.getLine(numLastLine); 
		if(pos.line == 0 && pos.ch == 0 && !cm.somethingSelected()) infoMessage(MSG_DELETE_FIRST_LAST_CHAR_FORBIDDEN);
		else if(pos.line == numLastLine && (pos.ch == lastLine.length - 1 || pos.ch == lastLine.length)) infoMessage(MSG_DELETE_FIRST_LAST_CHAR_FORBIDDEN);
		else throw CodeMirror.Pass;
	},
	Backspace: function(cm) {
		var pos = cm.getCursor(), numLastLine = cm.lineCount() - 1,
			lastLine = cm.getLine(numLastLine);
		if(pos.line == 0 && pos.ch == 1 && !cm.somethingSelected()) infoMessage(MSG_DELETE_FIRST_LAST_CHAR_FORBIDDEN);
		else if(pos.line == numLastLine && pos.ch == lastLine.length) infoMessage(MSG_DELETE_FIRST_LAST_CHAR_FORBIDDEN);
		else throw CodeMirror.Pass;
	},
	"'<'": function(cm) { infoMessage(MSG_INVALID_CHARACTER + "'<'") },
	"'>'": function(cm) { infoMessage(MSG_INVALID_CHARACTER + "'>'") },
	"Ctrl-Z": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	"Cmd-Z": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	"Shift-Ctrl-Z": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	"Ctrl-Y": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	"Shift-Cmd-Z": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	"Cmd-Y": function(cm) { infoMessage(MSG_REDO_UNDO_NOT_SUPPORTED_YET) },
	Enter: function(cm) { infoMessage(MSG_ENTER_NOT_INTENDED) },
	fallthrough: "default"
};

})();