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
      <div class="tabbable">
        <ul class="nav nav-tabs">
          <li class="active"><a href="#1" data-toggle="tab" id="tab1">konoha2js</a></li>
          <li><a href="#2" data-toggle="tab" id="tab2">konoha</a></li>
          <li><a href="#3" data-toggle="tab" id="tab3">HTML</a></li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active" id="1">
            <textarea id="editor1" class="readonly"><?cs var:Code.Body.Js ?></textarea>
          </div>
          <div class="tab-pane" id="2">
            <textarea id="editor2" class="readonly"><?cs var:Code.Body.Ks ?></textarea>
          </div>
          <div class="tab-pane" id="3">
            <textarea id="editor3" class="readonly"><?cs var:Code.Body.Html ?></textarea>
          </div>
        </div>
      </div>
    </div>
    <div class="span6">
      <div class="tabbable">
        <ul class="nav nav-tabs">
          <li class="active"><a href="#4" data-toggle="tab" id="tab4">Result</a></li>
          <li><a href="#5" data-toggle="tab" id="tab5">Dummy</a></li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active" id="4">
            <iframe name="resultframe" id="resultframe"></iframe>
          </div>
          <div class="tab-pane" id="5">
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<?cs include:"footer.cs" ?>
