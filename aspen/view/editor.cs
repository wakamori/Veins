<?cs include:"header.cs" ?>
<form action="/aspen/<?cs var:User.Name ?>/<?cs var:User.Id ?>/html" method="get" target="resultframe" id="codeform" class="hideform"></form>
<div class="modal fade" id="resultwindow">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">&times;</a>
    <h3 id="window-title">Run Result</h3>
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
  <li id="codename">
    <a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>/<?cs var:User.Id ?>"><?cs var:Code.Name ?></a>
  </li>
</ul>
<div class="btn-toolbar">
  <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id="runbtn">Run</button>
  <button class="btn btn-warning" id="checkbtn">Check</button>
  <button class="btn btn-success" id="savebtn">Save</button>
</div>
<div class="tabbable">
  <ul class="nav nav-tabs">
    <li class="hidden"><a href="#1" data-toggle="tab" id="tab1">Readme</a></li>
    <li class="active"><a href="#2" data-toggle="tab" id="tab2">Source</a></li>
    <li class="hidden"><a href="#3" data-toggle="tab" id="tab3">Source</a></li>
    <li class="hidden"><a href="#4" data-toggle="tab" id="tab4">HTML</a></li>
  </ul>
  <div class="tab-content">
    <div class="tab-pane" id="1">
      <textarea id="editor1"><?cs var:Code.Body.Readme ?></textarea>
    </div>
    <div class="tab-pane active" id="2">
      <textarea id="editor2"><?cs var:Code.Body.Js ?></textarea>
    </div>
    <div class="tab-pane" id="3">
      <textarea id="editor3"><?cs var:Code.Body.Ks ?></textarea>
    </div>
    <div class="tab-pane" id="4">
      <textarea id="editor4"><?cs var:Code.Body.Html ?></textarea>
    </div>
  </div>
</div>
<?cs include:"footer.cs" ?>
