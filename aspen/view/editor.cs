<?cs include:"header.cs" ?>
<form action="/cgi-bin/konoha2js.k" method="post" target="resultframe" id="codeform" class="hideform">
  <input type="hidden" name="requestedType" value="html">
  <input type="hidden" name="source" value="" id="sourceinput">
</form>
<div class="modal fade" id="resultwindow">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">&times;</a>
    <h3>Result</h3>
  </div>
  <div class="modal-body" id="body">
    <iframe name="resultframe" id="resultframe"></iframe>
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Close</a>
  </div>
</div>
<ul class="breadcrumb">
  <li>
    <a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>"><?cs var:User.Name ?></a> <span class="divider">/</span>
  </li>
  <li class="active"><?cs var:Code.Name ?></li>
</ul>
<div id="alertbox"></div>
<div class="btn-group">
  <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id="runbtn">Run</button><button class="btn" id="savebtn">Save</button>
</div>
<textarea id="editor"><?cs var:Code.Body ?></textarea>
<?cs include:"footer.cs" ?>
