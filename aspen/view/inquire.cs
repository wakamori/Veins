<?cs include:"header.cs" ?>
<h1>Post a new Topic</h1>
<form action="<?cs var:BASE_URL ?>/contact/new" method="post" class="form-horizontal">
  <fieldset>
    <legend>We'd love to answer all your questions.</legend>
    <?cs if:Error.Title ?>
    <div class="alert alert-error">
      <h4 class="alert-heading"><?cs var:Error.Title ?></h4>
      <p><?cs var:Error.Contents ?></p>
    </div>
    <?cs /if ?>
    <div class="control-group" id="title-group">
      <label class="control-label" for="title">Title</label>
      <div class="controls">
        <input type="text" class="input-xlarge" id="title" name="title" required autofocus>
        <span class="help-inline" id="title-help"></span>
      </div>
    </div>
    <div class="control-group" id="contents-group">
      <label class="control-label" for="contents">Contents</label>
      <div class="controls">
        <textarea type="text" class="input-xlarge" id="contents" name="contents" rows="5" required></textarea>
        <span class="help-inline" id="contents-help"></span>
      </div>
    </div>
    <div class="form-actions">
      <button type="submit" class="btn btn-primary">Post</button>
    </div>
  </fieldset>
</form>
<?cs include:"footer.cs" ?>
