<?cs include:"header.cs" ?>
<div class="container">
  <h1>About Aspen</h1>
  <p>Aspen is an online Konoha development environment.</p>
  <h1>Links</h1>
  <dl>
  <?cs each:item = Links ?>
  <dt><?cs var:item.Name ?></dt>
  <dd><a href="<?cs var:item.URL ?>"><?cs var:item.URL ?></a></dd>
  <?cs /each ?>
  </dl>
</div>
<?cs include:"footer.cs" ?>
