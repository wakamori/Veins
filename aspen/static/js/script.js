/* Author:
    2011 chenji <wakamori111 at gmail.com> @chen_ji on twitter
*/

$(function() {
    var editor = CodeMirror.fromTextArea($("#editor")[0], {
        lineNumbers: true
    });
    $("#runbtn").click(function() {
        $.ajax({
            type: "POST",
            url: "http://localhost/cgi-bin/konoha2js.k",
            data: {
                requestedType: "html",
                source: editor.getValue()
            },
            success: function(msg) {
                $("#body").html("<div class=\"modal-body\" id=\"body\"><iframe sandbox=\"allow-same-origin allow-forms allow-scripts\" src=\"" + msg.src + "\"></iframe></div>");
            },
            error: function(msg) {
                alert("error: " + msg);
            }
        });
    });
});


