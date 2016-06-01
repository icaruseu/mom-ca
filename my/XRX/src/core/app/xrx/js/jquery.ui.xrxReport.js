/*!
 * jQuery UI Forms Validation Report
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var uiMainDivClass						=	"xrx-report";
	
$.widget( "ui.xrxReport", {

	options: {
		serviceUrlValidateInstance: ""
	},
	
	_create: function() {
		
		var self = this;
		
		self.validate();
	},

	validate: function() {

		var self = this;

		$.ajax({
			url: self.options.serviceUrlValidateInstance,
			type: "POST",
			contentType: "application/xml",
			data: $(".xrx-instance").text(),
			dataType: "text",
			success: function(data) {
				var report = jQuery.parseJSON(data);
				self._show(report);
				self.report = report;
				$(document).xrx.validationRefresh();
				var text = $("#tab-validation-report").text();
				// TODO: replace by a event handler
				if(report["status"] == "invalid") {
					var wrapper = $('<span></span>').addClass("ui-state-error").css("border", "none");
					var iconSpan = $('<span></span>').addClass("ui-icon ui-icon-alert").css("float", "left");
					var textSpan = $("<span></span>").addClass("background-color", "none").text(text);
					wrapper.append(iconSpan).append(textSpan);
					$("#tab-validation-report").text("").append(wrapper);
				} else {
					$("#tab-validation-report").html(text);
				}
			}
		});
	},
	
	asJson: function() {
		
		return this.report;
	},
	
	_show: function(report) {
		
		var self = this
			status = report["status"],
			duration = report["duration"],
			messages = report["messages"],
		
			reportDiv = $('<div></div>')
				.css("padding", "5px"),
			
			statusDiv = $('<div></div>')
				.text(status + " (" + duration + ")"),
			
			messageDiv = $('<div></div>'),

			listDiv = $('<ol></ol>');

		
		for(var key in messages) {
		    errorDiv = $('<div name="error-code" value="' + messages[key][1] + '" fatal-error="' + messages[key][2] +'"></div>')
			listDiv.append('<li>' + messages[key][0] + '</li>');
			listDiv.append(errorDiv);
		}
		
		messageDiv.append(listDiv);
		reportDiv.append(statusDiv)
			.append(messageDiv);
		
		if(status == "invalid") {
			self.element.addClass("ui-state-error");
		}
		else {
			self.element.removeClass("ui-state-error");
		}
		
		//console.log(messages);
		
		$("." + uiMainDivClass).find('div').remove().end().append(reportDiv);
	}
	
});

})( jQuery );