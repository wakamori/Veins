/* Author:
    2011 chenji <wakamori111 at gmail.com> @chen_ji on twitter
*/

$(function() {
    if ($("#editor")[0] != undefined) {
        var editor = CodeMirror.fromTextArea($("#editor")[0], {
            lineNumbers: true
        });
        $("#runbtn").click(function() {
            $("#sourceinput").val(editor.getValue());
            $("#codeform").submit();
        });
    }
    $("#signoutbtn").click(function() {
        $("#signoutform").submit();
    });
    $("input#username").blur(function() {
        if (!this.value) {
            return;
        }
        $.ajax({
            type: "POST",
            url: "/aspen/check/username",
            dataType: "json",
            data: {
                username: this.value
            },
            success: function(msg) {
                if (msg.exists) {
                    $("#username-group").removeClass("success").addClass("error");
                    $("#username-help").text("Username is already taken.");
                }
                else {
                    $("#username-group").removeClass("error").addClass("success");
                    $("#username-help").text("OK.");
                }
            }
        });
    });
    $("input#username").focus(function() {
        $("#username-group").removeClass("error").removeClass("success");
        $("#username-help").text("");
    });
});


