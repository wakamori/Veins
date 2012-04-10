<?cs include:"header.cs" ?>
<p>
  <a class="btn"><i class="icon-pencil"></i> Post</a>
</p>
<h1>All Contacts</h1>
<table class="table">
  <thead>
    <tr><th>Name</th><th>Title</th><th>Date</th></tr>
  </thead>
  <tbody>
    <?cs each:item = Thread ?>
    <tr id="<?cs var:item.Id ?>">
      <td><?cs var:item.Name ?></td>
      <td><a href="<?cs var:BASE_URL ?>/contact/<?cs var:item.Id ?>"><?cs var:item.Title ?></a></td>
      <td><?cs var:item.Date ?></td>
    </tr>
    <?cs /each ?>
  </tbody>
</table>
<?cs include:"footer.cs" ?>
