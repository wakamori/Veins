<?cs include:"header.cs" ?>
<form action="/aspen/<?cs var:User.Name ?>/<?cs var:User.Id ?>/html" method="get" target="resultframe" id="codeform" class="hideform"></form>
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
  <div class="well">
    <a href="https://twitter.com/share" class="twitter-share-button" data-text="<?cs var:User.Name ?> / <?cs var:Code.Name ?>" data-hashtags="aspen">Tweet</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    <div class="fb-like" data-href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>/<?cs var:User.Id ?>" data-send="false" data-layout="button_count" data-width="110" data-show-faces="true"></div>
  </div>
</div>
<?cs include:"footer.cs" ?>
