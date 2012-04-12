<?cs include:"header.cs" ?>
<!-- Main hero unit for a primary marketing message or call to action -->
<div class="hero-unit">
  <h1>Aspen</h1>
  <p>Aspen is an online Konoha development environment.<br>You can edit, run and debug your Konoha code on your browser.</p>
  <p>
    <a class="btn btn-primary btn-large" data-toggle="modal" href="#sign-in">Try now</a>
    <a class="btn btn-large" href="<?cs var:BASE_URL ?>/action/signup">Sign up</a>
  </p>
</div>

<div class="row">
  <div class="span4">
    <h2>Online code hosting</h2>
     <p>You can edit your code with in-browser code editor. You can access your scripts from anyware.</p>
  </div>
  <div class="span4">
    <h2>Static type checker</h2>
     <p>Scripts are converted from Konoha to JavaScript on a server side, and they are runned on client side. Since konoha is a statically typed scripting language, a type checker can detect type errors without running a script.</p>
 </div>
  <div class="span4">
    <h2>Social coding</h2>
    <p>Share your code with others.</p>
  </div>
</div>
<?cs include:"footer.cs" ?>
