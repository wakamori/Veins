<?cs include:"header.cs" ?>
    <h1>Session</h1>
    <p>session ID: <?cs var:Session.ID ?></p>
    <table>
        <caption>
            Session test
        </caption>
        <thead>
            <tr><th>key</th><th>value</th></tr>
        </thead>
        <tbody>
            <?cs each:item = Session.Items ?>
            <tr><td><?cs var:item.key ?></td><td><?cs var:item.value ?></td></tr>
            <?cs /each ?>
        </tbody>
    </table>
<?cs include:"footer.cs" ?>
