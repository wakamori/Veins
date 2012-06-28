<!DOCTYPE html>
<html>
<head>
<title>Memory View (Experimental)</title>
<script src="<?cs var:BASE_URL ?>/<?cs var:User ?>/<?cs var:Script ?>/js"></script>
<script src="<?cs var:STATIC_URL ?>/js/libs/jquery-1.7.1.min.js"></script>
<script>
function runmain() {
	try {
		konoha_main();
	} catch (e) {
		if (typeof(e) == "string") {
			konoha.ERR = e;
		}
		else {
			throw e;
		}
	}
	var code = document.getElementById("console");
	if (typeof code.textContent != "undefined") {
		code.textContent = konoha.OUT;
	} else {
		code.innerText = konoha.OUT;
	}
}
$(function() {
	$("#start").click(function() {
		if (konoha.memview.id == null) {
			konoha.memview.show($("#interval").val());
		}
	});
	$("#stop").click(function() {
		if (konoha.memview.id != null) {
			clearInterval(konoha.memview.id);
			konoha.memview.id = null;
		}
	});
	$("#reset").click(function() {
		if (konoha.memview.id != null) {
			clearInterval(konoha.memview.id);
			konoha.memview.id = null;
		}
		konoha.memview.idx = 0;
		$("#count").text(0);
		var c = document.getElementById("memview");
		var ctx = c.getContext("2d");
		ctx.clearRect(0, 0, 800, 600);
	});
});
</script>
<style type="text/css">
canvas {
border: solid 1px #000;
}
pre {
border: solid 1px #000;
}
</style>
</head>
<body onload="runmain();">
<h1>Memory View</h1>
<p><button id="start">start</button>
<button id="stop">stop</button>
<button id="reset">reset</button>
interval: <input id="interval" value="100"></input></p>
<p>count: <span id="count">0</span></p>
<canvas id="memview" width="800" height="600"></canvas>
<h1>Console</h1>
<pre id="console">
</pre>
</body>
</html>
