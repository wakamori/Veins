<?cs include:"header.cs" ?>
<h1>Search text</h1>
<form action="<?cs var:BASE_URL ?>/action/search" class="well form-search" method="get">
  <input type="text" name="text" class="input-xlarge search-query" value="<?cs var:Search.Text ?>" autofocus>
  <button type="submit" class="btn">Search</button>
</form>
<h1>Search result</h1>
<div class="row-fluid">
  <div class="span6">
    <h2>User</h2>
    <table class="table table-bordered table-stripped">
      <thead>
        <tr><th>User Name</th></tr>
      </thead>
      <tbody>
        <?cs each:item = Result.Users ?><tr><td><a href="<?cs var:BASE_URL ?>/<?cs var:item ?>"><?cs var:item ?></a></td></tr><?cs /each ?>
      </tbody>
    </table>
  </div>
  <div class="span6">
    <h2>Code</h2>
    <table class="table table-bordered table-stripped">
      <thead>
        <tr><th>Code Name</th></tr>
      </thead>
      <tbody>
        <?cs each:item = Result.Codes ?><tr><td><a href="<?cs var:BASE_URL ?>/<?cs var:item.user ?>/<?cs var:item.id ?>"><?cs var:item.user ?>/<?cs var:item.name ?></a></td></tr><?cs /each ?>
      </tbody>
    </table>
  </div>
</div>
<?cs include:"footer.cs" ?>
