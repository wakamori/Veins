<?cs include:"header.cs" ?>
<form action="/aspen/<?cs var:User.Name ?>/<?cs var:User.Id ?>/html" method="get" target="resultframe" id="codeform" class="hideform"></form>
<div class="container-fluid">
  <div class="row-fluid">
    <div class="span6">
      <h3>
        <a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>"><?cs var:User.Name ?></a> <span class="divider">/</span>
        <?cs var:Code.Name ?>
        <small>
          View: <span class="badge"><?cs var:Code.Viewcount ?></span>
        </small>
      </h3>
    </div>
    <div class="span6">
      <ul class="nav nav-pills">
        <li><a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>"><i class="icon-home"></i> Home</a></li>
      </ul>
    </div>
  </div>
  <hr class="slim-top">
  <div class="row-fluid">
    <div class="span6">
    <?cs if:Myself ?>
      <p>
        <button class="btn btn-warning" id="checkbtn">Check</button>
        <button class="btn btn-success" id="savebtn">Save</button>
      </p>
    <?cs else ?>
      &nbsp;
    <?cs /if ?>
    </div>
    <div class="span6">
      <p>
        <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id=<?cs if:Myself ?>"runbtn"<?cs else ?>"runbtn-nosave"<?cs /if ?>><i class="icon-play icon-white"></i> Run</button>
        <a class="btn" href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>/<?cs var:User.Id ?>/html" target="_blank"><i class="icon-resize-full"></i> Fullscreen</a>
      </p>
    </div>
  </div>
  <div class="row-fluid">
    <div class="span6">
      <div class="tabbable">
        <ul class="nav nav-tabs">
          <li class="hidden"><a href="#1" data-toggle="tab" id="tab1">Readme</a></li>
          <li class="active"><a href="#2" data-toggle="tab" id="tab2">Source</a></li>
          <li class="hidden"><a href="#3" data-toggle="tab" id="tab3">Source</a></li>
          <li class="hidden"><a href="#4" data-toggle="tab" id="tab4">HTML</a></li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane" id="1">
            <textarea id="editor1"<?cs if:Myself ?><?cs else ?> class="readonly"<?cs /if ?>><?cs var:Code.Body.Readme ?></textarea>
          </div>
          <div class="tab-pane active" id="2">
            <textarea id="editor2"<?cs if:Myself ?><?cs else ?> class="readonly"<?cs /if ?>><?cs var:Code.Body.Js ?></textarea>
          </div>
          <div class="tab-pane" id="3">
            <textarea id="editor3"<?cs if:Myself ?><?cs else ?> class="readonly"<?cs /if ?>><?cs var:Code.Body.Ks ?></textarea>
          </div>
          <div class="tab-pane" id="4">
            <textarea id="editor4"<?cs if:Myself ?><?cs else ?> class="readonly"<?cs /if ?>><?cs var:Code.Body.Html ?></textarea>
          </div>
        </div>
      </div>
    </div>
    <div class="span6">
      <div class="tabbable">
        <ul class="nav nav-tabs">
          <li class="active"><a href="#5" data-toggle="tab" id="tab5">Result</a></li>
        </ul>
        <div class="tab-content">
          <div class="tab-pane active" id="5">
            <iframe name="resultframe" id="resultframe"></iframe>
          </div>
          <div class="tab-pane" id="6">
          </div>
        </div>
      </div>
    </div>
  </div>
  <?cs if:SNS ?>
  <div class="well">
    <a href="https://twitter.com/share" class="twitter-share-button" data-text="<?cs var:User.Name ?> / <?cs var:Code.Name ?>" data-hashtags="aspen">Tweet</a>
    <div class="fb-like" data-href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>/<?cs var:User.Id ?>" data-send="false" data-layout="button_count" data-width="110" data-show-faces="false"></div>
    <div class="g-plusone" data-size="medium"></div>
    <!--<div data-plugins-type="mixi-favorite" data-service-key="..."></div>
    <script type="text/javascript">
      (function(d) {
        var s = d.createElement('script'); s.type = 'text/javascript'; s.async = true;
        s.src = '//static.mixi.jp/js/plugins.js#lang=ja';
        d.getElementsByTagName('head')[0].appendChild(s);
      })(document);
    </script>
    -->
  </div>
  <?cs /if ?>
</div>
<?cs include:"footer.cs" ?>
