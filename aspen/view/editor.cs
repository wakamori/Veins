<?cs include:"header.cs" ?>
<div class="modal fade" id="result">
  <div class="modal-header">
    <a class="close" data-dismiss="modal">&times;</a>
    <h3>Result</h3>
  </div>
  <div class="modal-body" id="body">
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">Close</a>
  </div>
</div>
<div class="container">
  <div class="btn-group">
    <button class="btn btn-primary" data-toggle="modal" href="#result" id="runbtn">Run</button>
  </div>
  <textarea id="editor">// Your code goes here.
print "hello, world";</textarea>
</div>
<?cs include:"footer.cs" ?>
