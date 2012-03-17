<?cs include:"header.cs" ?>
<ul>
    <?cs each:item = Page.Menu ?>
    <li>
        <a href="<?cs var:STATIC_URL ?><?cs var:item.URL ?>">
            <?cs var:item.Name ?>
        </a>
    </li>
    <?cs /each ?>
</ul>
<?cs include:"footer.cs" ?>
