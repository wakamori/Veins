<?cs include:"header.cs" ?>
<h1><?cs var:Form.Title ?></h1>
<form action="<?cs var:Form.Action ?>" method="post" class="form-horizontal">
  <fieldset>
    <legend><?cs var:Form.Caption ?></legend>
    <?cs if:Error.Title ?>
    <div class="alert alert-error">
      <h4 class="alert-heading"><?cs var:Error.Title ?></h4>
      <p><?cs var:Error.Contents ?></p>
    </div>
    <?cs /if ?>
    <?cs each:item = Form.Inputs ?>
    <div class="control-group" id="<?cs var:item.ID?>-group">
      <label class="control-label" for="<?cs var:item.ID ?>"><?cs var:item.Label ?></label>
      <div class="controls">
        <input type="<?cs var:item.Input.Type ?>" class="input-xlarge" id="<?cs var:item.ID ?>"<?cs if:item.Input.Name ?> name="<?cs var:item.Input.Name ?>"<?cs /if ?><?cs if:item.Input.Value ?> value="<?cs var:item.Input.Value ?>"<?cs /if ?>>
        <span class="help-inline" id="<?cs var:item.ID ?>-help"></span>
      </div>
    </div>
    <?cs /each ?>
    <div class="form-actions">
      <?cs each:item = Form.Buttons ?><button type="<?cs var:item.Type ?>" class="<?cs var:item.Class ?>" id="<?cs var:item.ID ?>"><?cs var:item.Text ?></button><?cs /each ?>
    </div>
  </fieldset>
</form>
<?cs include:"footer.cs" ?>
