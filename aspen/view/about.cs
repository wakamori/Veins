<?cs include:"header.cs" ?>
<h1>About Aspen</h1>
<p>Aspen is an online Konoha development environment.</p>
<h1>What's New</h1>
<script charset="utf-8" src="http://widgets.twimg.com/j/2/widget.js"></script>
<script>
new TWTR.Widget({
  version: 2,
  type: 'profile',
  rpp: 4,
  interval: 30000,
  width: 'auto',
  height: 300,
  theme: {
    shell: {
      background: '#2c2c2c',
      color: '#ffffff'
    },
    tweets: {
      background: '#ffffff',
      color: '#333333',
      links: '#0088cc'
    }
  },
  features: {
    scrollbar: true,
    loop: false,
    live: true,
    behavior: 'default'
  }
}).render().setUser('ynualgo2012').start();
</script>
<h1>Links</h1>
<dl>
<?cs each:item = Links ?>
<dt><?cs var:item.Name ?></dt>
<dd><a href="<?cs var:item.URL ?>"><?cs var:item.URL ?></a></dd>
<?cs /each ?>
</dl>
<?cs include:"footer.cs" ?>
