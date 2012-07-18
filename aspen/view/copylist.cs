<?cs include:"header.cs" ?>
<div class="page-header">
  <h1>CopyList</h1>
</div>
<table class="table sortable-table sort1">
  <thead>
    <tr><th>User</th><th>Name</th><?cs if:Myself ?><th>Actions</th><?cs /if ?><th>Date</th></tr>
  </thead>
  <tbody>
    <?cs each:item = Code ?>
    <tr id="<?cs var:item.Id ?>">
      <td><a href="<?cs var:BASE_URL ?>/<?cs var:item.User ?>"><?cs var:item.User ?></a></td>
      <td><a href="<?cs var:BASE_URL ?>/<?cs var:item.User ?>/<?cs var:item.Id ?>"><?cs var:item.Name ?></a></td>
      <?cs if:Myself ?><td><a href="<?cs var:BASE_URL ?>/<?cs var:item.User ?>/<?cs var:item.Id ?>/edit" class="btn btn-mini">Edit</a> <button class="btn btn-mini btn-danger confirm">Delete</button></td><?cs /if ?>
      <td><?cs var:item.Date ?></td>
    </tr>
    <?cs /each ?>
  </tbody>
</table>
<?cs include:"footer.cs" ?>
