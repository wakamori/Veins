<?cs include:"header.cs" ?>
<form action="/cgi-bin/konoha2js.k" method="post" target="resultframe" id="codeform">
  <input type="hidden" name="requestedType" value="html">
  <input type="hidden" name="source" value="" id="sourceinput">
</form>
<div class="modal fade" id="resultwindow">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">&times;</a>
    <h3>Result</h3>
  </div>
  <div class="modal-body" id="body">
    <iframe name="resultframe"></iframe>
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Close</a>
  </div>
</div>
<div class="container">
  <div class="btn-group">
    <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id="runbtn">Run</button>
  </div>
  <textarea id="editor">// Your code goes here.
print "hello, world";</textarea>
</div>
<?cs include:"footer.cs" ?>
