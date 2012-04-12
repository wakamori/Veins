<?cs include:"header.cs" ?>
<form action="/aspen/<?cs var:User.Name ?>/<?cs var:User.Id ?>/html" method="get" target="resultframe" id="codeform" class="hideform"></form>
<div class="container-fluid">
  <ul class="breadcrumb">
    <li>
      <a href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>"><?cs var:User.Name ?></a> <span class="divider">/</span>
    </li>
    <li class="active"><?cs var:Code.Name ?></li>
  </ul>
  <p>
  <div class="btn-group">
    <button class="btn btn-primary" data-toggle="modal" href="#resultwindow" id="runbtn">Run</button>
    <?cs if:Myself ?>
    <a class="btn" href="<?cs var:BASE_URL ?>/<?cs var:User.Name ?>/<?cs var:User.Id ?>/edit">Edit</a>
    <?cs /if ?>
  </div>
  </p>
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
</div>
<?cs include:"footer.cs" ?>
