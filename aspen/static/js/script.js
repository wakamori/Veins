/* Author:
    2011 chenji <wakamori111 at gmail.com> @chen_ji on twitter
*/

$(function() {
    var editor = CodeMirror.fromTextArea($("#editor")[0], {
        lineNumbers: true
    });
    $("#runbtn").click(function() {
        $("#sourceinput").val(editor.getValue());
        $("#codeform").submit();
    });
});


