/* Author:
    2011 chenji <wakamori111 at gmail.com> @chen_ji on twitter
*/

(function ($) {
    $.fn.extend({
        //pass the options variable to the function
        confirmModal: function (options) {
            var html = '<div class="modal" id="confirmContainer"><div class="modal-header"><a class="close" data-dismiss="modal">&times;</a>' +
            '<h3>#Heading#</h3></div><div class="modal-body">' +
            '#Body#</div><div class="modal-footer">' +
            '<a href="#" class="btn btn-primary" id="confirmYesBtn">Confirm</a>' +
            '<a href="#" class="btn" data-dismiss="modal">Close</a></div></div>';

            var defaults = {
                heading: 'Please confirm',
                body:'Body contents',
                callback : null
            };

            var options = $.extend(defaults, options);
            html = html.replace('#Heading#',options.heading).replace('#Body#',options.body);
            $(this).html(html);
            $(this).modal('show');
            var context = $(this);
            $('#confirmYesBtn',this).click(function(){
                if(options.callback!=null)
                    options.callback();
                $(context).modal('hide');
            });
        }
    });
})(jQuery);

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
                return $("<div>").text(enteredText).html();
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
    $(".confirm").click(function () {
        var action = $.trim(this.text);
        $("#confirmDiv").confirmModal({
            heading: 'Confirm to delete',
            body: 'Are you sure you want to delete this code?',
            callback: function () {
                $.ajax({
                    type: "POST",
                    url: "/aspen/action/delete",
                    dataType: "json",
                    data: {
                    },
                });
            }
        });
    });
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


