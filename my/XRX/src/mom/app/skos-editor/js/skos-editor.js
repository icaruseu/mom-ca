var url = window.location.href;
var baseUrl = url.split("?")[0];
var urlParams = new URLSearchParams(window.location.search);
var concept = urlParams. get ('c');

//c auf concept umändern!

/*var editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
    mode: 'xml',
    htmlMode: true,
    lineNumbers: true
});
editor.setSize("500", "250");

$('input#submit-content').click(function () {
    var editorContent = editor.getValue();
    
    $.ajax({
        url: "/mom/service/edit-definition?c=" + concept,
        type: "PUT",
        contentType: "application/xml",
        data: editorContent,
        dataType: "xml"
    })
});*/


function htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, "text/html");
    return doc.documentElement.textContent;
};


$('#concept-select').on('change', function () {
    var redirectUrl = baseUrl + "?c=" + $(this).val();
    return (redirectUrl ? window.location = redirectUrl: console.log("Invalid URL!"));
});

$('input#add-label').click(function () {
    var labelLang = document.getElementById("lang-select").value;
    var labelName = document.getElementById("preflabel-input").value;
    
    var addLabelUrl = htmlDecode("/mom/service/add-preflabel?c=" + concept + "&amp;lang=" + labelLang);
    
    $.ajax({
        url: addLabelUrl,
        type: "POST",
        data: labelName,
        contentType: "application/xml",
        dataType: "text"
    })
    
    window.location.reload();
});

$('input.remove-label').click(function () {
    var labelLang = $(this).closest('td').prev().html();
    
    var removeLabelUrl = htmlDecode("/mom/service/remove-label?c=" + concept + "&amp;lang=" + labelLang);
    
    $.ajax({
        url: removeLabelUrl
    })
    
    window.location.reload();
});