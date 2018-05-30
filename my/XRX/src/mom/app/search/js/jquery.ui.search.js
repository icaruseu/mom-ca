 /*! 
 * jQuery UI mom search
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.autocomplete.js
 */

;(function( $, undefined ) {
var selCheckbox_ = "input[type=checkbox]";

$.widget("ui.search", {

  

  options: {    requestRoot: ""
  },


  
  _create: function() {
	
    this._initSearchField();
    this._initOptions();
    this._initSort();
    this._initCategories();
    this._initFilter();
    this._initContext();
    this._initTrigger();
  },



  _initSearchField: function() {
    var self = this;
    
    self.split = function( val ) {
      return val.split(/\s+/);
    };
    
    self.extractLast = function( term ) {
      return self.split( term ).pop();
    };
    
    $("#search-field")      
    .bind( "keydown", function( event ) {
      if ( event.keyCode === $.ui.keyCode.TAB &&
          $( this ).data( "ui-autocomplete" ).menu.active ) {
        event.preventDefault();
      }
    }) /**
    .autocomplete({
      source: function( request, response ) {
        $.getJSON("/terms.xql", {
          term: self.extractLast( request.term )
        }, response );
      },
      delay: 200,
      focus: function( event, ui ) {
        return false;
      },
      search: function() {
        var term = self.extractLast( this.value );
        if ( term.length < 2 ) {
          return false;
        }
      },
      select: function( event, ui ) {
        var terms = self.split( this.value );
        // remove the current input
        terms.pop();
        // add the selected item
        terms.push( ui.item.value );
        // add placeholder to get the comma-and-space at the end
        terms.push("");
        this.value = terms.join( " " );
        return false;
      }
    }) */;
  },



  _initOptions: function() {

    var getRaw = function() {
      var q = $("#search-field").val()
          .replace(/(OR|\,|\"|\')/g, "")
          .replace(/^\s*|\s(?=\s)|\s*$/g, "")
          .split(/\s/);
      return q;
    };

    $("input[type=radio]", "#search-options") .click(function() {

      switch($(this).val()) {
      case "and":
        $("#search-field").val(getRaw().join(" "));
        break;
      case "or":
        $("#search-field").val(getRaw().join(" OR "));
        break;
      case "phrase":
        $("#search-field").val('"' + getRaw().join(" ") + '"');
        break;
      default:
        break;
      }
    });
  },



  _initSort: function() {
    
    $("#result-sort-date").change(function() {
      $("#search-sort-date").prop("checked", $(this).is(":checked"));
    });
    $("#result-sort-ranking").change(function() {
      $("#search-sort-ranking").prop("checked", $(this).is(":checked"));
    });
  },



  _initCategories: function() {
    var str = [];
    $(selCheckbox_, "#categories-result").each(function() {
      if (this.checked) str.push($(this).attr('name'));
    });

    $("#categories-search").val(str.join(","));    
    
    // select and deselect search categories
    $(selCheckbox_, "#categories-result").change(function() {
      var str = [];
      $(selCheckbox_, "#categories-result").each(function() {
        if (this.checked) str.push($(this).attr('name'));
      });

      $("#categories-search").val(str.join(","));
    });
  },



  _initFilter: function() {
    $("#result-only-image").change(function() {
      if ($(this).is(":checked")) {
        $("#search-only-image").prop("checked", $(this).is(":checked")).val("true");
      } else {
        $("#search-only-image").prop("checked", $(this).is(":checked")).val("false");
      }
    });
    $("#result-only-annotations").change(function() {
      if ($(this).is(":checked")) {
        $("#search-only-annotations").prop("checked", $(this).is(":checked")).val("true");
      } else {
        $("#search-only-annotations").prop("checked", $(this).is(":checked")).val("false");
      }
    });    
  },


  _initContext: function() {
    var str = [];
    $(selCheckbox_, "#context-result").each(function() {
      if (this.checked) str.push($(this).attr('name'));
    });

    $("#context-search").val(str.join(","));    
    
    // select and deselect archives / collections
    $(selCheckbox_, "#context-result").change(function() {
      var str = [];
      $(selCheckbox_, "#context-result").each(function() {
        if (this.checked) str.push($(this).attr('name'));
      });

      $("#context-search").val(str.join(","));
    });
  },



  _initTrigger: function() {
    
    $(".confine-trigger").click(function() {
      $("#search-form").submit();
    });
  }

});
  
})( jQuery );
