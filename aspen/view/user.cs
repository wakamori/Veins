<?cs include:"header.cs" ?>
<div class="page-header">
  <h1>
  <?cs var:User ?>&#39;s code
  <?cs if:Myself ?>
  <small>
    <a href="<?cs var:BASE_URL ?>/action/create" class="btn"><i class="icon-edit"></i> Create</a>
    <?cs if:Admin ?>
    <a href="<?cs var:BASE_URL ?>/admin/" class="btn btn-inverse"><i class="icon-user icon-white"></i> Admin</a>
    <?cs /if ?>
  </small>
  <?cs /if ?>
  </h1>
</div>
<table class="table sortable-table sort<?cs if:Myself ?>2<?cs else ?>1<?cs /if ?>">
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
