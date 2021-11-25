var editor = CodeMirror.fromTextArea
(document.getElementById('editor'), {
    mode: 'xml',
    theme: 'cobalt',
    lineWrapping: true,
    indentUnit: 4
});