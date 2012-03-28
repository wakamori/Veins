<?cs include:"header.cs" ?>
<form action="/cgi-bin/konoha2js.k" method="post" target="resultframe" id="codeform" class="hideform">
  <input type="hidden" name="requestedType" value="html">
  <input type="hidden" name="source" value="" id="sourceinput">
</form>
<ul class="breadcrumb">
  <li>
    <a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>"><?cs var:User.Name ?></a> <span class="divider">/</span>
  </li>
  <li class="active"><?cs var:Code.Name ?></li>
</ul>
<div class="container-fluid">
  <div class="btn-group">
    <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id="runbtn">Run</button>
  </div>
  <div class="row-fluid">
    <div class="span6">
      <textarea id="editor" class="readonly"><?cs var:Code.Body ?></textarea>
    </div>
    <div class="span6">
      <iframe name="resultframe" id="resultframe"></iframe>
    </div>
  </div>
</div>
<?cs include:"footer.cs" ?>
