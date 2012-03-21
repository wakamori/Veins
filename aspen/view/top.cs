<?cs include:"header.cs" ?>
<div class="modal fade" id="sign-in">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">&times;</a>
    <h3>Sign in form</h3>
  </div>
  <div class="modal-body">
    <form class="well" action="<?cs var:BASE_URL ?>/login" method="post">
      <input name="type" type="hidden" value="login">
      <input name="username" type="text" class="input-medium" placeholder="Username"<?cs if:Remember == "on" ?> value="<?cs var:Username ?>"<?cs /if ?>>
      <input name="password" type="password" class="input-medium" placeholder="Password"<?cs if:Remember == "on" ?> value="<?cs var:Password ?>"<?cs /if ?>>
      <label class="checkbox">
        <input type="checkbox" name="remember" value="on"<?cs if:Remember == "on" ?> checked<?cs /if ?>> Remember me
      </label>
      <button type="submit" class="btn">Sign in</button>
    </form>
  </div>
</div>

<!-- Main hero unit for a primary marketing message or call to action -->
<div class="hero-unit">
  <h1>Aspen</h1>
  <p>Aspen is an online Konoha development environment. You can edit, run and debug your Konoha code on your browser.</p>
  <p><a class="btn btn-primary btn-large" data-toggle="modal" href="#sign-in">Try now</a></p>
</div>

<!-- Example row of columns -->
<div class="row">
  <div class="span4">
    <h2>Heading</h2>
     <p>Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. </p>
    <p><a class="btn" href="#">View details &raquo;</a></p>
  </div>
  <div class="span4">
    <h2>Heading</h2>
     <p>Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. </p>
    <p><a class="btn" href="#">View details &raquo;</a></p>
 </div>
  <div class="span4">
    <h2>Heading</h2>
    <p>Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.</p>
    <p><a class="btn" href="#">View details &raquo;</a></p>
  </div>
</div>
<?cs include:"footer.cs" ?>
