/* Author:
    2011 chenji <wakamori111 at gmail.com> @chen_ji on twitter
*/

$(function() {
    if ($("#editor")[0] != undefined) {
        var editor = CodeMirror.fromTextArea($("#editor")[0], {
            lineNumbers: true,
            mode: "text/x-konoha"
        });
        $("#runbtn").click(function() {
            $("#sourceinput").val(editor.getValue());
            $("#codeform").submit();
        });
        function getUser(url) {
            var a = url.split("/");
            if (a[a.length - 1] == "") {
                a.pop();
            }
            return a[a.length - 2];
        }
        function getId(url) {
            var a = url.split("/");
            if (a[a.length - 1] == "") {
                a.pop();
            }
            return a[a.length - 1];
        }
        $("#codename").editInPlace({
            callback: function(unused, enteredText) {
                $.ajax({
                    type: "POST",
                    url: "/aspen/action/save",
                    dataType: "json",
                    data: {
                        user: getUser(document.URL),
                        id: getId(document.URL),
                        name: enteredText,
                        body: editor.getValue()
                    },
                    success: function(msg) {
                        var $box = $("<div>").addClass("alert").addClass("fade").addClass("in");
                        $box.append($("<a>").addClass("close").attr("data-dismiss", "alert").attr("href", "#").html("&times;"));
                        if (msg.error) {
                            $box.addClass("alert-error");
                            $box.append($("<strong>").text("Error!"));
                        }
                        else {
                            $box.addClass("alert-success");
                            $box.append($("<strong>").text("OK!"));
                        }
                        $box.append(" " + msg.message);
                        $("#alertbox").html($box);
                    }
                });
                return enteredText;
            }
        });
        $("#savebtn").click(function() {
            $.ajax({
                type: "POST",
                url: "/aspen/action/save",
                dataType: "json",
                data: {
                    user: getUser(document.URL),
                    id: getId(document.URL),
                    name: $("#codename").text(),
                    body: editor.getValue()
                },
                success: function(msg) {
                    var $box = $("<div>").addClass("alert").addClass("fade").addClass("in");
                    $box.append($("<a>").addClass("close").attr("data-dismiss", "alert").attr("href", "#").html("&times;"));
                    if (msg.error) {
                        $box.addClass("alert-error");
                        $box.append($("<strong>").text("Error!"));
                    }
                    else {
                        $box.addClass("alert-success");
                        $box.append($("<strong>").text("OK!"));
                    }
                    $box.append(" " + msg.message);
                    $("#alertbox").html($box);
                }
            });
        });
        $("#resultframe");
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


