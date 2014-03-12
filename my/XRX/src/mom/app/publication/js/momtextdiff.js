CodeMirror.defineMode("momtextdiff", function(config, parserConfig) {
	
	// equal
	var TOKEN_EQUALIN = "equalin";
	// insert
	var TOKEN_INSERTSTART = "insertstart";
	var TOKEN_INSERTIN = "insertin";
	var TOKEN_INSERTEND = "insertend";
	// delete
	var TOKEN_DELETESTART = "deletestart";
	var TOKEN_DELETEIN = "deletein";
	var TOKEN_DELETEEND = "deleteend";

	var parserIn = false;
	
	function style(state, style, isStart) {
		
		var tmp;
		if(isStart) tmp = state.stack.pop();
		var overlayStyle = state.stack.join(" ") + " " + style;
		if(isStart) state.stack.push(tmp);
		return overlayStyle;
	}
	
	function pushState(state, node) {
		
		state.tokenize = eval(node);
		state.stack.push(node);
		// console.log("Push: " + state.stack);
	}
	
	function popState(state) {
		
		state.stack.pop();
		state.tokenize = eval(state.stack[state.stack.length - 1]);
		// console.log("Pop: " + state.stack);
	}
	
	function equalin(stream, state) {

		var ch = stream.next();
		if (ch == "+") {
			if(stream.match("+")) {
				pushState(state, TOKEN_INSERTIN);
				return TOKEN_INSERTSTART;
			}
		}
		if (ch == "-") {
			if(stream.match("-")) {
				pushState(state, TOKEN_DELETEIN);
				return TOKEN_DELETESTART;
			}
		}
		else return TOKEN_EQUALIN;
	}
	
	function insertin(stream, state) {
		
		var ch = stream.next();
		if (ch == "+") {
			if(stream.match("+")) {
				popState(state);
				return TOKEN_INSERTEND;
			}
		}
		else return TOKEN_INSERTIN;
	}

	function deletein(stream, state) {
		
		var ch = stream.next();
		if (ch == "-") {
			if(stream.match("-")) {
				popState(state);
				return TOKEN_DELETEEND;
			}
		}
		else return TOKEN_DELETEIN;
	}
		
	return {

		startState: function() {
			return {
				
				tokenize: equalin,
				stack: ["equalin"]
			};
		},
		
		token: function(stream, state) {
			
			var ch = stream.next();
			if (ch == "+" || ch == "-") {
				
				stream.backUp(1);
				var style = state.tokenize(stream, state);
				return style;
			}
			if( state.stack[1] == 'insertin') return "insertin"
			else if( state.stack[1] == 'deletein') return "deletein"
			else return null;

		}
	};
	
});

CodeMirror.defineMIME("text/momtextdiff", "momtextdiff");