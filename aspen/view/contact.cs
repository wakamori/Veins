<?cs include:"header.cs" ?>
<?cs if:ID ?>
<p>
  <a href="<?cs var:BASE_URL ?>/contact/new" class="btn"><i class="icon-pencil"></i> Post</a>
</p>
<?cs /if ?>
<h1>All Contacts</h1>
<table class="table">
  <thead>
    <tr><th>Title</th><th>Name</th><th>Date</th></tr>
  </thead>
  <tbody>
    <?cs each:item = Threads ?>
    <tr id="<?cs var:item.Id ?>">
      <td><a href="<?cs var:BASE_URL ?>/contact/<?cs var:item.Id ?>"><?cs var:item.Title ?></a></td>
      <td><?cs var:item.Name ?></td>
      <td><?cs var:item.Date ?></td>
    </tr>
    <?cs /each ?>
  </tbody>
</table>
<?cs include:"footer.cs" ?>
