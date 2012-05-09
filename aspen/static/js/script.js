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
            $(this).append($box);
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

/* Default class modification */
$.extend($.fn.dataTableExt.oStdClasses, {
    "sWrapper": "dataTables_wrapper form-inline"
});

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function(oSettings)
{
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
        "iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
    };
}

/* Bootstrap style pagination control */
$.extend($.fn.dataTableExt.oPagination, {
    "bootstrap": {
        "fnInit": function(oSettings, nPaging, fnDraw) {
            var oLang = oSettings.oLanguage.oPaginate;
            var fnClickHandler = function(e) {
                e.preventDefault();
                if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
                    fnDraw( oSettings );
                }
            };

            $(nPaging).addClass('pagination').append(
                '<ul>'+
                    '<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
                    '<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
                    '</ul>'
            );
            var els = $('a', nPaging);
            $(els[0]).bind('click.DT', { action: "previous" }, fnClickHandler);
            $(els[1]).bind('click.DT', { action: "next" }, fnClickHandler);
        },

        "fnUpdate": function(oSettings, fnDraw) {
            var iListLength = 5;
            var oPaging = oSettings.oInstance.fnPagingInfo();
            var an = oSettings.aanFeatures.p;
            var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

            if (oPaging.iTotalPages < iListLength) {
                iStart = 1;
                iEnd = oPaging.iTotalPages;
            }
            else if (oPaging.iPage <= iHalf) {
                iStart = 1;
                iEnd = iListLength;
            } else if (oPaging.iPage >= (oPaging.iTotalPages-iHalf)) {
                iStart = oPaging.iTotalPages - iListLength + 1;
                iEnd = oPaging.iTotalPages;
            } else {
                iStart = oPaging.iPage - iHalf + 1;
                iEnd = iStart + iListLength - 1;
            }

            for (i=0, iLen=an.length; i<iLen; i++) {
                // Remove the middle elements
                $('li:gt(0)', an[i]).filter(':not(:last)').remove();

                // Add the new list items and their event handlers
                for (j=iStart; j<=iEnd; j++) {
                    sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
                    $('<li '+sClass+'><a href="#">'+j+'</a></li>')
                    .insertBefore($('li:last', an[i])[0])
                    .bind('click', function (e) {
                        e.preventDefault();
                        oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
                        fnDraw(oSettings);
                    });
                }

                // Add / remove disabled classes from the static elements
                if (oPaging.iPage === 0) {
                    $('li:first', an[i]).addClass('disabled');
                } else {
                    $('li:first', an[i]).removeClass('disabled');
                }

                if (oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0) {
                    $('li:last', an[i]).addClass('disabled');
                } else {
                    $('li:last', an[i]).removeClass('disabled');
                }
            }
        }
    }
});

$(function() {
    if ($("#editor1")[0] != undefined) {
        var editor1 = CodeMirror(function(elt) {
            $("#editor1").replaceWith(elt);
        }, {
            value: $("#editor1").text(),
            mode: "text/plain",
            readOnly: $("#editor1").hasClass("readonly")
        });
        var editor2 = CodeMirror(function(elt) {
            $("#editor2").replaceWith(elt);
        }, {
            value: $("#editor2").text(),
            lineNumbers: true,
            mode: "text/x-konoha",
            readOnly: $("#editor2").hasClass("readonly"),
            onCursorActivity: function() {
                editor2.setLineClass(editor2.getCursor().line, null);
            },
            onChange: function(editor, e) {
                var txt = ("" + e.text);
                if (txt.length >= 2) {
                    // text is copied
                    sessionStorage.setItem("copy" + sessionStorage.length, txt);
                }
            }
        });
        var editor3 = CodeMirror(function(elt) {
            $("#editor3").replaceWith(elt);
        }, {
            value: $("#editor3").text(),
            lineNumbers: true,
            readOnly: $("#editor3").hasClass("readonly"),
            mode: "text/x-konoha"
        });
        var editor4 = CodeMirror(function(elt) {
            $("#editor4").replaceWith(elt);
        }, {
            value: $("#editor4").text(),
            lineNumbers: true,
            readOnly: $("#editor4").hasClass("readonly"),
            mode: "text/html"
        });
        var editors = [editor1, editor2, editor3, editor4];
        if ($(window).height() > 300) {
            $.each(editors, function() {
                $(this.getScrollerElement()).height($(window).height() - 280);
                $("#resultframe").height($(window).height() - 280);
            });
        }
        $.each(editors, function() {
            this.setOption("lineWrapping", true);
        });
        // TODO: for Firefox
        setTimeout(function() {
            editor2.refresh();
            editor2.refresh();
        }, 1);
        function flushHistory() {
            var ret = [];
            for (var i = 0; i < sessionStorage.length; i++) {
                var key = sessionStorage.key(i);
                if (key.indexOf("copy") == 0) {
                    ret.push(sessionStorage.getItem(key));
                    sessionStorage.removeItem(key);
                }
            }
            return JSON.stringify(ret);
        }
        function isTextChanged() {
            var changed = false;
            if (editor1.getValue() != sessionStorage.getItem("readme")) {
                changed = true;
                sessionStorage.setItem("readme", editor1.getValue());
            }
            if (editor2.getValue() != sessionStorage.getItem("js")) {
                changed = true;
                sessionStorage.setItem("js", editor2.getValue());
            }
            if (editor3.getValue() != sessionStorage.getItem("ks")) {
                changed = true;
                sessionStorage.setItem("ks", editor3.getValue());
            }
            if (editor4.getValue() != sessionStorage.getItem("html")) {
                changed = true;
                sessionStorage.setItem("html", editor4.getValue());
            }
            return changed;
        }
        function save(options) {
            options = $.extend({
                success: function(arg) {}
            }, options);
            if (isTextChanged()) {
                $.ajax({
                    type: "POST",
                    url: "/aspen/action/save",
                    dataType: "json",
                    data: {
                        user: $("#user-name").text(),
                        id: $("#user-id").text(),
                        readme: editor1.getValue(),
                        js: editor2.getValue(),
                        ks: editor3.getValue(),
                        html: editor4.getValue(),
                        history: flushHistory()
                    },
                    success: function(arg) {
                        options.success(arg);
                    }
                });
            }
            else {
                options.success({
                    message: "Script saved successfully."
                });
            }
        }
        $("#runbtn").click(function() {
            $(this).attr("disabled", "disabled");
            save({
                success: function(msg) {
                    $("#codeform").submit();
                }
            });
            setTimeout(function() {
                $("#runbtn").removeAttr("disabled");
            }, 3000);
        })
        $("#runbtn-nosave").click(function() {
            $(this).attr("disabled", "disabled");
            $("#codeform").submit();
            setTimeout(function() {
                $("#runbtn-nosave").removeAttr("disabled");
            }, 3000);
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
        $("#tab4").click(function() {
            setTimeout(function() {
                editor4.refresh();
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
                    $("#alertbox").html("");
                    $("#alertbox").notify({
                        type: type,
                        title: title,
                        body: msg.message
                    });
                }
            });
        });
        function parseCompileMessage(msg, cls) {
            editor2.setLineClass(parseInt(msg.line) - 1, cls);
            return msg.line + ": " + msg.message;
        }
        $("#checkbtn").click(function() {
            $(this).attr("disabled", "disabled");
            save({
                success: function() {
                    $.ajax({
                        type: "GET",
                        url: "/aspen/" + $("#user-name").text() + "/" + $("#user-id").text() + "/compile",
                        dataType: "json",
                        cache: false,
                        success: function(msg) {
                            $("#alertbox").html("");
                            var options = {
                                type: "",
                                title: "",
                                body: ""
                            };
                            var messaged = false;
                            if (msg.error) {
                                messaged = true;
                                options.type = "alert-error";
                                options.title = "Error!";
                                options.body = "<br>";
                                for (i = 0; i < msg.errormsg.length; i++) {
                                    options.body += parseCompileMessage(msg.errormsg[i], "errorline") + "<br>";
                                }
                                $("#alertbox").notify(options);
                            }
                            if (msg.warning) {
                                messaged = true;
                                options.type = "alert-block";
                                options.title = "Warning!";
                                options.body = "<br>";
                                for (i = 0; i < msg.warningmsg.length; i++) {
                                    options.body += parseCompileMessage(msg.warningmsg[i], "warningline") + "<br>";
                                }
                                $("#alertbox").notify(options);
                            }
                            if (msg.info) {
                                messaged = true;
                                options.type = "alert-info";
                                options.title = "Information";
                                options.body = "<br>";
                                for (i = 0; i < msg.infomsg.length; i++) {
                                    options.body += parseCompileMessage(msg.infomsg[i], "infoline") + "<br>";
                                }
                                $("#alertbox").notify(options);
                            }
                            if (!messaged) {
                                options.type = "alert-success";
                                options.title = "OK!";
                                options.body = "Compile succeeded.";
                                $("#alertbox").notify(options);
                            }
                        }
                    });
                }
            });
            setTimeout(function() {
                $("#checkbtn").removeAttr("disabled");
            }, 3000);
        });
        //$("#jcheckbtn").click(function() {
        //    save({
        //        success: function() {
        //            $.ajax({
        //                type: "GET",
        //                url: "/aspen/" + $("#user-name").text() + "/" + $("#user-id").text() + "/javac",
        //                dataType: "json",
        //                cache: false,
        //                success: function(msg) {
        //                    $("#alertbox").html("");
        //                    var options = {
        //                        type: "",
        //                        title: "",
        //                        body: ""
        //                    };
        //                    if (msg.error) {
        //                        messaged = true;
        //                        options.type = "alert-error";
        //                        options.title = "Error!";
        //                        options.body = "<br>";
        //                        options.body += msg.errormsg.replace(/\n/g, "<br>");
        //                        $("#alertbox").notify(options);
        //                    }
        //                    else {
        //                        options.type = "alert-success";
        //                        options.title = "OK!";
        //                        options.body = "Compile succeeded.";
        //                        $("#alertbox").notify(options);
        //                    }
        //                }
        //            });
        //        }
        //    });
        //});
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
    $("input#username").blur(function() {
        if (!this.value) {
            return;
        }
        $.ajax({
            type: "GET",
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
                else if (msg.error) {
                    $("#username-group").removeClass("success").addClass("error");
                    $("#username-help").text("Username is invalid.");
                } else {
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
    $("input#email").blur(function() {
        if (!this.value) {
            return;
        }
        $.ajax({
            type: "GET",
            url: "/aspen/check/email",
            dataType: "json",
            data: {
                email: this.value
            },
            success: function(msg) {
                if (msg.error) {
                    $("#email-group").removeClass("success").addClass("error");
                    $("#email-help").text("email is invalid.");
                }
                else {
                    $("#email-group").removeClass("error").addClass("success");
                    $("#email-help").text("OK.");
                }
            }
        });
    });
    $("input#email").focus(function() {
        $("#email-group").removeClass("error").removeClass("success");
        $("#email-help").text("");
    });
    $('.sortable-table').dataTable({
        "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
        "sPaginationType": "bootstrap",
        "oLanguage": {
            "sLengthMenu": "_MENU_ records per page"
        }
    });
});


