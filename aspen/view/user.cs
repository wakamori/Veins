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
        <a href="<?cs var:BASE_URL ?>/action/create" class="btn"><i class="icon-edit"></i> Create code</a>
      </form>
      <?cs /if ?>
      <h1>Code</h1>
      <table class="table">
        <thead>
          <tr><th>Name</th><th>Description</th><?cs if:Myself ?><th>Actions</th><?cs /if ?><th>Date</th></tr>
        </thead>
        <tbody>
          <?cs each:item = Code ?>
          <tr id="<?cs var:item.Id ?>">
            <td><a href="<?cs var:BASE_URL ?>/<?cs var:User ?>/<?cs var:item.Id ?>"><?cs var:item.Name ?></a></td>
            <td><?cs var:item.Description ?></td>
            <?cs if:Myself ?><td><a href="<?cs var:BASE_URL ?>/<?cs var:User ?>/<?cs var:item.Id ?>" class="btn btn-mini">Edit</a> <button class="btn btn-mini btn-danger confirm">Delete</button></td><?cs /if ?>
            <td><?cs var:item.Date ?></td>
          </tr>
          <?cs /each ?>
        </tbody>
      </table>
    </div>
  </div>
</div>
<?cs include:"footer.cs" ?>
