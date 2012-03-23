<?cs include:"header.cs" ?>
<h1>Sign up for Aspen</h1>
<form action="/aspen/signup" method="post" class="form-horizontal">
  <fieldset>
    <legend>Create your personal account</legend>
    <?cs if:Error.Title ?>
    <div class="alert alert-error">
      <h4 class="alert-heading"><?cs var:Error.Title ?></h4>
      <p><?cs var:Error.Contents ?></p>
    </div>
    <?cs /if ?>
    <div class="control-group" id="username-group">
      <label class="control-label" for="username">Username</label>
      <div class="controls">
        <input type="text" class="input-xlarge" id="username" name="username"<?cs if:Input.username ?> value="<?cs var:Input.username ?>"<?cs /if ?>>
        <span class="help-inline" id="username-help"></span>
      </div>
    </div>
    <div class="control-group" id="email-group">
      <label class="control-label" for="email">Email Address</label>
      <div class="controls">
        <input type="email" class="input-xlarge" id="email" name="email"<?cs if:Input.email ?> value="<?cs var:Input.email ?>"<?cs /if ?>>
        <span class="help-inline" id="email-help"></span>
      </div>
    </div>
    <div class="control-group" id="password-group">
      <label class="control-label" for="password">Password</label>
      <div class="controls">
        <input type="password" class="input-xlarge" id="password" name="password">
        <span class="help-inline" id="password-help"></span>
      </div>
    </div>
    <div class="control-group" id="confirm-group">
      <label class="control-label" for="confirm">Confirm Password</label>
      <div class="controls">
        <input type="password" class="input-xlarge" id="confirm">
        <span class="help-inline" id="confirm-help"></span>
      </div>
    </div>
    <div class="form-actions">
      <button type="submit" class="btn btn-primary" id="create-btn">Create an account</button>
    </div>
  </fieldset>
</form>
<?cs include:"footer.cs" ?>
