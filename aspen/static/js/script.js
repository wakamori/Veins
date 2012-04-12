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
            '<a href="#" class="btn btn-primary" id="confirmYesBtn">#OK#</a>' +
            '<a href="#" class="btn" data-dismiss="modal">#Close#</a></div></div>';

            var defaults = {
                heading: 'Please confirm',
                body:'Body contents',
                ok:'Confirm',
                close:'Close',
                callback : null
            };

            var options = $.extend(defaults, options);
            html = html.replace('#Heading#',options.heading).replace('#Body#',options.body).replace('#OK#',options.ok).replace('#Close#',options.close);
            $(this).html(html);
            $(this).modal('show');
            var context = $(this);
            $('#confirmYesBtn',this).click(function(){
                if(options.callback!=null)
                    options.callback();
                $(context).modal('hide');
            });
            return this;
        },
        notify: function (options) {
            var defaults = {
                type: "alert-info",
                title: "Information",
                body: ""
            };
            var options = $.extend(defaults, options);
            var $box = $("<div>").addClass("alert").addClass("fade").addClass("in");
            $box.append($("<a>").addClass("close").attr("data-dismiss", "alert").attr("href", "#").html("&times;"));
            $box.addClass(options.type);
            $box.append($("<strong>").text(options.title));
            $box.append(" " + options.body);
            $(this).html($box);
            return this;
        }
    });
    $.extend({
        escapeHTML: function(val) {
            return $("<div>").text(val).html();
        }
    });
})(jQuery);

// twitter
!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");

// facebook
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

// google plus
(function() {
  var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
  po.src = 'https://apis.google.com/js/plusone.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
})();

$(function() {
    if ($("#editor1")[0] != undefined) {
        var editor1 = CodeMirror.fromTextArea($("#editor1")[0], {
            lineNumbers: true,
            mode: "text/x-konoha",
            readOnly: $("#editor1").hasClass("readonly"),
            onCursorActivity: function() {
                editor1.setLineClass(editor1.getCursor().line, null);
            }
        });
        var editor2 = CodeMirror.fromTextArea($("#editor2")[0], {
            lineNumbers: true,
            mode: "text/x-konoha"
        });
        var editor3 = CodeMirror.fromTextArea($("#editor3")[0], {
            lineNumbers: true,
            mode: "text/html"
        });
        function save(options) {
            options = $.extend({
                success: function(arg) {}
            }, options);
            $.ajax({
                type: "POST",
                url: "/aspen/action/save",
                dataType: "json",
                data: {
                    user: $("#user-name").text(),
                    id: $("#user-id").text(),
                    name: $("#codename").text(),
                    js: editor1.getValue(),
                    ks: editor2.getValue(),
                    html: editor3.getValue()
                },
                success: function(arg) {
                    options.success(arg);
                }
            });
        }
        $("#runbtn").click(function() {
            save({
                success: function(msg) {
                    $("#codeform").submit();
                }
            });
        });
        $("#tab1").click(function() {
            setTimeout(function() {
                editor1.refresh();
            }, 1);
        });
        $("#tab2").click(function() {
            setTimeout(function() {
                editor2.refresh();
            }, 1);
        });
        $("#tab3").click(function() {
            setTimeout(function() {
                editor3.refresh();
            }, 1);
        });
        $("#savebtn").click(function() {
            save({
                success: function(msg) {
                    var type;
                    var title;
                    if (msg.error) {
                        type = "alert-error";
                        title = "Error!";
                    }
                    else {
                        type = "alert-success";
                        title = "OK!";
                    }
                    $("#alertbox").notify({
                        type: type,
                        title: title,
                        body: msg.message
                    });
                }
            });
        });
        function parseErrorText(text) {
            text.match(/\(.+_\d+_js\.k\:(\d+)\) (.+)/);
            editor1.setLineClass(parseInt(RegExp.$1) - 1, "errorline");
            return RegExp.$1 + ": " + RegExp.$2;
        }
        $("#checkbtn").click(function() {
            save({
                success: function() {
                    $.ajax({
                        type: "GET",
                        url: "/aspen/" + $("#user-name").text() + "/" + $("#user-id").text() + "/compile",
                        dataType: "json",
                        cache: false,
                        success: function(msg) {
                            var options = {
                                type: "",
                                title: "",
                                body: ""
                            };
                            if (msg.error) {
                                options.type = "alert-error";
                                options.title = "Error!";
                                options.body = "<br>";
                                for (i = 0; i < msg.stderr.length; i++) {
                                    options.body += parseErrorText(msg.stderr[i]) + "<br>";
                                }
                            }
                            else {
                                options.type = "alert-success";
                                options.title = "OK!";
                                options.body = "Compile succeeded.";
                            }
                            $("#alertbox").notify(options);
                        }
                    });
                }
            });
        });
    }
    $(".confirm").click(function () {
        var action = $.trim($(this).text()).toLowerCase();
        var name = $.escapeHTML($(this).parent().parent().children().first().text());
        var id = $(this).parent().parent().attr("id");
        $("#confirmDiv").confirmModal({
            heading: 'Confirm to ' + action + " '" + name + "'",
            body: 'Are you sure you want to ' + action + " '" + name + "'?",
            close: 'Cancel',
            callback: function () {
                $.ajax({
                    type: "POST",
                    url: "/aspen/action/" + action,
                    dataType: "json",
                    data: {
                        id: id
                    },
                    success: function(msg) {
                        if (msg.error) {
                            alert(msg.message);
                        }
                        else {
                            $("#" + id).remove();
                        }
                    }
                });
            }
        });
    });
    $("#signoutbtn").click(function() {
        $("#signoutform").submit();
    });
    $("#signinbtn").click(function() {
        $.ajax({
            type: "POST",
            url: "/aspen/action/login",
            data: {
                type: "login",
                username: $("#input-username").val(),
                password: $("#input-password").val(),
                remember: $("#input-remember").val()
            },
            success: function(msg) {
                location.reload();
            }
        });
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


