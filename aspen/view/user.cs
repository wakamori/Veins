<?cs include:"header.cs" ?>
<?cs if:Myself ?>
<p>
  <a href="<?cs var:BASE_URL ?>/action/create" class="btn"><i class="icon-edit"></i> Create</a>
</p>
<?cs /if ?>
<h1><?cs var:User ?>&#39;s Code</h1>
<table class="table">
  <thead>
    <tr><th>Name</th><?cs if:Myself ?><th>Actions</th><?cs /if ?><th>Date</th></tr>
  </thead>
  <tbody>
    <?cs each:item = Code ?>
    <tr id="<?cs var:item.Id ?>">
      <td><a href="<?cs var:BASE_URL ?>/<?cs var:User ?>/<?cs var:item.Id ?>"><?cs var:item.Name ?></a></td>
      <?cs if:Myself ?><td><a href="<?cs var:BASE_URL ?>/<?cs var:User ?>/<?cs var:item.Id ?>/edit" class="btn btn-mini">Edit</a> <button class="btn btn-mini btn-danger confirm">Delete</button></td><?cs /if ?>
      <td><?cs var:item.Date ?></td>
    </tr>
    <?cs /each ?>
  </tbody>
</table>
<?cs include:"footer.cs" ?>
