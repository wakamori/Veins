      <hr>
      <footer>
        <p><?cs var:Copyright ?></p>
      </footer>
</div> <!-- /container -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script>window.jQuery || document.write('<script src="<?cs var:STATIC_URL ?>/js/libs/jquery-1.7.1.min.js"><\/script>')</script>

<script src="<?cs var:STATIC_URL ?>/js/libs/bootstrap/collapse.js"></script>
<?cs if:ID ?>
<script src="<?cs var:STATIC_URL ?>/js/libs/bootstrap/dropdown.js"></script>
<script src="<?cs var:STATIC_URL ?>/js/libs/CodeMirror-2.22/lib/codemirror.js"></script>
<?cs /if ?>
<script src="<?cs var:STATIC_URL ?>/js/libs/bootstrap/modal.js"></script>
<script src="<?cs var:STATIC_URL ?>/js/libs/bootstrap/transition.js"></script>

<?cs if:ID ?>
<script src="<?cs var:STATIC_URL ?>/js/script.js"></script>
<?cs /if ?>
<script>
	var _gaq=[['_setAccount','UA-XXXXX-X'],['_trackPageview']];
	(function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
	g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
	s.parentNode.insertBefore(g,s)}(document,'script'));
</script>

</body>
</html>
