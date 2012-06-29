/* Memory View (Experimental) */
konoha.memview = new function() {
    var objs = [];
    var allobj = [];
    this.maxh = 0;
    this.maxw = 0;
    this.idx = 0;
    this.id;
    this.update = function() {
        var curobjs = [];
        for (var i=0; i < objs.length; i++) {
            curobjs.push(objs[i].rawptr.concat());
            if (objs[i].rawptr.length > this.maxh) {
                this.maxh = objs[i].rawptr.length;
            }
        };
        if (curobjs.length > this.maxw) {
            this.maxw = curobjs.length;
        }
        allobj.push(curobjs.concat());
    }
    this.getColor = function(r, g, b) {
        return "rgb(" + r + "," + g + "," + b + ")";
    }
    this.getCompColor = function(r, g, b) {
        return "rgb(" + Math.abs(255 - r) + "," + Math.abs(255 - g) + "," + Math.abs(255 - b) + ")";
    }
    this.display = function() {
        var maxw = this.maxw;
        var maxh = this.maxh;
        var vieww = 800;
        var viewh = 600;
        var c = document.getElementById("memview");
        if (c == null) return;
        var cnt = document.getElementById("count");
        cnt.innerHTML = this.idx;
        if (this.idx >= allobj.length - 1) {
            clearInterval(this.id);
        }
        var obj = allobj[this.idx++];
        var ctx = c.getContext("2d");
        ctx.clearRect(0, 0, vieww, viewh);
        ctx.font = "bold " + ((viewh / 2) / maxh) + "px \"Courier New\"";
        for (var i = 0; i < obj.length; i++) {
            for (var j = 0; j < obj[i].length; j++) {
                var num = obj[i][j];
                var r = Math.pow(num % 16, 2);
                var g = Math.pow(Math.floor((num / 100) % 16), 2);
                var b = Math.pow(Math.floor((num / 10000) % 16), 2);
                ctx.fillStyle = this.getColor(r, g, b);
                //console.log(this.getColor(r, g, b));
                ctx.fillRect(i * (vieww / maxw), viewh - ((j + 1) * (viewh / maxh)), ((vieww / 2) / maxw), ((viewh / 2) / maxh));
                ctx.fillStyle = this.getCompColor(r, g, b);
                //console.log(this.getCompColor(r, g, b));
                ctx.fillText("" + obj[i][j], i * (vieww / maxw), viewh - ((j + 0.5) * (viewh / maxh)));
            }
        }
        //console.log(obj);
    }
    this.show = function(ival) {
        this.id = setInterval("konoha.memview.display()", ival);
    }
    this.new = function(obj) {
        //console.log("newobj:" + obj);
        objs.push(obj);
        this.update();
    }
    this.set = function() {
        var obj = arguments[0];
        //console.log("set:" + obj);
        for (var i=1; i < arguments.length; i++) {
            //console.log("arg" + i + ":" + arguments[i]);
        }
        this.update();
    }
    this.set2 = function() {
        var obj = arguments[0];
        //console.log("set2:" + obj);
        for (var i=1; i < arguments.length; i++) {
            //console.log("arg" + i + ":" + arguments[i]);
        }
        this.update();
    }
    this.set3 = function() {
        //console.log("set3:" + obj);
        for (var i=1; i < arguments.length; i++) {
            //console.log("arg" + i + ":" + arguments[i]);
        }
        this.update();
    }
    this.add = function(obj, v) {
        //console.log("add:" + obj + "," + v);
        this.update();
    }
    this.clear = function(obj) {
        //console.log("clear:" + obj);
        this.update();
    }
    this.remove = function(obj, n) {
        //console.log("remove:" + obj + "," + n);
        this.update();
    }
    this.swap = function(obj, m, n) {
        //console.log("swap:" + obj + "," + m + "," + n);
        this.update();
    }
}
