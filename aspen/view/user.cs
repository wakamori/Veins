<?cs include:"header.cs" ?>
<div class="container-fluid">
  <div class="row-fluid">
    <div class="span2">
      <table class="table table-bordered">
        <tbody>
          <?cs each:item = Info ?>
          <tr>
            <th><?cs var:item.key ?></th>
            <td><?cs var:item.value ?></td>
          </tr>
          <?cs /each ?>
        </tbody>
      </table>
    </div>
    <div class="span10">
      <?cs if:Myself ?>
      <form action="<?cs var:BASE_URL ?>/create" method="post" class="form-inline">
        <button type="submit" class="btn"><i class="icon-pencil"></i> Start coding</button>
      </form>
      <?cs /if ?>
      <h1>Code</h1>
      <table class="table table-stripped">
        <thead>
          <tr><th>Name</th><th>Caption</th><th>Date</th></tr>
        </thead>
        <tbody>
          <?cs each:item = Code ?>
          <tr>
            <td><?cs var:item.Name ?></td>
            <td><?cs var:item.Caption ?></td>
            <td><?cs var:item.Date ?></td>
          </tr>
          <?cs /each ?>
        </tbody>
      </table>
    </div>
  </div>
</div>
<?cs include:"footer.cs" ?>
